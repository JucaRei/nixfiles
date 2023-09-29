{ config, lib, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../_mixins/console/fish.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };
}
