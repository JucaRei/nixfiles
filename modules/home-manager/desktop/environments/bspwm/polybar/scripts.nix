{
  pkgs,
  colors,
  lib ? pkgs.lib,
  polybar ? (
    pkgs.polybar.override {
      pulseSupport = true;
      i3Support = false;
    }
  ),
  ...
}:
let
  colorEnv = {
    COLOR_BLUE = colors.blue;
    COLOR_CRUST = colors.crust;
    COLOR_GREEN = colors.green;
    COLOR_LAVENDER = colors.lavender;
    COLOR_MAUVE = colors.mauve;
    COLOR_MUTED = colors.muted;
    COLOR_PEACH = colors.peach;
    COLOR_RED = colors.red;
    COLOR_SAPPHIRE = colors.sapphire;
    COLOR_SKY = colors.sky;
    COLOR_SUBTEXT0 = colors.subtext0;
    COLOR_SURFACE1 = colors.surface1;
    COLOR_SURFACE2 = colors.surface2;
    COLOR_TEAL = colors.teal;
    COLOR_TEXT = colors.text;
    COLOR_YELLOW = colors.yellow;
  };

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
in
rec {
  polywinsScriptPkg = writeShellApp {
    name = "polybar-polywins";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.xprop
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-polywins.sh;
  };
  polywinsScript = lib.getExe polywinsScriptPkg;

  mediaControlScriptPkg = writeShellApp {
    name = "polybar-media-control";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.playerctl
    ];
    text = builtins.readFile ./scripts/polybar-media-control.sh;
  };
  mediaControlScript = lib.getExe mediaControlScriptPkg;

  mediaScriptPkg = writeShellApp {
    name = "polybar-media";
    runtimeInputs = [
      mediaControlScriptPkg
      pkgs.coreutils
      pkgs.gnused
      pkgs.playerctl
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-media.sh;
  };
  mediaScript = lib.getExe mediaScriptPkg;

  bluetoothScriptPkg = writeShellApp {
    name = "polybar-bluetooth";
    runtimeInputs = [
      pkgs.bluez
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.procps
      pkgs.uutils-coreutils-noprefix
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-bluetooth.sh;
  };
  bluetoothScript = lib.getExe bluetoothScriptPkg;

  audioScriptPkg = writeShellApp {
    name = "polybar-audio";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.pamixer
      pkgs.pulseaudio
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-audio.sh;
  };
  audioScript = lib.getExe audioScriptPkg;

  audioControlScriptPkg = writeShellApp {
    name = "polybar-audio-control";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.pamixer
      pkgs.pulseaudio
    ];
    text = builtins.readFile ./scripts/polybar-audio-control.sh;
  };
  audioControlScript = lib.getExe audioControlScriptPkg;

  networkScriptPkg = writeShellApp {
    name = "polybar-network";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.networkmanager
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-network.sh;
  };
  networkScript = lib.getExe networkScriptPkg;

  minimizedScriptPkg = writeShellApp {
    name = "polybar-minimized";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.gnugrep
      pkgs.uutils-coreutils-noprefix
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-minimized.sh;
  };
  minimizedScript = lib.getExe minimizedScriptPkg;

  temperatureScriptPkg = writeShellApp {
    name = "polybar-temperature";
    runtimeInputs = [
      pkgs.gawk
      pkgs.gnugrep
      pkgs.uutils-coreutils-noprefix
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-temperature.sh;
  };
  temperatureScript = lib.getExe temperatureScriptPkg;

  redshiftScriptPkg = writeShellApp {
    name = "polybar-redshift";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.gnugrep
      pkgs.procps
      pkgs.redshift
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-redshift.sh;
  };
  redshiftScript = lib.getExe redshiftScriptPkg;

  bspLayoutScriptPkg = writeShellApp {
    name = "bsp-layout-status";
    runtimeInputs = [
      pkgs.bsp-layout
      pkgs.bspwm
      pkgs.coreutils
      pkgs.jq
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/bsp-layout-status.sh;
  };
  bspLayoutScript = lib.getExe bspLayoutScriptPkg;

  bspLayoutSwitchScriptPkg = writeShellApp {
    name = "bsp-layout-switch";
    runtimeInputs = [
      pkgs.bsp-layout
      pkgs.bspwm
      pkgs.coreutils
      pkgs.dunst
      pkgs.jq
    ];
    text = builtins.readFile ./scripts/bsp-layout-switch.sh;
  };
  bspLayoutSwitchScript = lib.getExe bspLayoutSwitchScriptPkg;

  osLogoScriptPkg = writeShellApp {
    name = "polybar-os-logo";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-os-logo.sh;
  };
  osLogoScript = lib.getExe osLogoScriptPkg;

  uptimeScriptPkg = writeShellApp {
    name = "polybar-uptime";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-uptime.sh;
  };
  uptimeScript = lib.getExe uptimeScriptPkg;

  netspeedScriptPkg = writeShellApp {
    name = "polybar-netspeed";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.iproute2
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-netspeed.sh;
  };
  netspeedScript = lib.getExe netspeedScriptPkg;

  backlightScriptPkg = writeShellApp {
    name = "polybar-backlight";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.coreutils
      pkgs.dunst
      pkgs.polybar
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-backlight.sh;
  };
  backlightScript = lib.getExe backlightScriptPkg;

  stalonetrayToggleScriptPkg = writeShellApp {
    name = "stalonetray-toggle";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.procps
      pkgs.stalonetray
      pkgs.xdotool
    ];
    text = builtins.readFile ./scripts/stalonetray-toggle.sh;
  };
  stalonetrayToggleScript = lib.getExe stalonetrayToggleScriptPkg;

  polybarLaunchScriptPkg = writeShellApp {
    name = "polybar-launch";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.procps
      pkgs.util-linux
      pkgs.xrandr
      polybar
    ];
    text = builtins.readFile ./scripts/polybar-launch.sh;
  };
  polybarLaunchScript = lib.getExe polybarLaunchScriptPkg;

  notificationStatusScriptPkg = writeShellApp {
    name = "polybar-notifications-status";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.procps
      pkgs.systemd
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-notifications-status.sh;
  };
  notificationStatusScript = lib.getExe notificationStatusScriptPkg;

  notificationToggleDndScriptPkg = writeShellApp {
    name = "polybar-notifications-dnd";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.systemd
    ];
    text = builtins.readFile ./scripts/polybar-notifications-dnd.sh;
  };
  notificationToggleDndScript = lib.getExe notificationToggleDndScriptPkg;

  # Rofi interactive menus and pickers
  rofiMenus = import ./_rofi-menus.nix {
    inherit
      pkgs
      lib
      writeShellApp
      bspLayoutSwitchScriptPkg
      ;
  };

  inherit (rofiMenus)
    rofiBluetoothMenuPkg
    rofiBluetoothMenu
    rofiWifiMenuPkg
    rofiWifiMenu
    rofiPowerMenuPkg
    rofiPowerMenu
    restoreMenuScriptPkg
    restoreMenuScript
    rofiKeyboardMenuPkg
    rofiKeyboardMenu
    rofiLayoutMenuPkg
    rofiLayoutMenu
    rofiNotificationMenuPkg
    rofiNotificationMenu
    ;
}
