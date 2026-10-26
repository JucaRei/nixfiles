{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    optionalString
    mkDefault
    mkIf
    mkMerge
    ;

  cfg = config.system.programs.file-manager;
  cfgNautilus = config.system.programs.file-manager.nautilus or { enable = false; };
  cfgThunar = config.system.programs.file-manager.thunar or { enable = false; };
  cfgNemo = config.system.programs.file-manager.nemo or { enable = false; };
  cfgPcmanfm = config.system.programs.file-manager.pcmanfm or { enable = false; };

  # Determina qual gerenciador de arquivos é o preferencial/ativo
  chosenFM =
    if cfg.default != "auto" then
      cfg.default
    else if (cfgThunar.enable or false) then
      "thunar"
    else if (cfgNautilus.enable or false) then
      "nautilus"
    else if (cfgNemo.enable or false) then
      "nemo"
    else if (cfgPcmanfm.enable or false) then
      "pcmanfm"
    else
      "auto";

  nautilusBin =
    if (cfgNautilus.useSystemPackage or false) || (cfgNautilus.useSystemPackages or false) then
      "nautilus"
    else
      "${cfgNautilus.package or pkgs.nautilus}/bin/nautilus";

  thunarBin =
    if (cfgThunar.enable or false) then
      "${cfgThunar.package or pkgs.thunar}/bin/thunar"
    else
      "${pkgs.thunar}/bin/thunar";

  nemoBin =
    if (cfgNemo.useSystemPackage or false) || (cfgNemo.useSystemPackages or false) then
      "nemo"
    else
      "${cfgNemo.package or pkgs.nemo-with-extensions}/bin/nemo";

  pcmanfmBin =
    if (cfgPcmanfm.useSystemPackage or false) || (cfgPcmanfm.useSystemPackages or false) then
      "pcmanfm"
    else
      "${cfgPcmanfm.package or pkgs.pcmanfm}/bin/pcmanfm";

  activeCommand =
    if chosenFM == "nautilus" then
      nautilusBin
    else if chosenFM == "nemo" then
      nemoBin
    else if chosenFM == "pcmanfm" then
      pcmanfmBin
    else if chosenFM == "thunar" then
      thunarBin
    else
      "file-manager";

  activeName =
    if chosenFM == "nautilus" then
      "Nautilus"
    else if chosenFM == "nemo" then
      "Nemo"
    else if chosenFM == "pcmanfm" then
      "PCManFM"
    else if chosenFM == "thunar" then
      "Thunar"
    else
      "Gerenciador de Arquivos";

  activeDesktopFile =
    if chosenFM == "nautilus" then
      "org.gnome.Nautilus.desktop"
    else if chosenFM == "nemo" then
      "nemo.desktop"
    else if chosenFM == "pcmanfm" then
      "pcmanfm.desktop"
    else if chosenFM == "thunar" then
      "thunar.desktop"
    else
      null;

  # Despachante agnóstico acessível via terminal ou atalhos ('file-manager')
  fileManagerDispatcher = pkgs.writeShellScriptBin "file-manager" ''
    # Agnostic File Manager Dispatcher
    TARGET="''${1:-$HOME}"

    ${optionalString (chosenFM == "nautilus") ''
      exec ${nautilusBin} "$TARGET" "''${@:2}"
    ''}
    ${optionalString (chosenFM == "nemo") ''
      exec ${nemoBin} "$TARGET" "''${@:2}"
    ''}
    ${optionalString (chosenFM == "pcmanfm") ''
      exec ${pcmanfmBin} "$TARGET" "''${@:2}"
    ''}
    ${optionalString (chosenFM == "thunar") ''
      exec ${thunarBin} "$TARGET" "''${@:2}"
    ''}

    # Detecção dinâmica caso o binário não seja estático
    if command -v nautilus >/dev/null 2>&1; then
      exec nautilus "$TARGET" "''${@:2}"
    elif command -v nemo >/dev/null 2>&1; then
      exec nemo "$TARGET" "''${@:2}"
    elif command -v pcmanfm >/dev/null 2>&1; then
      exec pcmanfm "$TARGET" "''${@:2}"
    elif command -v thunar >/dev/null 2>&1; then
      exec thunar "$TARGET" "''${@:2}"
    else
      exec xdg-open "$TARGET"
    fi
  '';
  anyFMEnabled =
    (cfgThunar.enable or false)
    || (cfgNautilus.enable or false)
    || (cfgNemo.enable or false)
    || (cfgPcmanfm.enable or false);
in
{
  imports = [
    ./thunar
    ./nautilus
    ./nemo
    ./pcmanfm
  ];

  options.system.programs.file-manager = {
    default = mkOption {
      type = types.enum [
        "auto"
        "thunar"
        "nautilus"
        "nemo"
        "pcmanfm"
      ];
      default = "auto";
      description = ''
        Gerenciador de arquivos preferido do sistema.
        Se 'auto', seleciona automaticamente entre nautilus, nemo, pcmanfm ou thunar conforme ativado.
      '';
    };

    activeCommand = mkOption {
      type = types.str;
      default = activeCommand;
      description = "Comando executável para invocar o gerenciador de arquivos ativo em atalhos de WM e scripts.";
    };

    activeName = mkOption {
      type = types.str;
      default = activeName;
      description = "Nome amigável do gerenciador de arquivos ativo (ex: Nautilus, Nemo, PCManFM, Thunar).";
    };

    cleanInactiveConfigs = mkOption {
      type = types.bool;
      default = config.system.cleanup.enable;
      description = ''
        Indica se a limpeza declarativa de arquivos residuais para gerenciadores inativos está ativada.
        Delegado ao módulo centralizado system.cleanup.
      '';
    };

    enableThumbnails = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Habilitar serviço global de miniaturas (Tumbler / Freedesktop Thumbnailer) e geradores
        (ffmpegthumbnailer, webp, poppler, libgsf, freetype, shared-mime-info) para todos os gerenciadores de arquivos.
      '';
    };
  };

  config = mkMerge [
    {
      # Disponibiliza o despachante agnóstico no PATH do usuário
      home.packages = [
        fileManagerDispatcher
      ];
    }
    (mkIf (activeDesktopFile != null) {
      xdg.mimeApps = {
        defaultApplications = {
          "inode/directory" = mkDefault activeDesktopFile;
        };
        associations.added = {
          "inode/directory" = activeDesktopFile;
        };
      };
    })
    (mkIf (cfg.enableThumbnails && anyFMEnabled) {
      # Serviço de usuário Systemd para o daemon de miniaturas do FreeDesktop (Tumbler)
      systemd.user.services.tumbler = mkIf pkgs.stdenv.isLinux {
        Unit = {
          Description = "Thumbnail generator service (Tumbler / FreeDesktop)";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "dbus";
          BusName = "org.freedesktop.thumbnails.Thumbnailer1";
          ExecStart = "${pkgs.tumbler}/lib/tumbler-1/tumblerd";
          Restart = "on-failure";
          RestartSec = 3;
          Environment = [
            "GIO_EXTRA_MODULES=${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules"
            "XDG_DATA_DIRS=${pkgs.tumbler}/share:${pkgs.shared-mime-info}/share:${pkgs.gdk-pixbuf}/share:/usr/local/share:/usr/share"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" "default.target" ];
        };
      };

      # Arquivos de ativação D-Bus para o barramento de sessão do usuário (~/.local/share/dbus-1/services)
      xdg.dataFile = {
        "dbus-1/services/org.freedesktop.thumbnails.Thumbnailer1.service".text = ''
          [D-BUS Service]
          Name=org.freedesktop.thumbnails.Thumbnailer1
          Exec=${pkgs.tumbler}/lib/tumbler-1/tumblerd
        '';
        "dbus-1/services/org.freedesktop.thumbnails.Manager1.service".text = ''
          [D-BUS Service]
          Name=org.freedesktop.thumbnails.Manager1
          Exec=${pkgs.tumbler}/lib/tumbler-1/tumblerd
        '';
        "dbus-1/services/org.freedesktop.thumbnails.Cache1.service".text = ''
          [D-BUS Service]
          Name=org.freedesktop.thumbnails.Cache1
          Exec=${pkgs.tumbler}/lib/tumbler-1/tumblerd
        '';
        "dbus-1/services/org.xfce.Tumbler.Thumbnailer1.service".text = ''
          [D-BUS Service]
          Name=org.xfce.Tumbler.Thumbnailer1
          Exec=${pkgs.tumbler}/lib/tumbler-1/tumblerd
        '';
        "dbus-1/services/org.xfce.Tumbler.Manager1.service".text = ''
          [D-BUS Service]
          Name=org.xfce.Tumbler.Manager1
          Exec=${pkgs.tumbler}/lib/tumbler-1/tumblerd
        '';
        "dbus-1/services/org.xfce.Tumbler.Cache1.service".text = ''
          [D-BUS Service]
          Name=org.xfce.Tumbler.Cache1
          Exec=${pkgs.tumbler}/lib/tumbler-1/tumblerd
        '';
      };

      # Limpa miniaturas marcadas como erro e reinicia o serviço Tumbler para todos os gerenciadores
      home.activation.cleanThumbnailFailCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD rm -rf "$HOME/.cache/thumbnails/fail" 2>/dev/null || true
        if systemctl --user is-active --quiet tumbler.service 2>/dev/null; then
          $DRY_RUN_CMD systemctl --user restart tumbler.service 2>/dev/null || true
        fi
      '';

      # Pacotes essenciais de thumbnailing compartilhados por todos os file managers
      home.packages = with pkgs; [
        tumbler
        ffmpegthumbnailer
        webp-pixbuf-loader
        libgsf
        poppler
        freetype
        shared-mime-info
      ];
    })
  ];
}
