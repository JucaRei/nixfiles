{ pkgs, lib, config, isWorkstation, isInstall, isISO, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.core.optimizations;
in
{
  options.core.optimizations = {
    enable = mkEnableOption "Enable optimizations module.";
    selected = mkOption {
      type = types.listOf (types.enum [ "earlyoom" "ananicy" "thermald" "psd" "fixwakeup" ]);
      default = [ ];
      description = "Enables selected optimizations.";
    };
  };

  config = mkIf cfg.enable {
    services = {
      # https://dataswamp.org/~solene/2022-09-28-earlyoom.html
      # avoid the linux kernel from locking itself when we're putting too much strain on the memory
      # this helps avoid having to shut down forcefully when we OOM
      earlyoom = {
        enable = mkIf cfg.selected == "earlyoom";
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
        # chaotic.ananicy-cpp.enable = true;
        enable = mkIf cfg.selected == "ananicy";
        package = pkgs.ananicy-rules-cachyos;
        rulesProvider = pkgs.ananicy-rules-cachyos;
        settings = {
          check_freq = 2;
          cgroup_load = true;
          type_load = true;
          rule_load = true;
          apply_nice = true;
          apply_latnice = true;
          apply_ioclass = true;
          apply_ionice = true;
          apply_sched = true;
          apply_oom_score_adj = true;
          apply_cgroup = true;
          check_disks_schedulers = true;
        };
      };

      irqbalance = {
        enable = mkIf cfg.selected == "irqbalance";
      };

      thermald = {
        enable = mkIf cfg.selected == "thermald";
      };

      psd = {
        enable = mkIf cfg.selected == "psd";
        resyncTimer = "10min";
      };
    };
    systemd.services.fixSuspend = mkIf (cfg.selected == "fixwakeup") {
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
  };
}
