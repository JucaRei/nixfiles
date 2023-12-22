{ lib, pkgs, ... }: {
  services = {
    # Enable TLP for better power management with Schedutil governor
    tlp = lib.mkForce {
      enable = true;
      settings = {
        AHCI_RUNTIME_PM_ON_BAT = "auto";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_ENERGY_PERF_POLICY_ON_AC = "ondemand";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "ondemand";
        CPU_MAX_PERF_ON_AC = 99;
        CPU_MAX_PERF_ON_BAT = 75;
        CPU_MIN_PERF_ON_BAT = 75;
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil"; # Adjust as needed
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil"; # Adjust as needed
        NATACPI_ENABLE = 1;
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        SCHED_POWERSAVE_ON_BAT = 1;
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 1;
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
        TPACPI_ENABLE = 1;
        TPSMAPI_ENABLE = 1;
        WOL_DISABLE = "Y";
      };
    };

    # Power management & Analyze power consumption on Intel-based laptops
    power-profiles-daemon.enable = lib.mkForce false;
    upower = {
      enable = true;
    };
  };
  powerManagement = {
    # Enable power management (do not disable this unless you have a reason to).
    # Likely to cause problems on laptops and with screen tearing if disabled.
    enable = true;
    powertop = {
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      acpi
      cpufrequtils
      cpupower-gui
      powerstat
      powertop
      tlp
    ];
  };

  # auto-cpufreq = {
  #   enable = false;
  #   settings = {
  #     battery = {
  #       governor = "powersave";
  #       turbo = "never";
  #     };
  #     charger = {
  #       governor = "performance";
  #       turbo = "auto";
  #     };
  #     # power management is auto-cpufreq which aims to replace tlp.
  #     # When using auto-cpufreq it is therefore recommended to disable tlp as
  #     # these tools are conflicting with each other. However, NixOS does allow
  #     # for using both at the same time, and you therefore run them in tandem at your own risk.
  #   };
  # };

  #services.tlp = {
  #  enable = true;
  # writes to /etc/tpl.conf
  #  extraConfig = ''
  #    TLP_DEFAULT_MODE=AC
  #    TLP_PERSISTENT_DEFAULT=0
  #    DISK_IDLE_SECS_ON_AC=0
  #    DISK_IDLE_SECS_ON_BAT=2
  #    MAX_LOST_WORK_SECS_ON_AC=15
  #    MAX_LOST_WORK_SECS_ON_BAT=60
  #    CPU_HWP_ON_AC=balance_performance
  #    CPU_HWP_ON_BAT=balance_power
  #    SCHED_POWERSAVE_ON_AC=0
  #    SCHED_POWERSAVE_ON_BAT=1
  #    NMI_WATCHDOG=0
  #    ENERGY_PERF_POLICY_ON_AC=performance
  #    ENERGY_PERF_POLICY_ON_BAT=power
  #    DISK_DEVICES="sda sdb"
  #    DISK_APM_LEVEL_ON_AC="254 254"
  #    DISK_APM_LEVEL_ON_BAT="128 128"
  #    SATA_LINKPWR_ON_AC="med_power_with_dipm max_performance"
  #    SATA_LINKPWR_ON_BAT="med_power_with_dipm min_power"
  #    PCIE_ASPM_ON_AC=performance
  #    PCIE_ASPM_ON_BAT=powersave
  #    RADEON_POWER_PROFILE_ON_AC=high
  #    RADEON_POWER_PROFILE_ON_BAT=low
  #    RADEON_DPM_STATE_ON_AC=performance
  #    RADEON_DPM_STATE_ON_BAT=battery
  #    RADEON_DPM_PERF_LEVEL_ON_AC=auto
  #    RADEON_DPM_PERF_LEVEL_ON_BAT=auto
  #    WIFI_PWR_ON_AC=off
  #    WIFI_PWR_ON_BAT=on
  #    WOL_DISABLE=Y
  #    SOUND_POWER_SAVE_ON_AC=0
  #    SOUND_POWER_SAVE_ON_BAT=1
  #    SOUND_POWER_SAVE_CONTROLLER=Y
  #    BAY_POWEROFF_ON_AC=0
  #    BAY_POWEROFF_ON_BAT=0
  #    BAY_DEVICE="sr0"
  #    RUNTIME_PM_ON_AC=on
  #    RUNTIME_PM_ON_BAT=auto
  #    USB_AUTOSUSPEND=0
  #    RESTORE_DEVICE_STATE_ON_STARTUP=0
  #  '';
  #};

  #services.acpid.acEventCommands = ''
  #  echo -1 > /sys/module/usbcore/parameters/autosuspend
  #'';

  #environment.systemPackages = [ tpacpi-bat ];

}
