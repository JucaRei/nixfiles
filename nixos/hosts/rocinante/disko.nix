_:
let
  defaultBtrfsOpts = [
    "noatime"
    "nodiratime"
    "ssd"
    "compress-force=zstd:2"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "BIOS-BOOT";
              size = "2M";
              type = "EF02";
            };
            ESP = {
              name = "ESP";
              label = "EFI";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                  "noatime"
                  "nodiratime"
                ];
              };
            };
            root = {
              name = "NixOS";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "NixOS" "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@var_log" = {
                    mountpoint = "/var/log";
                    mountOptions = defaultBtrfsOpts;
                  };

                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = defaultBtrfsOpts;
                    swap.swapfile.size = "6G";
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
