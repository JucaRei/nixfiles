{ desktop, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [ nvme-cli smartmontools ]
    ++ lib.optionals (desktop != null) [ gsmartcontrol ];

  services.smartd = {
    enable = true;
    notifications.mail.enable = false;
    defaults.monitored = "-a " # monitor all attributes
      + "-o on " # enable automatic offline data collection
      + "-S on " # enable automatic attribute autosave
      + "-n standby,q " # do not check if disk is in standby, and suppress log message to that effect so as not to cause a write to disk
      + "-s (S/../.././02|L/../0[1-7]/4/02) " # schedule short self-test every day at 2AM, long self-test every months the first thursday at 2AM
      + "-W 4,50,55 " # monitor temperature, 4C Diff, 35 Info, 55 Crit
    ;
  };
}
