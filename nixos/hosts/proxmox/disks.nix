{ disks ? [ "/dev/vda" ], ... }:
let
  defaultXfsOpts = [ "defaults" "relatime" "nodiratime" ];
in
{
  disko.devices = {
    disk = {
      vda = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          # type = "table";
          format = "gpt";
          partitions = {
            boot = {
              start = "0%";
              end = "1M";
              flags = [ "bios_grub" ];
            };
            esp = {
              start = "1M";
              end = "550MiB";
              bootable = true;
              priority = 1;
              flags = [ "esp" ];
              fs-type = "fat32";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              start = "550MiB";
              end = "100%";
              priority = 2;
              content = {
                type = "filesystem";
                # Overwirte the existing filesystem
                extraArgs = [ "-f" ];
                format = "xfs";
                mountpoint = "/";
                mountOptions = defaultXfsOpts;
              };
            };
          };
        };
      };
    };
  };
}
