{ ssdDevice ? "/dev/nvme0n1"
, pkgs
, desktop
, lib
, config
  # , disks ? [
  #     "/dev/nvme0n1"
  #   ]
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

  disko.devices = {
    disk.nvme0 = {
      type = "disk";
      device = ssdDevice;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            # start = "1M";
            start = "0%";
            end = "1024M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              # mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            # size = "100%";
            start = "1024M";
            end = "-16GiB";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                # Subvolume name is different from mountpoint
                "@rootfs" = { mountpoint = "/"; };
                mountOptions = BTRFS_OPTS;
                # Subvolume name is the same as the mountpoint
                "@home" = {
                  mountOptions = BTRFS_OPTS;
                  mountpoint = "/home";
                };
                # Parent is not mounted so the mountpoint must be set
                "@nix" = {
                  mountOptions = BTRFS_OPTS;
                  mountpoint = "/nix";
                };
                "@var" = {
                  mountOptions = BTRFS_OPTS;
                  mountpoing = "/var";
                };
                "@snapshots" = {
                  mountOptions = BTRFS_OPTS;
                  mountpoing = "/.snapshots";
                };
              };
              # mountpoint = "/partition-root";
            };
          };
          swap = {
            start = "-16GiB";
            end = "100%";
            part-type = "primary";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
        };
      };
    };
  };
}
