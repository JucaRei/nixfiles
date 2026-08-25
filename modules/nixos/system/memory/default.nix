{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
  usezramSwap = builtins.length config.swapDevices == 0;
in
{
  config = {
    # ZRAM Swap Configuration
    zramSwap = {
      algorithm = mkDefault "zstd";
      enable = mkDefault usezramSwap;
      memoryPercent = mkDefault 100;
    };

    # Kernel vm.page-cluster optimization for ZRAM
    boot.kernel.sysctl = mkIf usezramSwap {
      "vm.page-cluster" = 1;
    };

    # Multi-Gen LRU (MGLRU) optimization
    systemd.services.mglru = mkIf usezramSwap {
      enable = true;
      wantedBy = [ "basic.target" ];
      script = "${pkgs.uutils-coreutils-noprefix}/bin/echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms";
      serviceConfig = {
        Type = "oneshot";
      };
      unitConfig = {
        ConditionPathExists = "/sys/kernel/mm/lru_gen/enabled";
        Description = "Configure Enable Multi-Gen LRU";
      };
    };
  };
}
