{ config, lib, ... }:
let
  inherit (lib) optional mkOption mkOptionDefault enum nullOr;
  cfg = config.desktop.display-managers;
in
{
  imports = [
    ./lightdm
    ./sddm
    ./regreet
    ./gdm
  ];

  options = {
    desktop.display-managers.name = mkOption {
      type = nullOr (enum [ "lightdm" "sddm" "regreet" "gdm" ]);
      default = null;
      description = "The selected display-manager for your desktop environment.";
    };
  };
}
