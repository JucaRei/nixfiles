{ pkgs
, desktop
, lib
, ...
}:
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

  environment.systemPackages = [ pkgs.snapper ] ++ lib.optional (builtins.isString desktop) pkgs.snapper-gui;

  services.snapper = {
    snapshotRootOnBoot = true;
    cleanupInterval = "7d";
    snapshotInterval = "weekly"; # "hourly";
    configs = {
      root = {
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        SUBVOLUME = "/";
      };
      # home = {
      #   TIMELINE_CREATE = true;
      #   TIMELINE_CLEANUP = true;
      #   SUBVOLUME = "/home";
      # };
      # nix = {
      #   TIMELINE_CREATE = true;
      #   TIMELINE_CLEANUP = true;
      #   SUBVOLUME = "/nix";
      # };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs"; 
      options = [
        "subvol=@"
        "x-gvfs-hide" # hide from filemanager
      ] ++ BTRFS_OPTS;
    };

    "/home" = {
      device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@home"
      ] ++ BTRFS_OPTS;
    };

    "/.snapshots" = {
      device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@snapshots"
      ] ++ BTRFS_OPTS;
    };

    "/var" = {
      device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
      fsType = "btrfs";
      options = [
        "subvol=@var"
      ] ++ BTRFS_OPTS;
    };


    "/nix" = {
      device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
      ] ++ BTRFS_OPTS;
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
        "defaults"
        "noatime"
        "nodiratime"
        "x-gvfs-hide" # hide from filemanager
      ];
    };

    # "swap" = {
    #   device = "/dev/disk/by-partlabel/disk-nvme0-SWAP";
    #   fstype = "btrfs";
    #   # options = [ "subvol=@swap" ];
    # };

    # "/boot/efi" = {
    #   device = "/dev/disk/by-label/EFI";
    #   # device = "/dev/disk/by-uuid/076D-BEC9";
    #   fsType = "vfat";
    #   options = [
    #     "defaults"
    #     "noatime"
    #     "nodiratime"
    #     "x-gvfs-hide" # hide from filemanager
    #   ];
    #   noCheck = true;
    # };
  };

  swapDevices = [
    {
      # device = "/var/swap/swapfile";
      # device = "/dev/disk/by-label/swap";
      device = "/dev/disk/by-partlabel/disk-nvme0-SWAP";
      # size = "20G";
    }
  ];
}
