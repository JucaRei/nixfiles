{ config, lib, ... }:

# let
#   powerOptions = config.features.powerManagement;
# in
with lib;

{
  # config = mkIf (lib.strings.equals powerOptions "auto-cpufreq" OR lib.strings.equals powerOptions "power-profiles-daemon") {
  config = mkIf (config.features.powerManagement.enable) {
    services = {
      upower = {
        enable = mkDefault true;
        percentageLow = mkDefault 15;
        percentageCritical = mkDefault 5;
        percentageAction = mkDefault 2;
        criticalPowerAction = mkDefault "Hibernate";
      };
    };
  };
}
