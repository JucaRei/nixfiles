{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dmenu
      slstatus
      xdotool
      wmctrl
      xorg.xsetroot
      xorg.xrandr
      xorg.xrdb
      xorg.xinput
      nitrogen
      feh
      picom
      xclip
      rofi-power-menu
      brightnessctl
      networkmanagerapplet
    ];
  };
}
