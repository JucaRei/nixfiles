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
  ];

  options = {
    desktop.display-managers.name = mkOption {
      type = nullOr (enum [ "lightdm" "sddm" "regreet" ]);
      default = mkOptionDefault (if (
        cfg.desktop.environment != "bspwm" || cfg.desktop.environments != "gnome"
      )
      then "sddm" else "lightdm");
    };
  };
}
