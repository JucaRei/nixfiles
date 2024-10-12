{ config, hostname, isInstall, lib, pkgs, ... }:
let
  isIntelCPU = config.hardware.cpu.intel.updateMicrocode;
  usePowerProfiles = config.programs.hyprland.enable
    || config.services.xserver.desktopManager.gnome.enable
    || config.services.xserver.desktopManager.pantheon.enable;
  inherit (lib) mkDefault mkIf mkForce mkOption optionals types;
  cfg = config.features.autocpufreq;

in
{
  options = {
    features.autocpufreq = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enables power management.";
      };
      autosuspend = mkOption {
        type = types.bool;
        default = false;
        description = "Whether disable auto-suspend.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Power Management strategy:
    # - If a desktop environment is enabled the supports the power-profiles-daemon, then use the power profiles daemon.
    #   - Otherwise, use auto-cpufreq.
    # - If zramSwap is enabled, then disable power management features that conflict with zram.
    # - Always disable TLP and Powertop because they conflict with auto-cpufreq or agressively suspend USB devices
    # - Disable USB autosuspend on desktop workstations
    # - Enable thermald on Intel CPUs
    # - Thinkpads have a battery threshold charging either via the GNOME extension or auto-cpufreq

    # Disable USB autosuspend on desktop always on power workstations
    boot.kernelParams = optionals (cfg.autosuspend) [ "usbcore.autosuspend=-1" ];

    powerManagement.powertop.enable = mkDefault false;

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

    services = {
      # Only enable power-profiles-daemon if the desktop environment supports it
      power-profiles-daemon.enable = true;
      # Only enable thermald on Intel CPUs
      # thermald.enable = isIntelCPU;
      # Disable TLP because it conflicts with auto-cpufreq
      tlp.enable = mkForce false;
    };

    # Disable hiberate, hybrid-sleep and suspend-then-hibernate when zram swap is enabled.
    systemd.targets.hibernate.enable = !config.zramSwap.enable;
    systemd.targets.hybrid-sleep.enable = !config.zramSwap.enable;
    systemd.targets.suspend-then-hibernate.enable = !config.zramSwap.enable;
  };
}