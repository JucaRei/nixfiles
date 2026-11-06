# modules/home-manager/desktop/environments/bspwm/_sxhkd-scripts.nix
# Derivações herméticas e wrappers de scripts utilitários do SXHKD.
{
  pkgs,
  lib,
  nixGLWrapper ? lib.id,
  scratchpadLaunchCmd,
  fmCmd,
  picomBin,
  screenshotSavePath,
  browserLaunchCmd,
  termCmd,
  termDisplayName,
  modDisplayName,
}:
let
  writeShellApp =
    args:
    pkgs.writeShellApplication (
      args
      // {
        bashOptions = args.bashOptions or [ ];
        excludeShellChecks = (args.excludeShellChecks or [ ]) ++ [
          "SC1087"
          "SC1091"
          "SC2001"
          "SC2005"
          "SC2012"
          "SC2015"
          "SC2016"
          "SC2028"
          "SC2034"
          "SC2046"
          "SC2059"
          "SC2076"
          "SC2086"
          "SC2089"
          "SC2090"
          "SC2119"
          "SC2120"
          "SC2126"
          "SC2154"
          "SC2155"
          "SC2181"
          "SC2183"
          "SC2206"
          "SC2207"
          "SC2221"
          "SC2222"
        ];
      }
    );

  scratchpadScriptPkg = writeShellApp {
    name = "bspwm-scratchpad";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.jq
      pkgs.xdo
      pkgs.xprop
    ];
    runtimeEnv = {
      SCRATCHPAD_LAUNCH_CMD = scratchpadLaunchCmd;
    };
    text = builtins.readFile ./scripts/bspwm-scratchpad.sh;
  };
  scratchpadScript = lib.getExe scratchpadScriptPkg;

  resizeScriptPkg = writeShellApp {
    name = "bspwm-resize";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.coreutils
    ];
    text = builtins.readFile ./scripts/bspwm-resize.sh;
  };
  resizeScript = lib.getExe resizeScriptPkg;

  screenshotScriptPkg = writeShellApp {
    name = "bspwm-screenshot";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.byzanz
      pkgs.dunst
      pkgs.feh
      pkgs.ffmpeg
      pkgs.jq
      pkgs.maim
      (nixGLWrapper pkgs.picom)
      pkgs.procps
      pkgs.rofi
      pkgs.slop
      pkgs.xclip
      pkgs.xdg-utils
    ];
    runtimeEnv = {
      FILE_MANAGER_CMD = fmCmd;
      PICOM_BIN = picomBin;
      SCREENSHOT_SAVE_PATH = screenshotSavePath;
    };
    text = builtins.readFile ./scripts/bspwm-screenshot.sh;
  };
  screenshotScript = lib.getExe screenshotScriptPkg;

  volumeOsdPkg = writeShellApp {
    name = "volume-osd";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.gawk
      pkgs.gnugrep
      pkgs.pamixer
      pkgs.pulseaudio
    ];
    text = builtins.readFile ./scripts/volume-osd.sh;
  };
  volumeOsd = lib.getExe volumeOsdPkg;

  brightnessOsdPkg = writeShellApp {
    name = "brightness-osd";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.dunst
    ];
    text = builtins.readFile ./scripts/brightness-osd.sh;
  };
  brightnessOsd = lib.getExe brightnessOsdPkg;

  mediaControlPkg = writeShellApp {
    name = "bspwm-media-control";
    runtimeInputs = [
      pkgs.dunst
      pkgs.playerctl
    ];
    text = builtins.readFile ./scripts/bspwm-media-control.sh;
  };
  mediaControl = lib.getExe mediaControlPkg;

  colorPickerScriptPkg = writeShellApp {
    name = "bspwm-colorpicker";
    runtimeInputs = [
      pkgs.dunst
      pkgs.xclip
      pkgs.xcolor
    ];
    text = builtins.readFile ./scripts/bspwm-colorpicker.sh;
  };
  colorPickerScript = lib.getExe colorPickerScriptPkg;

  kbdBrightnessOsdPkg = writeShellApp {
    name = "kbd-brightness-osd";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.dunst
      pkgs.solaar
    ];
    text = builtins.readFile ./scripts/kbd-brightness-osd.sh;
  };
  kbdBrightnessOsd = lib.getExe kbdBrightnessOsdPkg;

  pseudoTileScriptPkg = writeShellApp {
    name = "bspwm-toggle-pseudo-tile";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.dunst
    ];
    text = builtins.readFile ./scripts/bspwm-toggle-pseudo-tile.sh;
  };
  pseudoTileScript = lib.getExe pseudoTileScriptPkg;

  quickSettingsPkg = writeShellApp {
    name = "quick-settings";
    runtimeInputs = [
      pkgs.arandr
      pkgs.dunst
      pkgs.feh
      pkgs.lxappearance
      pkgs.networkmanagerapplet
      pkgs.nitrogen
      pkgs.pavucontrol
      pkgs.rofi
      pkgs.rofi-power-menu
      pkgs.xdg-utils
      pkgs.xrandr
      scratchpadScriptPkg
      screenshotScriptPkg
      colorPickerScriptPkg
      pseudoTileScriptPkg
    ];
    runtimeEnv = {
      BROWSER_CMD = browserLaunchCmd;
      TERMINAL_CMD = termCmd;
      TERMINAL_NAME = termDisplayName;
      MOD_NAME = modDisplayName;
      FILE_MANAGER_CMD = fmCmd;
    };
    text = builtins.readFile ./scripts/quick-settings.sh;
  };
  quickSettings = lib.getExe quickSettingsPkg;

  desktopFocusScriptPkg = writeShellApp {
    name = "bspwm-desktop-focus";
    runtimeInputs = [ pkgs.bspwm ];
    text = builtins.readFile ./scripts/bspwm-desktop-focus.sh;
  };
  desktopFocusScript = lib.getExe desktopFocusScriptPkg;

  desktopNodeScriptPkg = writeShellApp {
    name = "bspwm-node-to-desktop";
    runtimeInputs = [ pkgs.bspwm ];
    text = builtins.readFile ./scripts/bspwm-node-to-desktop.sh;
  };
  desktopNodeScript = lib.getExe desktopNodeScriptPkg;

  desktopRightClickScriptPkg = writeShellApp {
    name = "bspwm-desktop-right-click";
    runtimeInputs = [
      pkgs.xdotool
      pkgs.xprop
      quickSettingsPkg
    ];
    text = builtins.readFile ./scripts/bspwm-desktop-right-click.sh;
  };
  desktopRightClickScript = lib.getExe desktopRightClickScriptPkg;

  toggleDesktopScriptPkg = writeShellApp {
    name = "bspwm-toggle-desktop";
    runtimeInputs = [ pkgs.bspwm ];
    text = builtins.readFile ./scripts/bspwm-toggle-desktop.sh;
  };
  toggleDesktopScript = lib.getExe toggleDesktopScriptPkg;
in
{
  inherit
    scratchpadScriptPkg
    scratchpadScript
    resizeScriptPkg
    resizeScript
    screenshotScriptPkg
    screenshotScript
    volumeOsdPkg
    volumeOsd
    brightnessOsdPkg
    brightnessOsd
    mediaControlPkg
    mediaControl
    colorPickerScriptPkg
    colorPickerScript
    kbdBrightnessOsdPkg
    kbdBrightnessOsd
    pseudoTileScriptPkg
    pseudoTileScript
    quickSettingsPkg
    quickSettings
    desktopFocusScriptPkg
    desktopFocusScript
    desktopNodeScriptPkg
    desktopNodeScript
    desktopRightClickScriptPkg
    desktopRightClickScript
    toggleDesktopScriptPkg
    toggleDesktopScript
    ;
}
