# { disks ? [ "/dev/sda1" "/dev/sda4" "/dev/sda5" ], ... }:
# { disks ? [ "/dev/sda1" "/dev/sda4" ], ... }:
# { disks ? [ "/dev/sda4" ], ... }:
{ disks ? [ "/dev/sda" ], ... }:
let
  memory = "4G";
  defaultBtrfsOpts = [
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
in
{
  disko.devices = {
    disk = {
      ### Dual boot mac, dont format mac EFI
      #sda1 = {
      #  type = "disk";
      #  device = builtins.elemAt disks 0;
      #  content = {
      #    type = "gpt";
      #    partitions = [{
      #      priority = 1;
      #      name = "ESP";
      #      start = "0";
      #      end = "100%";
      #      bootable = true;
      #      flags = [ "esp" ];
      #      #fs-type = "fat32";
      #      content = {
      #        type = "filesystem";
      #        format = "vfat";
      #        mountpoint = "/boot";
      #        mountOptions = [ "defaults" "noatime" "nodiratime" ];
      #      };
      #    }];
      #  };
      #};
      #sda4 = {
      #  type = "disk";
      #  device = builtins.elemAt disks 1;
      #  size = "100%";
      #  content = {
      #    type = "table";
      #    format = "gpt";
      #    partitions = {
      #      name = "swap";
      #      start = "0";
      #      end = "100%";
      #      party-type = "primary";
      #      content = {
      #        type = "swap";
      #        randomEncryption = true;
      #      };
      #    };
      #  };
      #};
      sda = {
        type = "disk";
        device = builtins.elemAt disks 0;
        # size = "100%";
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
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@rootfs" = {
                    mountpoint = "/";
                    #mountOptions = defaultBtrfsOpts;
                  };
                  # Mountpoints inferred from subvolume name
                  "@home" = {
                    mountOptions = defaultBtrfsOpts;
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountOptions = defaultBtrfsOpts;
                    mountpoint = "/nix";
                  };
                  "@snaphots" = {
                    mountOptions = defaultBtrfsOpts;
                    mountpoint = "/.snashots";
                  };
                  "@tmp" = {
                    mountOptions = defaultBtrfsOpts;
                    mountpoint = "/var/tmp";
                  };
                  # "/swap" = {
                  #   mountOptions = [ "noatime" ];
                  #   #mount -t btrfs /dev/mapper/crypted /mnt
                  #   postCreateHook = ''
                  #     btrfs filesystem mkswapfile --size ${memory} /mnt/swap/swapfile
                  #     umount /mnt
                  #   '';
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "3G";
                      swapfile2.size = "3G";
                      swapfile2.path = "rel-path";
                    };
                  };
                };
                mountpoint = "/partition-root";
                swap = {
                  swapfile = {
                    size = "3G";
                  };
                  swapfile1 = {
                    size = "3G";
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
