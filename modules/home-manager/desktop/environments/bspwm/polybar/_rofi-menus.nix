{
  pkgs,
  lib,
  writeShellApp,
  bspLayoutSwitchScriptPkg,
}:
rec {
  rofiBluetoothMenuPkg = writeShellApp {
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

  rofiWifiMenuPkg = writeShellApp {
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

  rofiPowerMenuPkg = writeShellApp {
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

  restoreMenuScriptPkg = writeShellApp {
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

  rofiKeyboardMenuPkg = writeShellApp {
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

  rofiLayoutMenuPkg = writeShellApp {
    name = "rofi-bsp-layout";
    runtimeInputs = [
      bspLayoutSwitchScriptPkg
      pkgs.bsp-layout
      pkgs.bspwm
      pkgs.coreutils
      pkgs.dunst
      pkgs.jq
      pkgs.rofi
    ];
    text = builtins.readFile ./scripts/rofi-bsp-layout.sh;
  };
  rofiLayoutMenu = lib.getExe rofiLayoutMenuPkg;

  rofiNotificationMenuPkg = writeShellApp {
    name = "rofi-notifications";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dunst
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
      pkgs.procps
      pkgs.rofi
      pkgs.systemd
    ];
    text = builtins.readFile ./scripts/rofi-notifications.sh;
  };
  rofiNotificationMenu = lib.getExe rofiNotificationMenuPkg;
}
