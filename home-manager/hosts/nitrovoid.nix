{ config, lib, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../_mixins/dev/nix.nix
    ../_mixins/dev/nixpkgs.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };
  targets.genericLinux.enable = true;
}
