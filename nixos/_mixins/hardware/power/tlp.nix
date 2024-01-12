{ lib, pkgs, ... }: {
  services = {
    # Enable TLP for better power management with Schedutil governor
    tlp = lib.mkForce {
      enable = true;
      settings = {
        TLP_ENABLE = 1;
        TLP_DEFAULT_MODE = "BAT";
        AHCI_RUNTIME_PM_ON_BAT = "auto";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_ENERGY_PERF_POLICY_ON_AC = "ondemand";
        # CPU_ENERGY_PERF_POLICY_ON_BAT = "ondemand";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_MAX_PERF_ON_AC = 90;
        CPU_MAX_PERF_ON_BAT = 75;
        CPU_MIN_PERF_ON_BAT = 60;
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil"; # Adjust as needed
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; # Adjust as needed
        NATACPI_ENABLE = 1;
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "on";
        SCHED_POWERSAVE_ON_BAT = 1;
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 1;
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
        TPACPI_ENABLE = 1;
        TPSMAPI_ENABLE = 1;
        WOL_DISABLE = "Y";

        START_CHARGE_THRESH_BAT0 = 80;
        STOP_CHARGE_THRESH_BAT0 = 95;

        # Restores radio device state (builtin Bluetooth, Wi-Fi, WWAN) from previous shutdown on boot.
        # RESTORE_DEVICE_STATE_ON_STARTUP = 0;

        DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";
        DEVICES_TO_ENABLE_ON_STARTUP = "wifi";

        # has precedence
        DEVICES_TO_ENABLE_ON_AC = "";
        DEVICES_TO_DISABLE_ON_BAT = "";

        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wwan";

        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wwan";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";

        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi";
        DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT = "";
        DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT = "";

         DEVICES_TO_ENABLE_ON_DOCK = "wifi bluetooth";
        # DEVICES_TO_DISABLE_ON_DOCK = "";

        DEVICES_TO_ENABLE_ON_UNDOCK = "";
        DEVICES_TO_DISABLE_ON_UNDOCK = "bluetooth";

        # RUNTIME_PM_DENYLIST = "11:22.3 44:55.6";
        RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon psmouse";

        # PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        # Restores radio device state (builtin Bluetooth, Wi-Fi, WWAN) from previous shutdown on boot.
        # RESTORE_DEVICE_STATE_ON_STARTUP = 0;

        # DEVICES_TO_DISABLE_ON_SHUTDOWN = "bluetooth wifi wwan";
        # DEVICES_TO_ENABLE_ON_SHUTDOWN = "bluetooth wifi wwan";

        # RUNTIME_PM_ON_AC = "on";
        # RUNTIME_PM_ON_BAT = "auto";

        # USB_AUTOSUSPEND = 1;
        # USB_DENYLIST = "1111:2222 3333:4444";
        # USB_EXCLUDE_AUDIO = 1;
        # USB_EXCLUDE_BTUSB = 1;
        # USB_EXCLUDE_PHONE = 1;
        # USB_EXCLUDE_PRINTER = 1;
        # USB_EXCLUDE_WWAN = 0;
        # USB_ALLOWLIST="5555:6666 7777:8888";
        # USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 0;

        # Timeout (in seconds) for the audio power saving mode (supports Intel HDA, AC97).
        # A value of 1 is recommended for Linux desktop environments with PulseAudio,
        # systems without PulseAudio may require 10. The value 0 disables power save.
        SOUND_POWER_SAVE_ON_AC = 10;
        SOUND_POWER_SAVE_ON_BAT = 10;

        # Prevents bluez from hanging:
        USB_EXCLUDE_BTUSB = 1;
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
