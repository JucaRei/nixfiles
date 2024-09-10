{ config, lib, ... }:
let
  cfg = config.custom.features.monitors;
  inherit (lib) mkOption types;
in
{
  options.custom.features.monitors = {
    laptopMonitors = mkOption {
      description = "List of internal laptop monitors.";
      default = [ ];
      type = types.listOf types.str;
    };
    externalMonitors = mkOption {
      description = "List of external monitors.";
      default = [ ];
      type = types.listOf types.str;
    };
  };
}
