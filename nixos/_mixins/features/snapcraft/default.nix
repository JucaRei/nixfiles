{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.features.snapcraft;
in
{
  options = {
    features.snapcraft = {
      enable = mkEnableOption "Whether enables snap.";
    };
  };
  config = mkIf cfg.enable {
    services.snap.enable = true;
  };
}
