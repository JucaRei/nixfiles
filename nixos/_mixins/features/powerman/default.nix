{ config, lib, pkgs, desktop, ... }:

let
  inherit (lib) mkOption mkIf mkDefault types optionals;
  cfg = config.features.powerman;
in
{
  imports = [
    ./tlp.nix
  ];
  options = {
    features.powerman = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = "Enables tools and automatic power management";
      };

      disks-platter = mkOption {
        default = true;
        type = types.bool;
        description = "Enables spin down for platter hard drives";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hdparm # Hard Drive management
      smartmontools # SMART montioring
    ] ++ optionals (desktop != null) [
      nvme-cli
      power-profiles-daemon # dbus power profiles
    ];

    powerManagement = {
      enable = true;
    };

    services = {
      power-profiles-daemon.enable = mkDefault true;
      udev = {
        path = [ pkgs.hdparm ];
        extraRules = ''
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 108 -B 127 /dev/%k"
        '';
      };

      systembus-notify.enable = false;

      smartd = mkIf (desktop != null) {
        enable = true;
        defaults.monitored =
          "-a " # monitor all attributes
          + "-o on " # enable automatic offline data collection
          + "-S on " # enable automatic attribute autosave
          + "-n standby,q " # do not check if disk is in standby, and suppress log message to that effect so as not to cause a write to disk
          + "-s (S/../.././02|L/../0[1-7]/4/02) " # schedule short self-test every day at 2AM, long self-test every months the first thursday at 2AM
          + "-W 4,50,60 "
          # monitor temperature, 4C Diff, 40 Info, 60 Crit
        ;
      };
    };
  };
}
