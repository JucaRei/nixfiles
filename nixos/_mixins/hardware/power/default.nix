{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.hardware.power;
in
{
  options.hardware.power = {
    enable = mkOption {
      type = bool;
      default = false;
      description = mdDoc "Whether or not to enable support for extra power devices.";
    };
  };

  config = mkIf cfg.enable {
    services.upower = {
      enable = true;
      percentageAction = 5;
      percentageCritical = 10;
      percentageLow = 25;
    };
  };
}
