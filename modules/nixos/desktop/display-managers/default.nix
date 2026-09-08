{ config, lib, ... }:
let
  inherit (lib) mkOption mkDefault;
  inherit (lib.types) enum nullOr;
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
      type = nullOr (enum [
        "lightdm"
        "sddm"
        "regreet"
        "gdm"
      ]);
      default = null;
      description = "The selected display-manager for your desktop environment.";
    };
  };

  config = {
    desktop.display-managers.lightdm.enable = mkDefault (cfg.name == "lightdm");
    desktop.display-managers.sddm.enable = mkDefault (cfg.name == "sddm");
    desktop.display-managers.regreet.enable = mkDefault (cfg.name == "regreet");
    desktop.display-managers.gdm.enable = mkDefault (cfg.name == "gdm");
  };
}
