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

  BTRFS_OPTS2 = [
    "noatime"
    "nodiratime"
    "nodatacow"
    "ssd"
    "compress-force=zstd:6"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      # device = "/dev/disk/by-uuid/a4a7e1b9-0730-4eec-9ead-e8c9e4355085";
      fsType = "btrfs";
      options = [
        "subvol=@root"
        "x-gvfs-hide" # hide from filemanager
      ] ++ BTRFS_OPTS2;
    };

    "/home" = {
      device = "/dev/disk/by-label/nixos";
      # device = "/dev/disk/by-uuid/a4a7e1b9-0730-4eec-9ead-e8c9e4355085";
      fsType = "btrfs";
      options = [
        "subvol=@home"
      ] ++ BTRFS_OPTS;
    };

    "/var/snapshots" = {
      device = "/dev/disk/by-label/nixos";
      # device = "/dev/disk/by-uuid/a4a7e1b9-0730-4eec-9ead-e8c9e4355085";
      fsType = "btrfs";
      options = [
        "subvol=@snapshots"
      ] ++ BTRFS_OPTS;
    };

    "/var/log" = {
      device = "/dev/disk/by-label/nixos";
      # device = "/dev/disk/by-uuid/a4a7e1b9-0730-4eec-9ead-e8c9e4355085";
      fsType = "btrfs";
      options = [
        "subvol=@log"
      ] ++ BTRFS_OPTS2;
    };

    "/var/tmp" = {
      device = "/dev/disk/by-label/nixos";
      # device = "/dev/disk/by-uuid/a4a7e1b9-0730-4eec-9ead-e8c9e4355085";
      fsType = "btrfs";
      options = [
        "subvol=@tmp"
      ] ++ BTRFS_OPTS2;
    };

    "/nix" = {
      device = "/dev/disk/by-label/nixos";
      # device = "/dev/disk/by-uuid/a4a7e1b9-0730-4eec-9ead-e8c9e4355085";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
      ] ++ BTRFS_OPTS;
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      # device = "/dev/disk/by-uuid/BBF5-D456";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
        "defaults"
        "noatime"
        "nodiratime"
        "x-gvfs-hide" # hide from filemanager
      ];
      # noCheck = true;
    };

    # "/var/swap" = {
    #   # device = "/dev/disk/by-label/nixos";
    #   device = "/dev/disk/by-uuid/62107246-5335-41d1-a94b-076b7baae356";
    #   fstype = "btrfs";
    #   options = [ "noatime" "ssd_spread" "subvol=@swap" ];
    # };
  };

  # swapDevices = [
  #   {
  #     device = "/var/swap/swapfile";
  #     size = 16384;
  #     # device = "/var/swap/swapfile";
  #     # device = "/dev/disk/by-label/swap";
  #     # device = "/dev/disk/by-partlabel/disk-nvme0-SWAP";
  #     # size = "20G";
  #   }
  # ];

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB
  }];
}
