# modules/home-manager/desktop/environments/bspwm/sxhkd.nix
# Daemon de atalhos de teclado SXHKD para o ambiente BSPWM.
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

  scripts = import ./_sxhkd-scripts.nix {
    inherit
      pkgs
      lib
      nixGLWrapper
      scratchpadLaunchCmd
      fmCmd
      picomBin
      screenshotSavePath
      browserLaunchCmd
      termCmd
      termDisplayName
      modDisplayName
      ;
  };

  isAppleKeyboard =
    (config.home.keyboard.model or "") == "apple" || (config.home.keyboard.model or "") == "macbook";

  effectiveScreenshotProfile =
    if cfg.screenshotProfile != "auto" then
      cfg.screenshotProfile
    else if isAppleKeyboard then
      "mac"
    else
      "standard";

  screenshotBindings =
    if effectiveScreenshotProfile == "none" then
      { }
    else if effectiveScreenshotProfile == "custom" then
      cfg.screenshotKeybindings
    else if effectiveScreenshotProfile == "mac" then
      {
        # --- Perfil macOS (MacBook Pro / Air e teclados Apple sem tecla Print física) ---
        "${mod} + shift + 3" = "${scripts.screenshotScript} full";
        "${mod} + shift + 4" = "${scripts.screenshotScript} area";
        "${mod} + shift + 5" = "${scripts.screenshotScript} menu";
        "${mod} + shift + 6" = "${scripts.screenshotScript} gif";
        "Print" = "${scripts.screenshotScript} full";
        "shift + Print" = "${scripts.screenshotScript} area";
        "ctrl + Print" = "${scripts.screenshotScript} window";
        "ctrl + shift + Print" = "${scripts.screenshotScript} gif";
        "super + shift + s" = "${scripts.screenshotScript} menu";
        "${mod} + ctrl + shift + s" = "${scripts.screenshotScript} gif";
        "XF86SelectiveScreenshot" = "${scripts.screenshotScript} area";
      }
      // lib.optionalAttrs (mod != "super") {
        "${mod} + shift + s" = "${scripts.screenshotScript} area";
      }
    else
      {
        # --- Perfil Standard / PC (Acer Nitro, PCs desktop, VMs, etc.) ---
        "Print" = "${scripts.screenshotScript} full";
        "shift + Print" = "${scripts.screenshotScript} area";
        "ctrl + Print" = "${scripts.screenshotScript} window";
        "ctrl + shift + Print" = "${scripts.screenshotScript} gif";
        "${mod} + shift + Print" = "${scripts.screenshotScript} in5";
        "${mod} + Print" = "${scripts.screenshotScript} menu";
        "Sys_Req" = "${scripts.screenshotScript} full";
        "shift + Sys_Req" = "${scripts.screenshotScript} area";
        "super + shift + s" = "${scripts.screenshotScript} menu";
        "${mod} + ctrl + shift + s" = "${scripts.screenshotScript} gif";
        "XF86SelectiveScreenshot" = "${scripts.screenshotScript} area";
      }
      // lib.optionalAttrs (mod != "super") {
        "${mod} + shift + s" = "${scripts.screenshotScript} area";
      };

  baseBindings = import ./_sxhkd-bindings.nix {
    inherit
      pkgs
      mod
      ctrlMod
      browserLaunchCmd
      termCmd
      fmCmd
      scripts
      ;
  };
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
      keybindings =
        baseBindings
        // screenshotBindings
        //
          lib.optionalAttrs (config.desktop.bspwm.polybar.enable && config.desktop.bspwm.polybar.tray.enable)
            {
              # Bandeja do Sistema Stalonetray (oculta/exibe)
              "${mod} + i" = "stalonetray-toggle";
              "${mod} + shift + i" = "stalonetray-toggle";
            }
        // lib.optionalAttrs (mod == "super") {
          # Super + Alt + Setas / H,J,K,L: redimensionamento rápido tradicional de janelas
          "super + alt + {Left,Down,Up,Right}" = "${scripts.resizeScript} {left,down,up,right}";
          "super + alt + {h,j,k,l}" = "${scripts.resizeScript} {left,down,up,right}";
        }
        // (config.desktop.bspwm.extraKeybindings or { })
        // cfg.keybindings
        // cfg.extraKeybindings;
    };

    # Utilitários de linha de comando para uso interativo e scripts
    home.packages = [
      scripts.pseudoTileScriptPkg
      (pkgs.writeShellScriptBin "bspwm-pseudo-tile" ''exec ${scripts.pseudoTileScript} "$@"'')
      scripts.screenshotScriptPkg
      (pkgs.writeShellScriptBin "screenshoter" ''exec ${scripts.screenshotScript} "$@"'')
      scripts.resizeScriptPkg
      scripts.colorPickerScriptPkg
      scripts.mediaControlPkg
    ];
  };
}
