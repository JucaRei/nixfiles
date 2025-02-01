{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.features.powerManagement;

in
{
  config = mkIf (cfg.powerProfiles == "auto-cpufreq") {
    # Power Management strategy:
    # - If a desktop environment is enabled the supports the power-profiles-daemon, then use the power profiles daemon.
    #   - Otherwise, use auto-cpufreq.
    # - If zramSwap is enabled, then disable power management features that conflict with zram.
    # - Always disable TLP and Powertop because they conflict with auto-cpufreq or agressively suspend USB devices
    # - Disable USB autosuspend on desktop workstations
    # - Enable thermald on Intel CPUs
    # - Thinkpads have a battery threshold charging either via the GNOME extension or auto-cpufreq

    programs = {
      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            platform_profile = "low-power";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            platform_profile = "balanced";
            turbo = "auto";
          };
          ### Available only on Lenovo
          # battery = {
          #   enable_thresholds = true;
          #   start_threshold = 15;
          #   stop_threshold = 85;
          # };
        };
      };
    };
  };
}
