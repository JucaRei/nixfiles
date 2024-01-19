{ pkgs, lib, ... }:
# let
#   pulseaudio-control = "${pkgs.callPackage ../../../../config/polybar-scripts/pulseaudio-control.nix { } }/bin/pulseaudio-control";
# in
{
  imports = [
    ../default/polybar/scripts.nix
  ];
  services = {
    polybar = {
      enable = true;
      package = pkgs.unstable.polybarFull;
      script = "";
    };
  };
  home = {
    file = {
      # ".config/polybar".source = builtins.path {
      #   path = ../../../../config/polybar-everforest;
      # };
      # link the configuration file in current directory to the specified location in home directory
      ".config/polybar" = {
        source = ../../../../config/polybar/everforest;
        recursive = true;
      };
    };
  };
}
