_:
let
  device = "/dev/vda";
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
                # extraArgs = [ "-f" "--compression=lz4" "--discard" "--encrypted" ];
                extraArgs = [
                  "-f"
                  "--compression=zstd:5"
                  "--discard"
                  # "background_compression zstd"
                  # "--block_size=4096" # 4kb block size.
                ];
                format = "bcachefs";
                mountOptions = [
                  "defaults"
                  "compression=zstd"
                  "discard"
                  "relatime"
                  "nodiratime"
                ];
                type = "filesystem";
                mountpoint = "/";
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
