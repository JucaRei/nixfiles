{ pkgs, ... }: {
  # chaotic.ananicy-cpp.enable = true;
  services = {
    # Auto Nice Daemon
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp-rules;
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
  };
}
