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
in
rec {
  polywinsScriptPkg = pkgs.writeShellApplication {
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

  mediaControlScriptPkg = pkgs.writeShellApplication {
    name = "polybar-media-control";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.playerctl
    ];
    text = builtins.readFile ./scripts/polybar-media-control.sh;
  };
  mediaControlScript = lib.getExe mediaControlScriptPkg;

  mediaScriptPkg = pkgs.writeShellApplication {
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

  bluetoothScriptPkg = pkgs.writeShellApplication {
    name = "polybar-bluetooth";
    runtimeInputs = [
      pkgs.bluez
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.uutils-coreutils-noprefix
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-bluetooth.sh;
  };
  bluetoothScript = lib.getExe bluetoothScriptPkg;

  audioScriptPkg = pkgs.writeShellApplication {
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

  audioControlScriptPkg = pkgs.writeShellApplication {
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

  rofiBluetoothMenuPkg = pkgs.writeShellApplication {
    name = "rofi-bluetooth";
    runtimeInputs = [
      pkgs.blueman
      pkgs.bluez
      pkgs.dunst
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.procps
      pkgs.rofi
      pkgs.util-linux
      pkgs.uutils-coreutils-noprefix
    ];
    text = builtins.readFile ./scripts/rofi-bluetooth.sh;
  };
  rofiBluetoothMenu = lib.getExe rofiBluetoothMenuPkg;

  networkScriptPkg = pkgs.writeShellApplication {
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

  rofiWifiMenuPkg = pkgs.writeShellApplication {
    name = "rofi-wifi-menu";
    runtimeInputs = [
      pkgs.dunst
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.networkmanager
      pkgs.networkmanagerapplet
      pkgs.procps
      pkgs.rofi
      pkgs.uutils-coreutils-noprefix
    ];
    text = builtins.readFile ./scripts/rofi-wifi-menu.sh;
  };
  rofiWifiMenu = lib.getExe rofiWifiMenuPkg;

  rofiPowerMenuPkg = pkgs.writeShellApplication {
    name = "rofi-powermenu";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.rofi
      pkgs.systemd
      pkgs.uutils-coreutils-noprefix
    ];
    text = builtins.readFile ./scripts/rofi-powermenu.sh;
  };
  rofiPowerMenu = lib.getExe rofiPowerMenuPkg;

  minimizedScriptPkg = pkgs.writeShellApplication {
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

  restoreMenuScriptPkg = pkgs.writeShellApplication {
    name = "rofi-restore-minimized";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.rofi
      pkgs.uutils-coreutils-noprefix
      pkgs.xdotool
    ];
    text = builtins.readFile ./scripts/rofi-restore-minimized.sh;
  };
  restoreMenuScript = lib.getExe restoreMenuScriptPkg;

  temperatureScriptPkg = pkgs.writeShellApplication {
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

  rofiKeyboardMenuPkg = pkgs.writeShellApplication {
    name = "rofi-keyboard";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.gnused
      pkgs.rofi
      pkgs.xkb-switch
    ];
    text = builtins.readFile ./scripts/rofi-keyboard.sh;
  };
  rofiKeyboardMenu = lib.getExe rofiKeyboardMenuPkg;

  redshiftScriptPkg = pkgs.writeShellApplication {
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

  bspLayoutScriptPkg = pkgs.writeShellApplication {
    name = "bsp-layout-status";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.coreutils
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/bsp-layout-status.sh;
  };
  bspLayoutScript = lib.getExe bspLayoutScriptPkg;

  bspLayoutSwitchScriptPkg = pkgs.writeShellApplication {
    name = "bsp-layout-switch";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.coreutils
      pkgs.dunst
    ];
    text = builtins.readFile ./scripts/bsp-layout-switch.sh;
  };
  bspLayoutSwitchScript = lib.getExe bspLayoutSwitchScriptPkg;

  rofiLayoutMenuPkg = pkgs.writeShellApplication {
    name = "rofi-bsp-layout";
    runtimeInputs = [
      bspLayoutSwitchScriptPkg
      pkgs.bspwm
      pkgs.coreutils
      pkgs.dunst
      pkgs.rofi
    ];
    text = builtins.readFile ./scripts/rofi-bsp-layout.sh;
  };
  rofiLayoutMenu = lib.getExe rofiLayoutMenuPkg;

  osLogoScriptPkg = pkgs.writeShellApplication {
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

  uptimeScriptPkg = pkgs.writeShellApplication {
    name = "polybar-uptime";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-uptime.sh;
  };
  uptimeScript = lib.getExe uptimeScriptPkg;

  netspeedScriptPkg = pkgs.writeShellApplication {
    name = "polybar-netspeed";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-netspeed.sh;
  };
  netspeedScript = lib.getExe netspeedScriptPkg;

  backlightScriptPkg = pkgs.writeShellApplication {
    name = "polybar-backlight";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.coreutils
    ];
    runtimeEnv = colorEnv;
    text = builtins.readFile ./scripts/polybar-backlight.sh;
  };
  backlightScript = lib.getExe backlightScriptPkg;

  stalonetrayToggleScriptPkg = pkgs.writeShellApplication {
    name = "stalonetray-toggle";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.procps
      pkgs.stalonetray
      pkgs.xdotool
    ];
    text = builtins.readFile ./scripts/stalonetray-toggle.sh;
  };
  stalonetrayToggleScript = lib.getExe stalonetrayToggleScriptPkg;

  polybarLaunchScriptPkg = pkgs.writeShellApplication {
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

  notificationStatusScriptPkg = pkgs.writeShellApplication {
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

  notificationToggleDndScriptPkg = pkgs.writeShellApplication {
    name = "polybar-notifications-dnd";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.systemd
    ];
    text = builtins.readFile ./scripts/polybar-notifications-dnd.sh;
  };
  notificationToggleDndScript = lib.getExe notificationToggleDndScriptPkg;

  rofiNotificationMenuPkg = pkgs.writeShellApplication {
    name = "rofi-notifications";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.procps
      pkgs.rofi
      pkgs.systemd
    ];
    text = builtins.readFile ./scripts/rofi-notifications.sh;
  };
  rofiNotificationMenu = lib.getExe rofiNotificationMenuPkg;

}
