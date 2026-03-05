{ config, lib, pkgs, useNixGL ? false, ... }:
let
  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);
in
{
  imports = [ ];
  xsession = {
    enable = true;
    windowManager = {
      bspwm = {
        enable = true;
        package = nixGLWrapper pkgs.bspwm;
        startupPrograms = [
          "sxhkd"
          "polybar"
        ];
      };
    };
  };

  home = {
    packages = with pkgs; [
      # Window Manager
      sxhkd

      xorg.xrandr
      xorg.xsetroot

      # Bar
      polybar

      # Terminal
      # alacritty

      # File Manager
      # xfce.thunar

      # Misc
      gnome-keyring
      galculator
    ];
  };

  services = {
    sxhkd = {
      enable = true;
    };
    # polybar = {
    #   enable = true;
    #   package = pkgs.polybar;
    #   config = {
    #     "bar/main" = {
    #       monitor = "DP-1";
    #       width = "100%";
    #       height = "24";
    #       font-0 = "monospace:size=10";
    #     };
    #   };
    # };
  };
}
