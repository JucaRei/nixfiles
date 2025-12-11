{ config, lib, ... }:
let
  inherit (lib) optional mkOption mkOptionDefault;
  inherit (lib.types) bool nullOr enum;
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
    desktop.display-manager = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable display manager.";
      };
      chosen = mkOption {
        type = enum [ "lightdm" "sddm" "regreet" "gdm" ];
        default = "lightdm";
        description = "The selected Display Manager for your desktop environment.";
      };
    };
  };
}
