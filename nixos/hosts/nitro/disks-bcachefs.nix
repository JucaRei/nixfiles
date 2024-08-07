{ disks ? [
    "/dev/nvme0n1"
  ]
, ...
}:
let
  bcachefs_opts = [
    "compression=zstd:3"
    "background_compression=zstd:15"
    "block_size=4096" # 4kb block size.
    "discard"
    "bind"
    "relatime"
    "nodiratime"
  ];
in
{
  # required by impermanence
  # fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
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
              name = "root";
              end = "-16GiB";
              content = {
                type = "filesystem";
                format = "bcachefs";
                mountpoint = "/";
                # extraArgs = bcachefs_opts;
                extraArgs = [
                  "--compression zstd"
                  "--background_compression zstd"
                  "--block_size=4096" # 4kb block size.
                  "--discard"
                  "--label nroot"
                ];
                mountOptions = [ "noatime" ];
                # subvolumes = {
                #   # Not implemented
                #   "@home" = { };
                #   "@nix" = { };
                #   "@var" = { };
                #   "@snapshots" = { };
                # };
              };
            };
            swap = {
              name = "SWAP";
              # start = "-16GiB";
              # end = "100%";
              size = "100%";
              type = "8200";
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
