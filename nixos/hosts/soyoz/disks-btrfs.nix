{ disks ? [ "/dev/mmcblk1" ], ... }:
let
  defaultBtrfsOpts = [
    "noatime"
    "nodiratime"
    "nodatacow"
    "ssd"
    "compress-force=zstd:15"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];

  defaultBtrfsOpts2 = [
    "noatime"
    "nodiratime"
    "nodatacow"
    "ssd"
    "compress-force=zstd:3"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  # required by impermanence
  # fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    disk = {
      mmcblk1 = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              label = "ESP";
              start = "0%";
              end = "100M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            root = {
              name = "NixOS";
              end = "-6GiB";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts2;
                  };
                  # Subvolume name is the same as the mountpoint
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = defaultBtrfsOpts;
                  };
                  # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
                  # "@home/user" = { };
                  # Parent is not mounted so the mountpoint must be set
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = defaultBtrfsOpts2;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = defaultBtrfsOpts;
                  };
                };
              };
            };
            swap = {
              name = "SWAP";
              size = "100%";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };
}
