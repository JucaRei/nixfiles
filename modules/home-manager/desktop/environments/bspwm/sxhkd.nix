{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm.sxhkd;
  fmCmd = config.system.programs.file-manager.activeCommand or "file-manager";

  terminalCfg = config.system.programs.terminal;
  termCmd = terminalCfg.activeCommand;
  termDisplayName = terminalCfg.activeName;
  scratchpadLaunchCmd = "${terminalCfg.scratchpadCommand} &";

  browserBin = config.system.programs.browsers.activeBin or null;
  browserLaunchCmd =
    if browserBin != null then
      "${browserBin} &"
    else
      ''if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || firefox 2>/dev/null || x-www-browser & fi'';

  picomBin = "${nixGLWrapper pkgs.picom}/bin/picom";

  screenshotSavePath = "${config.home.homeDirectory}/Pictures/Screenshots";

  normMod =
    let
      k = lib.toLower (cfg.modifierKey or "super");
    in
    if k == "super" || k == "mod4" then
      "Super"
    else if k == "alt" || k == "mod1" then
      "Alt"
    else if k == "ctrl" || k == "control" then
      "Ctrl"
    else
      "Super";

  mod =
    if normMod == "Alt" then
      "alt"
    else if normMod == "Ctrl" then
      "ctrl"
    else
      "super";

  ctrlMod = if mod == "ctrl" then "super" else "ctrl";
  modDisplayName = normMod;

  sxhkdScripts = import ./_sxhkd-scripts.nix {
    inherit
      pkgs
      lib
      config
      cfg
      mod
      modDisplayName
      screenshotSavePath
      fmCmd
      termCmd
      termDisplayName
      scratchpadLaunchCmd
      browserLaunchCmd
      picomBin
      nixGLWrapper
      ;
  };
  inherit (sxhkdScripts)
    pseudoTileScriptPkg
    pseudoTileScript
    screenshotScriptPkg
    screenshotScript
    screenshotBindings
    resizeScriptPkg
    resizeScript
    colorPickerScriptPkg
    colorPickerScript
    scratchpadScript
    desktopFocusScript
    mediaControlPkg
    mediaControl
    volumeOsd
    brightnessOsd
    kbdBrightnessOsd
    quickSettings
    desktopNodeScript
    desktopRightClickScript
    toggleDesktopScript
    ;
in
{
  options.desktop.bspwm.sxhkd = {
    enable = lib.my.mkBool config.desktop.bspwm.enable "Enable sxhkd keybindings for bspwm";

    modifierKey = lib.my.mkStr (config.desktop.bspwm.modifierKey
      or (config.desktop.modifierKey or "Super")
    ) "Tecla modificadora principal do SXHKD (ex: 'super', 'alt', 'ctrl').";

    keybindings =
      lib.my.mkOpt (lib.types.attrsOf lib.types.str) { }
        "sxhkd keybindings adicionais ou customizadas.";

    extraKeybindings =
      lib.my.mkOpt (lib.types.attrsOf lib.types.str) { }
        "Atalhos adicionais ou personalizados do SXHKD definidos no host.";

    screenshotProfile =
      lib.my.mkEnum
        [
          "auto"
          "standard"
          "mac"
          "custom"
          "none"
        ]
        "auto"
        ''
          Perfil de teclas de atalho para captura de tela (screenshots):
          - "auto": detecta automaticamente (teclado Apple/Mac usa "mac", outros usam "standard").
          - "standard": ideal para PCs (Acer, Nitro, VMs, etc.) usando Print, Shift+Print, Ctrl+Print. Preserva Super+Shift+1..0 livres para workspaces!
          - "mac": estilo macOS usando Super+Shift+3/4/5 para telas/áreas de captura.
          - "custom": utiliza os atalhos declarados em screenshotKeybindings.
          - "none": desativa os atalhos de screenshot do sxhkd.
        '';

    screenshotKeybindings =
      lib.my.mkOpt (lib.types.attrsOf lib.types.str) { }
        "Mapeamento customizado de atalhos para captura de tela quando screenshotProfile = 'custom'.";
  };

  config = mkIf cfg.enable {
    # Recarregar automaticamente o sxhkd ao rodar switch-home (sem reiniciar o bspwm)
    home.activation.reloadSxhkd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -USR1 -x sxhkd 2>/dev/null || (cd "$HOME" && $DRY_RUN_CMD nohup ${pkgs.sxhkd}/bin/sxhkd >/dev/null 2>&1 &)
    '';

    services.sxhkd = {
      enable = true;
      package = pkgs.sxhkd;
      keybindings = import ./_sxhkd-bindings.nix {
        inherit
          lib
          config
          cfg
          pkgs
          mod
          ctrlMod
          fmCmd
          termCmd
          browserLaunchCmd
          desktopRightClickScript
          desktopFocusScript
          desktopNodeScript
          toggleDesktopScript
          scratchpadScript
          quickSettings
          screenshotScript
          screenshotBindings
          resizeScript
          pseudoTileScript
          colorPickerScript
          volumeOsd
          mediaControl
          brightnessOsd
          kbdBrightnessOsd
          ;
      };
    };

    # Utilitários de linha de comando para uso interativo e scripts
    home.packages = [
      pseudoTileScriptPkg
      (pkgs.writeShellScriptBin "bspwm-pseudo-tile" ''exec ${pseudoTileScript} "$@"'')
      screenshotScriptPkg
      (pkgs.writeShellScriptBin "screenshoter" ''exec ${screenshotScript} "$@"'')
      resizeScriptPkg
      colorPickerScriptPkg
      mediaControlPkg
    ];
  };
}
