{ disks ? [ "/dev/sda" ], ... }:
let
  defaultXfsOpts = [ "defaults" "relatime" "nodiratime" ];
in
{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP =
              {
                type = "EF00";
                size = "300M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot/efi";
                  mountOptions = [ "defaults" "noatime" "nodiratime" ];
                };
              };
            root = {
              size = "100%";
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
