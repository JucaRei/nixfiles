{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.services.snapcraft;
in
{
  options = {
    system.services.snapcraft = {
      enable = mkEnableOption "Whether enables snap daemon.";
    };
  };
  config = mkIf cfg.enable {
    services.snap.enable = true;
  };
}
