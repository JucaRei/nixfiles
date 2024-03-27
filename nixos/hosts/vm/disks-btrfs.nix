{ disks ? [ "/dev/vda" ], ... }:
let
  defaultBtrfsOpts = [
    "noatime"
    "nodiratime"
    "ssd"
    "compress-force=zstd:15"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  # environment.etc = {
  #   "crypttab".text = ''
  #     data  /dev/disk/by-partlabel/data  /etc/data.keyfile
  #   '';
  # };

  disko.devices = {
    disk = {
      # 512GB root/boot drive. Configured with:
      # - A FAT32 ESP partition for systemd-boot
      # - Multiple btrfs subvolumes for the installation of nixos
      vda = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "EFI";
              start = "0%";
              end = "512MiB";
              bootable = true;
              fs-type = "fat32";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
              };
            }
            {
              name = "root";
              start = "512MiB";
              end = "100%";
              part-type = "primary";
              content = {
                type = "btrfs";
                # Override existing partition
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@home" = {
                    mountpoint = "/home";
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
                  "@swap" = {
                    mountpoint = "/var/swap";
                    mountOptions = [
                      "defaults"
                      "x-mount.mkdir"
                      "ssd"
                      "noatime"
                      "nodiratime"
                    ];
                  };
                };
              };
            }
          ];
        };
      };
    };
  };
}
