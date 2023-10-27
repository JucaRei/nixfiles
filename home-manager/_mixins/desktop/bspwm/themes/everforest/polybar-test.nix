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
      package = pkgs.polybar;
      script = "";
    };
  };
  home = {
    file = {
      # ".config/polybar".source = builtins.path {
      #   path = ../../../../config/polybar-everforest;
      # };
      ".config/polybar" = {
        source = ../../../../config/polybar-everforest;
      };
    };
  };
}
