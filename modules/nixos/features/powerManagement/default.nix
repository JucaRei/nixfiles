{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
in
{
  imports = [
    ./autocpufreq.nix
    ./battery.nix
    ./cpu.nix
    ./tlp.nix
    ./undervolt.nix
  ];

  options.features.powerManagement = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enables power management.";
    };

    powerProfiles = mkOption {
      type = types.enum [
        "auto-cpufreq"
        "tlp"
        "power-profiles-daemon"
      ];
      default = "power-profiles-daemon";
      description = "Enables power profile manager for selected device.";
    };

    undervolt = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables undervolting support for intel CPUs";
      };
    };
  };

  config = {
    # Disable USB autosuspend on desktop always on power workstations
    boot.kernelParams = mkIf
      (config.features.powerManagement.powerProfiles == "tlp" || config.features.powerManagement.powerProfiles == "auto-cpufreq") [
      "usbcore.autosuspend=-1"
    ];

    # Disable hiberate, hybrid-sleep and suspend-then-hibernate when zram swap is enabled.
    systemd = {
      targets = {
        hibernate.enable = !config.zramSwap.enable;
        hybrid-sleep.enable = !config.zramSwap.enable;
        suspend-then-hibernate.enable = !config.zramSwap.enable;
      };
    };
  };
}
