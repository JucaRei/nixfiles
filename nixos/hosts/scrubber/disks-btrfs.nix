_:
let
  # device = "/dev/vda";
  device = "/dev/sda";

  defaultBtrfsOpts = [
    "noatime"
    "nodiratime"
    "nodatacow"
    "ssd"
    "compress-force=zstd:5"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  disko.devices = {
    disk = {
      ${baseNameOf device} = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              end = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" "umask=0077" ];
              };
            };
            root = {
              name = "Nixos";
              end = "-4G";
              content = {
                extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
                type = "btrfs";
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = defaultBtrfsOpts;
                  };
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
                };
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
                # randomEncryption = true;
                resumeDevice = false; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };


}

# sudo mkswap /dev/vda3
# sudo swapon /dev/vda3
# sudo mount -o remount,size=20G /
