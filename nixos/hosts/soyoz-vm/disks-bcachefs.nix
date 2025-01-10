_:
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
      sda = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
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
              name = "root";
              end = "-3GiB"; # "-16GiB";
              content = {
                type = "filesystem";
                format = "bcachefs";
                mountpoint = "/";
                # extraArgs = bcachefs_opts;
                extraArgs = [
                  "--compression=zstd:3"
                  "--background_compression=zstd"
                  # "--block_size=4096" # 4kb block size.
                  "--discard"
                  "--label=vda.vm"
                ];
                mountOptions = [
                  "compression=zstd:3"
                  "noatime"
                  # "very_degraded"
                ];
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
              size = "100%";
              type = "8200";
              # part-type = "primary";
              content = {
                type = "swap";
                # randomEncryption = true;
                # resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };
}

# mount -o remount,size=10G,noatime /nix/.rw-store
