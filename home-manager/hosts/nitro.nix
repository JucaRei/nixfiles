{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../_mixins/console/fish.nix
    ../_mixins/video/mpv.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };

  # home.packages = with pkgs; [
  #   mpv
  # ];
}
