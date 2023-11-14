{ lib, ... }: {
  services = {
    tlp = lib.mkForce {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

        # This enables tlp and sets the minimum and maximum frequencies
        # for the cpu based on whether it is plugged into power or not. It also
        # changes the cpu scaling governor based on this.
      };
    };
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
        # power management is auto-cpufreq which aims to replace tlp.
        # When using auto-cpufreq it is therefore recommended to disable tlp as
        # these tools are conflicting with each other. However, NixOS does allow
        # for using both at the same time, and you therefore run them in tandem at your own risk.
      };
    };
  };

}
