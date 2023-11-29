{ config, lib, pkgs, ... }:
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

  targets.genericLinux.enable = true;
  home = {
    packages = with pkgs; [
      util-linux
      clonegit
    ];
  };
}
