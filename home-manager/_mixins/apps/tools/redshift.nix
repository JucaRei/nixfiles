{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.custom.apps.redshift;
in
{
  config = mkIf cfg.enable {
    # Only evaluate code if using X11
    services = mkIf config.xsession.enable {
      redshift = {
        enable = true;
        temperature.night = 3000;
        latitude = -23.55052;
        longitude = -46.633308;
      };
    };
  };
}
