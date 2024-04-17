{ pkgs, config, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
in
{
  config = {
    home = {
      packages = with pkgs; [
        wmname
        sxhkd
        xorg.xdpyinfo
        xorg.xkill
        xorg.xrandr
        xorg.xsetroot
        xorg.xwininfo
        xorg.xprop
        xorg.xrandr
        xfce.xfce4-terminal
      ];
    };
    xsession = {
      enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          package = nixgl pkgs.bspwm;
        };
      };
    };
  };
}
