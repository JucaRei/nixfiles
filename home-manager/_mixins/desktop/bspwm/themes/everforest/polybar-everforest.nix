{ pkgs, lib, osConfig, config, ... }:
# let
#   pulseaudio-control = "${pkgs.callPackage ../../../../config/polybar-scripts/pulseaudio-control.nix { } }/bin/pulseaudio-control";
# in
{
  imports = [
    ../default/polybar/scripts.nix
  ];
  config = {
    services = lib.mkIf config.xsession.enable {
      polybar = {
        enable = true;
        package = pkgs.unstable.polybarFull;
        script = "";
      };
    };
    home = {
      packages = pkgs.unstable.polybarFull;
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
  };
}