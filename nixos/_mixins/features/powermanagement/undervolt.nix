{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkDefault;
  cfg = config.features.powermanagement.undervolt;
  undervolt =
    if (config.core.cpu.vendor == "intel")
    then true
    else false;
in
{
  config = mkIf cfg.enable {
    services = {
      undervolt = {
        enable = mkDefault undervolt;
        package = pkgs.undervolt;
        tempBat = mkDefault 65;
      };
    };
  };
}
