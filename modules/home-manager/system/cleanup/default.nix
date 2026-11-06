{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkIf
    optionalString
    ;

  cfg = config.system.cleanup;

  # ---------------------------------------------------------------------------
  # Registro Declarativo de Aplicações Conhecidas
  # Mapeia cada módulo para seus diretórios de configuração (~/.config),
  # caches (~/.cache), dados locais (~/.local/share) e atalhos (.desktop).
  # ---------------------------------------------------------------------------
  knownApps = [
    # --- Gerenciadores de Arquivos ---
    {
      name = "spacefm";
      enabled = false; # Removido permanentemente
      configs = [ "$HOME/.config/spacefm" ];
      caches = [ "$HOME/.cache/spacefm" ];
      data = [ "$HOME/.local/share/spacefm" ];
      desktops = [ "$HOME/.local/share/applications/spacefm*.desktop" ];
    }
    {
      name = "thunar";
      enabled = config.system.programs.file-manager.thunar.enable or false;
      configs = [
        "$HOME/.config/Thunar"
        "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
      ];
      caches = [ "$HOME/.cache/Thunar" ];
      data = [ "$HOME/.local/share/Thunar" ];
      desktops = [
        "$HOME/.local/share/applications/thunar*.desktop"
        "$HOME/.local/share/applications/Thunar*.desktop"
      ];
    }
    {
      name = "nautilus";
      enabled = config.system.programs.file-manager.nautilus.enable or false;
      configs = [ "$HOME/.config/nautilus" ];
      caches = [ "$HOME/.cache/nautilus" ];
      data = [ "$HOME/.local/share/nautilus" ];
      desktops = [ "$HOME/.local/share/applications/org.gnome.Nautilus*.desktop" ];
    }
    {
      name = "nemo";
      enabled = config.system.programs.file-manager.nemo.enable or false;
      configs = [ "$HOME/.config/nemo" ];
      caches = [ "$HOME/.cache/nemo" ];
      data = [ "$HOME/.local/share/nemo" ];
      desktops = [ "$HOME/.local/share/applications/nemo*.desktop" ];
    }
    {
      name = "pcmanfm";
      enabled = config.system.programs.file-manager.pcmanfm.enable or false;
      configs = [ "$HOME/.config/pcmanfm" ];
      caches = [ "$HOME/.cache/pcmanfm" ];
      data = [ "$HOME/.local/share/pcmanfm" ];
      desktops = [ "$HOME/.local/share/applications/pcmanfm*.desktop" ];
    }
    {
      name = "catfish";
      # Catfish é utilitário de busca integrado ao Thunar e XFCE4
      enabled =
        (config.system.programs.file-manager.thunar.enable or false)
        || (config.desktop.environments.xfce4.enable or false);
      configs = [ "$HOME/.config/catfish" ];
      caches = [ "$HOME/.cache/catfish" ];
      data = [ "$HOME/.local/share/catfish" ];
      desktops = [ "$HOME/.local/share/applications/org.xfce.Catfish*.desktop" ];
    }

    # --- Comunicação / Chat ---
    {
      name = "discord";
      enabled = config.system.programs.chat.discord.enable or false;
      configs = [
        "$HOME/.config/discord"
        "$HOME/.config/BetterDiscord"
        "$HOME/.config/Vencord"
      ];
      caches = [ "$HOME/.cache/discord" ];
      data = [ "$HOME/.local/share/discord" ];
      desktops = [ "$HOME/.local/share/applications/*discord*.desktop" ];
    }

    # --- Editores ---
    {
      name = "vscode";
      enabled = config.system.programs.editors.vscode.enable or false;
      configs = [ "$HOME/.config/Code" ];
      caches = [ "$HOME/.cache/vscode-cpptools" ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "gedit";
      enabled = config.system.programs.editors.gedit.enable or false;
      configs = [ "$HOME/.config/gedit" ];
      caches = [ ];
      data = [ "$HOME/.local/share/gedit" ];
      desktops = [
        "$HOME/.local/share/applications/org.gnome.gedit*.desktop"
        "$HOME/.local/share/applications/gedit*.desktop"
      ];
    }
    {
      name = "zitext";
      enabled = false; # Descontinuado / removido permanentemente
      configs = [ "$HOME/.config/zitext" ];
      caches = [ "$HOME/.cache/zitext" ];
      data = [ "$HOME/.local/share/zitext" ];
      desktops = [
        "$HOME/.local/share/applications/zitext*.desktop"
        "$HOME/.local/share/applications/ZITEXT*.desktop"
      ];
    }

    # --- Terminais ---
    {
      name = "alacritty";
      enabled =
        (config.system.programs.terminal.enable or false)
        && ((config.system.programs.terminal.name or "") == "alacritty");
      configs = [ "$HOME/.config/alacritty" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "kitty";
      enabled =
        (config.system.programs.terminal.enable or false)
        && ((config.system.programs.terminal.name or "") == "kitty");
      configs = [ "$HOME/.config/kitty" ];
      caches = [ "$HOME/.cache/kitty" ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "urxvt";
      enabled =
        (
          (config.system.programs.terminal.enable or false)
          && (
            ((config.system.programs.terminal.name or "") == "urxvt")
            || ((config.system.programs.terminal.name or "") == "rxvt")
          )
        )
        || (config.system.programs.terminal.urxvt.enable or false);
      configs = [ "$HOME/.urxvt" ];
      caches = [ ];
      data = [ ];
      desktops = [
        "$HOME/.local/share/applications/rxvt.desktop"
        "$HOME/.local/share/applications/urxvt.desktop"
      ];
    }

    # --- Multimídia ---
    {
      name = "sonixd";
      enabled = config.system.programs.multimedia.sonixd.enable or false;
      configs = [ "$HOME/.config/sonixd" ];
      caches = [ "$HOME/.cache/sonixd" ];
      data = [ ];
      desktops = [ "$HOME/.local/share/applications/*sonixd*.desktop" ];
    }
    {
      name = "rhythmbox";
      enabled = config.system.programs.multimedia.rhythmbox.enable or false;
      configs = [ "$HOME/.config/rhythmbox" ];
      caches = [ "$HOME/.cache/rhythmbox" ];
      data = [ "$HOME/.local/share/rhythmbox" ];
      desktops = [ "$HOME/.local/share/applications/*rhythmbox*.desktop" ];
    }
    {
      name = "audio-recorder";
      enabled = config.system.programs.multimedia.audio-recorder.enable or false;
      configs = [ "$HOME/.config/audio-recorder" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "ncmpcpp";
      enabled = config.system.programs.multimedia.ncmpcpp.enable or false;
      configs = [ "$HOME/.config/ncmpcpp" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }

    # --- Ferramentas / Utilitários ---
    {
      name = "bleachbit";
      enabled = config.system.programs.tools.bleachbit.enable or false;
      configs = [ "$HOME/.config/bleachbit" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "flameshot";
      enabled = config.system.programs.tools.flameshot.enable or false;
      configs = [ "$HOME/.config/flameshot" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "meld";
      enabled = config.system.programs.tools.meld.enable or false;
      configs = [ "$HOME/.config/meld" ];
      caches = [ ];
      data = [ "$HOME/.local/share/meld" ];
      desktops = [ ];
    }
    {
      name = "fastfetch";
      enabled = config.system.programs.tools.fastfetch.enable or false;
      configs = [ "$HOME/.config/fastfetch" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }

    # --- Documentos ---
    {
      name = "zathura";
      enabled = config.system.programs.documents.zathura.enable or false;
      configs = [ "$HOME/.config/zathura" ];
      caches = [ ];
      data = [ "$HOME/.local/share/zathura" ];
      desktops = [ ];
    }
    {
      name = "libreoffice";
      enabled = config.system.programs.documents.libreoffice.enable or false;
      configs = [ "$HOME/.config/libreoffice" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
  ];

  # Filtra apenas aplicações que estão desativadas ou removidas
  inactiveApps = builtins.filter (app: !app.enabled) knownApps;

  # Constrói o bloco de limpeza estática declarativa
  declarativeCleanupCommands = concatStringsSep "\n" (
    map (app: ''
      # [${app.name}] - Aplicação desativada ou removida
      ${concatStringsSep "\n" (
        map (p: ''
          for target in ${p}; do
            if [ -e "$target" ] || [ -L "$target" ]; then
              remove_path "$target" "${app.name} (config)"
            fi
          done
        '') app.configs
      )}
      ${optionalString cfg.cleanCaches (
        concatStringsSep "\n" (
          map (p: ''
            for target in ${p}; do
              if [ -e "$target" ] || [ -L "$target" ]; then
                remove_path "$target" "${app.name} (cache)"
              fi
            done
          '') app.caches
        )
      )}
      ${optionalString cfg.cleanData (
        concatStringsSep "\n" (
          map (p: ''
            for target in ${p}; do
              if [ -e "$target" ] || [ -L "$target" ]; then
                remove_path "$target" "${app.name} (local share)"
              fi
            done
          '') app.data
        )
      )}
      ${concatStringsSep "\n" (
        map (p: ''
          for target in ${p}; do
            if [ -e "$target" ] || [ -L "$target" ]; then
              remove_path "$target" "${app.name} (desktop entry)"
            fi
          done
        '') app.desktops
      )}
    '') inactiveApps
  );

  writeShellApp =
    args:
    pkgs.writeShellApplication (
      args
      // {
        bashOptions = args.bashOptions or [ ];
        excludeShellChecks = (args.excludeShellChecks or [ ]) ++ [
          "SC1090"
          "SC1091"
          "SC2012"
          "SC2034"
          "SC2086"
          "SC2089"
          "SC2090"
        ];
      }
    );

  declarativeRulesFile = pkgs.writeText "declarative-cleanup.sh" ''
    ${declarativeCleanupCommands}
    ${concatStringsSep "\n" (
      map (p: ''
        for target in ${p}; do
          if [ -e "$target" ] || [ -L "$target" ]; then
            remove_path "$target" "extraPath"
          fi
        done
      '') cfg.extraPaths
    )}
  '';

  # Script executável e despachante de limpeza de órfãos
  cleanupScriptPkg = writeShellApp {
    name = "clean-orphaned-configs";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gawk
      pkgs.gnugrep
      pkgs.findutils
    ];
    runtimeEnv = {
      CLEAN_CACHES = if cfg.cleanCaches then "1" else "0";
      CLEAN_DATA = if cfg.cleanData then "1" else "0";
      CLEAN_BROKEN_SYMLINKS = if cfg.cleanBrokenSymlinks then "1" else "0";
      CLEAN_ORPHANED_DESKTOPS = if cfg.cleanOrphanedDesktops then "1" else "0";
      DECLARATIVE_RULES_FILE = "${declarativeRulesFile}";
    };
    text = builtins.readFile ./scripts/clean-orphaned.sh;
  };

  cleanHmAppsPkg = writeShellApp {
    name = "hm-clean-apps";
    runtimeInputs = [ cleanupScriptPkg ];
    text = builtins.readFile ./scripts/clean-hm-apps.sh;
  };
in
{
  options.system.cleanup = {
    enable = lib.my.mkBool true ''
      Ativa a limpeza automática e declarativa de configurações residuais (~/.config),
      caches (~/.cache), dados locais (~/.local/share) e atalhos de desktop de qualquer
      aplicação que tenha sido removida ou desativada no Nixfiles.
    '';

    cleanCaches = lib.my.mkBool true "Remove diretórios de cache (~/.cache/<app>) de aplicações desativadas.";

    cleanData = lib.my.mkBool true "Remove diretórios de dados locais (~/.local/share/<app>) de aplicações desativadas.";

    cleanBrokenSymlinks = lib.my.mkBool true "Remove links simbólicos corrompidos em ~/.local/share/applications e ~/.config.";

    cleanOrphanedDesktops = lib.my.mkBool true "Remove arquivos .desktop residuais cujos binários apontem para store paths inexistentes.";

    extraPaths =
      lib.my.mkListOf lib.types.str [ ]
        "Lista adicional de diretórios ou arquivos a serem limpos caso existam.";
  };

  config = mkIf cfg.enable {
    # Disponibiliza o utilitário no PATH do usuário
    home.packages = [
      cleanupScriptPkg
      cleanHmAppsPkg
    ];

    # Hook de ativação automático no Home Manager (executa em todo switch)
    home.activation.cleanupOrphanedConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${cleanupScriptPkg}/bin/clean-orphaned-configs \
        ''${oldGenPath:+--old-gen "$oldGenPath"} \
        ''${newGenPath:+--new-gen "$newGenPath"}
    '';
  };
}
