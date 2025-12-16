{ config, lib, pkgs, ... }:
let
  backend = config.desktop.backend;
in
{
  desktop.backend = "x11";
  apps.graphical.file-manager.thunar.enable = true;

  home = {
    packages = with pkgs; [
      gparted
      galculator
    ];
  };

  xfconf.settings = {
    thunar-volman = {
      "autobrowse/enabled" = true;
      "automount-drives/enabled" = true;
      "automount-media/enabled" = true;
      "autorun/enabled" = false;
      "automouse/enabled" = false;
      "autoopen/enabled" = false;
      "autophoto/enabled" = false;
    };
    xfce4-session = { };
    xfce4-panel = { };
    xfce4-power-manager = {
      # 2023-07-29: MUST have leading slashes
      # FIXXME: this section is untested
      "xfce4-power-manager/blank-on-ac" = 0;
      "xfce4-power-manager/brightness-switch" = 1;
      "xfce4-power-manager/brightness-switch-restore-on-exit" = -1;
      "xfce4-power-manager/dpms-enabled" = true;
      "xfce4-power-manager/dpms-on-ac-off" = 0;
      "xfce4-power-manager/dpms-on-ac-sleep" = 0;
      "xfce4-power-manager/lock-screen-suspend-hibernate" = true;
      "xfce4-power-manager/show-tray-icon" = 1;

      "xfce4-power-manager/handle-brightness-keys" = true; # FIXXME: doesn't work on floyd yet
      "xfce4-power-manager/power-button-action" = 3; # Ask
      "xfce4-power-manager/lid-action-on-battery" = 0; # just blank screen
      "xfce4-power-manager/lid-action-on-ac" = 0; # just blank screen
      "xfce4-power-manager/logind-handle-lid-switch" = false;
      "xfce4-power-manager/critical-power-action" = 3; # Ask
    };
    xfce4-notifyd = { };
    xfce4-desktop = { };
    xfce4-settings-manager = { };
    xsettings = {
      "Gtk/ButtonImages" = true;
    };
    xfce4-appfinder = { };
    keyboards = {
      "Default/Numlock" = false;
    };
    xfce4-screenshooter = { };
    xfwm4 = { };
    xfce4-keyboard-shortcuts = {
      # "commands/custom/XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
      # "commands/custom/XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
      # "commands/custom/XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
    };
    displays = { };
  };
  # xfconf-query -l
  # xfconf-query -c xfce-session -v -l
  # xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
}
