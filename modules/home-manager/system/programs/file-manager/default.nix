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
    else if (cfgNautilus.enable or false) then
      "nautilus"
    else if (cfgNemo.enable or false) then
      "nemo"
    else if (cfgPcmanfm.enable or false) then
      "pcmanfm"
    else if (cfgThunar.enable or false) then
      "thunar"
    else
      "auto";

  nautilusBin =
    if (cfgNautilus.useSystemPackage or false) || (cfgNautilus.useSystemPackages or false) then
      "nautilus"
    else
      "${cfgNautilus.package or pkgs.nautilus}/bin/nautilus";

  thunarBin = "${pkgs.thunar}/bin/thunar";

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
  };

  config = mkMerge [
    {
      # Disponibiliza o despachante agnóstico no PATH do usuário
      home.packages = [
        fileManagerDispatcher
      ];
    }
    (mkIf (activeDesktopFile != null) {
      xdg.mimeApps.defaultApplications = {
        "inode/directory" = mkDefault activeDesktopFile;
      };
    })
  ];
}
