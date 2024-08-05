_: {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@rootfs"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "nodatacow"
        "commit=120"
        "discard=async"
        "x-gvfs-hide" # hide from filemanager
      ];
    };

    "/home" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/.snapshots" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@snapshots"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "nodatacow"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/var/tmp" = {
      device = "/dev/disk/by-label/Nitroux";
      fsType = "btrfs";
      options = [
        "subvol=@tmp"
        "rw"
        "noatime"
        "nodiratime"
        "nodatacow"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/var/log" = {
      device = "/dev/disk/by-label/Nitroux";
      fsType = "btrfs";
      options = [
        "subvol=@logs"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/var/swap" = {
      device = "/dev/disk/by-label/Nitroux";
      fsType = "btrfs";
      options = [
        "subvol=@swap"
        "defaults"
        "noatime"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/EFI";
      # device = "/dev/disk/by-uuid/076D-BEC9";
      fsType = "vfat";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
        "x-gvfs-hide" # hide from filemanager
      ];
      noCheck = true;
    };
  };

  swapDevices = [
    {
      device = "/var/swap/swapfile";
      # size = "20G";
    }
  ];
}
