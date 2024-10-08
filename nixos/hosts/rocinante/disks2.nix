{ ... }:
let
  #defaultXfsOpts = [ "defaults" "relatime" "nodiratime" ];
  defaultExt4Opts = [ "defaults" "noatime" "nodiratime" "commit=60" ];
in
{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_120_GB_181102802196";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0";
              end = "1M";
              part-type = "primary";
              flags = [ "bios_grub" ];
            }
            {
              name = "ESP";
              start = "1MiB";
              end = "512MiB";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "nixsystem";
              start = "512MiB";
              end = "-6GiB";
              content = {
                format = "ext4";
                type = "filesystem";
                mountpoint = "/";
                mountOptions = defaultExt4Opts;
              };
            }
            {
              name = "nixswap";
              start = "-6GiB";
              end = "100%";
              fs-type = "linux-swap";
              content = {
                type = "swap";
              };
            }
            # {
            #   name = "root";
            #   start = "512MiB";
            #   end = "100%";
            #   content = {
            #     type = "btrfs";
            #     extraArgs = [ "-f" ];
            #     subvolumes = {
            #       "/rootfs" = {
            #         mountpoint = "/";
            #       };
            #       # Mountpoints inferred from subvolume name
            #       "/home" = {
            #         mountOptions = [ "compress=zstd" ];
            #       };
            #       "/nix" = {
            #         mountOptions = [
            #           "compress=zstd"
            #           "noatime"
            #         ];
            #       };
            #       # "/persist" = {
            #       #   mountOptions = [
            #       #     "compress=zstd"
            #       #     "noatime"
            #       #   ];
            #       # };
            #     };
            #   };
            # }
          ];
        };
      };
    };
  };
  # nodev = {
  #   "/tmp" = {
  #     fsType = "tmpfs";
  #     mountOptions = [
  #       "defaults"
  #       "size=4G"
  #       "mode=755"
  #     ];
  #   };
  # };
}
