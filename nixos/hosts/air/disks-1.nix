{disks ? ["/dev/sda"], ...}: {
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-APPLE_SSD_TS064C_61UA30RXK6HK";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
              };
            };
            swap = {
              size = "6G";
              content = {
                type = "swap";
                # randomEncryption = true;
                # resumeDevice = true; # resume from hiberation from this device
              };
            };
            root = {
              size = "100%";
              # end = "-6G";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@rootfs" = {mountpoint = "/";};
                  # Subvolume name is the same as the mountpoint
                  "@home" = {
                    mountOptions = [
                      "rw"
                      "noatime"
                      "ssd"
                      "compress-force=zstd:3"
                      "space_cache=v2"
                      "nodatacow"
                      "commit=120"
                      "autodefrag"
                      "discard=async"
                    ];
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountOptions = [
                      "rw"
                      "noatime"
                      "ssd"
                      "compress-force=zstd:15"
                      "space_cache=v2"
                      "nodatacow"
                      "commit=120"
                      "autodefrag"
                      "discard=async"
                    ];
                    mountpoint = "/nix";
                  };
                  "@tmp" = {
                    mountOptions = [
                      "rw"
                      "noatime"
                      "ssd"
                      "compress-force=zstd:3"
                      "space_cache=v2"
                      "nodatacow"
                      "commit=120"
                      "autodefrag"
                      "discard=async"
                    ];
                    mountpoint = "/var/tmp";
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "rw"
                      "noatime"
                      "ssd"
                      "compress-force=zstd:3"
                      "space_cache=v2"
                      "nodatacow"
                      "commit=120"
                      "autodefrag"
                      "discard=async"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
