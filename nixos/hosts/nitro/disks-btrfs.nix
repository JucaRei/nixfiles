{ disks ? [
    "/dev/nvme0n1"
  ]
, ...
}:
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
in
{
  # required by impermanence
  # fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        # device = builtins.elemAt disks 0;
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_500GB_23170F801244";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              # priority = 1;
              name = "ESP";
              label = "ESP";
              # start = "1M";
              start = "0%";
              end = "1024M";
              # size = "1024M";
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
              # size = "100%";
              # start = "1024M";
              end = "-16GiB";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts;
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
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = defaultBtrfsOpts;
                  };
                  # This subvolume will be created but not mounted
                  # "/test" = { };
                  # "@swap" = {
                  #   # mountpoint = "/swap";
                  #   swap = {
                  #     swapfile = {
                  #       size = "8G";
                  #       path = "rel-path";
                  #     };
                  #     swapfile2 = {
                  #       size = "8G";
                  #       path = "rel-path";
                  #     };

                  #   };
                  # };
                  # mountpoint = "/partition-root";
                };
              };
            };
            swap = {
              name = "SWAP";
              # start = "-16GiB";
              # end = "100%";
              size = "100%";
              # part-type = "primary";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };
}

# https://sourcegraph.com/search?q=context:global+-repo:%5Egithub%5C.com/NixOS/nixpkgs%24+-repo:%5Egithub%5C.com/nix-community/home-manager%24+-repo:%5Egithub%5C.com/ceph/ceph%24++-repo:Azure/azure-sdk-for-js+-repo:osbuild+-repo:systemd+-repo:Azure+-repo:knorrie/python-btrfs++-repo:Azure/azure-sdk-for-java+-repo:%5Egithub%5C.com/NetApp/trident%24+-repo:hashicorp/go-azure-sdk+-repo:cblichmann/btrfscue++-repo:NVlabs/intrinsic3d+content:%27subvolumes+%3D+%7B%27&patternType=keyword&sm=0
