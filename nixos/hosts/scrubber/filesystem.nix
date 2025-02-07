_:
let
  BTRFS_OPTS = [
    "noatime"
    "nodiratime"
    "nodatacow"
    "ssd"
    "compress-force=zstd:15"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixsystem";
      fsType = "btrfs";
      options = [
        "subvol=@rootfs"
        "x-gvfs-hide" # hide from filemanager
      ] ++ BTRFS_OPTS;
    };

    "/home" = {
      device = "/dev/disk/by-label/nixsystem";
      fsType = "btrfs";
      options = [
        "subvol=@home"
      ] ++ BTRFS_OPTS;
    };

    "/.snapshots" = {
      device = "/dev/disk/by-label/nixsystem";
      fsType = "btrfs";
      options = [
        "subvol=@snapshots"
      ] ++ BTRFS_OPTS;
    };

    "/var/log" = {
      device = "/dev/disk/by-label/nixsystem";
      fsType = "btrfs";
      options = [
        "subvol=@logs"
      ] ++ BTRFS_OPTS;
    };

    "/var/tmp" = {
      device = "/dev/disk/by-label/nixsystem";
      fsType = "btrfs";
      options = [
        "subvol=@tmp"
      ] ++ BTRFS_OPTS;
    };

    "/nix" = {
      device = "/dev/disk/by-label/nixsystem";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
      ] ++ BTRFS_OPTS;
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
        "defaults"
        "noatime"
        "nodiratime"
        "x-gvfs-hide" # hide from filemanager
      ];
      noCheck = true;
    };
  };

  # swapDevices = [
  #   {
  #     device = "/dev/disk/by-label/swap";
  #   }
  # ];
}
