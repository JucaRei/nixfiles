{ disks ? [ "/dev/mmcblk0" ], ... }:
let
  defaultF2FS = [
    "noatime"
    "nodiratime"
    "compress_algorithm=zstd:6"
    "compress_chksum"
    "atgc"
    "gc_merge"
    "lazytime"
    "nodiscard"
    "background_gc=on"
    # "inline_xattr"
    "inline_data"
    "inline_dentry"
    "flush_merge"
    # "extent_cache"
    # "checkpoint_merge"
    # "compress_cache"
  ];
in
{
  # required by impermanence
  # fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    disk = {
      mmcblk0 = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0%";
              end = "1M";
              flags = [ "bios_grub" ];
            }
            {
              name = "ESP";
              start = "1M";
              end = "550MiB";
              bootable = true;
              flags = [ "esp" ];
              fs-type = "fat32";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "root";
              start = "550MiB";
              end = "-6GiB";
              content = {
                type = "filesystem";
                # Overwirte the existing filesystem
                extraArgs = [
                  "-f"
                  # "-O"
                  # "encrypt,extra_attr,inode_checksum,flexible_inline_xattr,inode_crtime,lost_found,sb_checksum,compression"
                ];
                format = "f2fs";
                mountpoint = "/";
                mountOptions = defaultF2FS;
              };
            }
            {
              name = "swap";
              start = "-6GiB";
              end = "100%";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            }
          ];
        };
      };
    };
  };
}
