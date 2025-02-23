{ config, lib, namespace, ... }:
let
  cfg = config.system.zfs;

  inherit (lib) mkEnableOption mkOption mkIf mkDefault;
  inherit (lib.types) listOf str;
in
{
  options.system.zfs = {
    enable = mkEnableOption "ZFS support";

    pools = mkOption {
      type = listOf str [ "rpool" ];
      default = [ "" ];
      description = "The ZFS pools to manage.";
    };
    auto-snapshot = {
      enable = mkEnableOption "ZFS auto snapshotting";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    services.zfs = {
      autoScrub = {
        enable = true;
        pools = cfg.pools;
      };

      autoSnapshot = mkIf cfg.auto-snapshot.enable {
        enable = true;
        flags = "-k -p --utc";
        weekly = mkDefault 3;
        daily = mkDefault 3;
        hourly = mkDefault 0;
        frequent = mkDefault 0;
        monthly = mkDefault 2;
      };
    };
  };
}
