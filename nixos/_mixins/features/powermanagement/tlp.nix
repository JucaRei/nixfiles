{ config, lib, pkgs, ... }:

let
  cfg = config.features.powerManagement;
  MHz = x: x * 1000;
in
with lib;
{
  config = mkIf (cfg.powerProfiles == "tlp") {
    services = {
      auto-cpufreq.enable = mkForce false;
      power-profiles-daemon.enable = mkForce false;
      tlp = {
        enable = mkDefault true;
        settings = {
          TLP_ENABLE = 1;
          TLP_DEFAULT_MODE = "BAT";

          SOUND_POWER_SAVE_ON_AC = 10;
          SOUND_POWER_SAVE_ON_BAT = 10;

          #SOUND_POWER_SAVE_CONTROLLER = "Y";

          START_CHARGE_THRESH_BAT0 = 80;
          STOP_CHARGE_THRESH_BAT0 = 95;

          RESTORE_THRESHOLDS_ON_BAT = 1;

          # battery care drivers
          #NATACPI_ENABLE = 1;
          TPACPI_ENABLE = 1;
          TPSMAPI_ENABLE = 1;

          #DISK_DEVICES = "nvme0n1 mmcblk0";

          #DISK_APM_LEVEL_ON_AC = "254 254";
          #DISK_APM_LEVEL_ON_BAT = "128 128";

          #DISK_IDLE_SECS_ON_AC=0;
          DISK_IDLE_SECS_ON_BAT = 2;

          #RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
          RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

          #RADEON_DPM_STATE_ON_AC = "performance";
          #RADEON_DPM_STATE_ON_BAT = "battery";

          RADEON_POWER_PROFILE_ON_AC = "high";
          RADEON_POWER_PROFILE_ON_BAT = "low";

          #NMI_WATCHDOG = 0;

          #WIFI_PWR_ON_AC = "off";
          #WIFI_PWR_ON_BAT = "on";

          #WOL_DISABLE = "Y";

          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          # <https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html>
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_DRIVER_OPMODE_ON_AC = "active";
          CPU_DRIVER_OPMODE_ON_BAT = "active";

          #CPU_SCALING_MIN_FREQ_ON_AC = MHz 1400;
          #CPU_SCALING_MAX_FREQ_ON_AC = MHz 1700;
          #CPU_SCALING_MIN_FREQ_ON_BAT = MHz 1400;
          #CPU_SCALING_MAX_FREQ_ON_BAT = MHz 1600;

          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          #SCHED_POWERSAVE_ON_AC = 0;
          #SCHED_POWERSAVE_ON_BAT = 1;

          #RESTORE_DEVICE_STATE_ON_STARTUP = 0;

          DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";
          DEVICES_TO_ENABLE_ON_STARTUP = "wifi";

          #DEVICES_TO_DISABLE_ON_SHUTDOWN = "bluetooth wifi wwan";
          #DEVICES_TO_ENABLE_ON_SHUTDOWN = "bluetooth wifi wwan";

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
          #DEVICES_TO_DISABLE_ON_DOCK = "";

          DEVICES_TO_ENABLE_ON_UNDOCK = "";
          DEVICES_TO_DISABLE_ON_UNDOCK = "bluetooth";

          #RUNTIME_PM_ON_AC = "on";
          #RUNTIME_PM_ON_BAT = "auto";

          #RUNTIME_PM_DENYLIST = "11:22.3 44:55.6";
          RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon psmouse";

          #RUNTIME_PM_ENABLE="11:22.3";
          #RUNTIME_PM_DISABLE="44:55.6";

          #PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";

          #USB_AUTOSUSPEND = 1;
          #USB_DENYLIST = "1111:2222 3333:4444";
          #USB_EXCLUDE_AUDIO = 1;
          #USB_EXCLUDE_BTUSB = 1;
          #USB_EXCLUDE_PHONE = 1;
          #USB_EXCLUDE_PRINTER = 1;
          #USB_EXCLUDE_WWAN = 0;
          #USB_ALLOWLIST="5555:6666 7777:8888";
          #USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 0;
        };
      };

      udev.extraRules = ''
        SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.tlp}/bin/tlp ac"
        SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.tlp}/bin/tlp bat"
      '';
    };
  };
}
