{ pkgs, lib, config, isWorkstation, isInstall, desktop, ... }:
let
  inherit (lib) mkEnableOption mkIf optionals;
  cfg = config.core.optimizations;
in
{
  options.core.optimizations = {
    enable = mkEnableOption "Enable optimizations module.";
  };

  config = mkIf cfg.enable
    {
      environment = {
        systemPackages = with pkgs;[
          hdparm # Hard Drive management
          smartmontools # SMART montioring
        ] ++ optionals (desktop != null) [
          nvme-cli
          # power-profiles-daemon # dbus power profiles
        ];
      };

      services = {
        # https://dataswamp.org/~solene/2022-09-28-earlyoom.html
        # avoid the linux kernel from locking itself when we're putting too much strain on the memory
        # this helps avoid having to shut down forcefully when we OOM
        earlyoom = {
          enable = isInstall && isWorkstation;
          enableNotifications = false; # true; # annoying, but we want to know what's killed
          freeSwapThreshold = 2;
          freeMemThreshold = 2;
          extraArgs = [
            "-g"
            "--avoid 'Hyprland|soffice|soffice.bin|firefox)$'" # things we want to not kill
            "--prefer '^(electron|.*.exe)$'" # I wish we could kill electron permanently
          ];

          # we should ideally write the logs into a designated log file; or even better, to the journal
          # for now we can hope this echo sends the log to somewhere we can observe later
          killHook = pkgs.writeShellScript "earlyoom-kill-hook" ''
            echo "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed"
          '';
        };


        # Auto Nice Daemon
        ananicy = {
          enable = isInstall;
          package = pkgs.ananicy-rules-cachyos_git;
          rulesProvider = pkgs.ananicy-rules-cachyos;
        };

        irqbalance = {
          enable = isInstall;
        };

        thermald = {
          enable = if (config.core.cpu.cpuVendor == "intel") then true else false;
        };

        psd = {
          enable = isInstall && isWorkstation;
          resyncTimer = "10min";
        };

        udev = {
          path = [ pkgs.hdparm ];
          extraRules = ''
            ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 108 -B 127 /dev/%k"
          '';
        };

        smartd = mkIf (desktop != null) {
          enable = isInstall && isWorkstation;
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

      systemd.services = {
        fixSuspend = mkIf (isInstall && isWorkstation) {
          enable = true;
          description = "Fix immediate wakeup on suspend/hibernate";
          unitConfig = {
            Type = "oneshot";
          };
          serviceConfig = {
            User = "root";
            ExecStart = "-${pkgs.bash}/bin/bash -c \"echo GPP0 > /proc/acpi/wakeup\"";
          };
          wantedBy = [ "multi-user.target" ];
        };

        # ananicy-cpp = mkIf config.services.ananicy.enable {
        #   # https://gitlab.com/ananicy-cpp/ananicy-cpp/-/issues/40#note_1986279383
        #   serviceConfig = {
        #     Delegate-cpu = "cpuset io memory pids";
        #     ExecStartPre = "${pkgs.coreutils}/bin/sleep 30";
        #   };
        # };
      };
    };
}
