# Example to create a bios compatible gpt partition
#{ disks ? [ "/dev/sda" ], ... }:
{...}: let
  #defaultXfsOpts = [ "defaults" "relatime" "nodiratime" ];
  defaultExt4Opts = ["defaults" "noatime" "nodiratime" "commit=60"];
in {
  #device = "/dev/sda";
  #type = "msdos";
  #disko.devices = {
  #  disk = {
  #    vda = {
  #      type = "disk";
  #      device = builtins.elemAt disks 0;
  #      content = {
  #        type = "table";
  #        format = "gpt";
  #        partitions = [{
  #          name = "primary";
  #          start = "0%";
  #          end = "1M";
  #          #type = "EF02"; # for grub MBR
  #          flags = [ "bios_grub" ];
  #        }
  #          {
  #            name = "NIXOS";
  #            start = "1M";
  #            end = "100%";
  #            content = {
  #              type = "filesystem";
  #              # Overwirte the existing filesystem
  #              #extraArgs = [ "-f" ];
  #              format = "ext4";
  #              mountpoint = "/";
  #              mountOptions = defaultExt4Opts;
  #            };
  #          }];
  #      };
  #    };
  #  };
  #};

  #disko.devices = {
  #  disk = {
  #    sda = {
  #      device = "/dev/sda";
  #      type = "disk";
  #      content = {
  #        type = "table";
  #        format = "msdos";
  #        partitions = [
  #          {
  #            name = "NIXOS";
  #            part-type = "primary";
  #            start = "1M";
  #            end = "100%";
  #            bootable = true;
  #            content = {
  #              type = "filesystem";
  #              format = "ext4";
  #              mountpoint = "/";
  #            };
  #          }
  #        ];
  #      };
  #    };
  #  };
  #};
  disko.devices = {
    disk = {
      mmcblk0 = {
        # device = "/dev/mmcblk0";
        device = "/dev/disk/by-id/mmc-SC32G_0x78fe3e2e";
        type = "disk";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "BOOT";
              start = "0%";
              end = "500M";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                extraArgs = ["-n BOOT"];
              };
            }
            {
              name = "root";
              start = "500M";
              end = "100%";
              part-type = "primary";
              bootable = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = defaultExt4Opts;
                extraArgs = ["-L NIXOS-SD"];
              };
            }
          ];
        };
      };
    };
  };
}
