{ disks ? [ "/dev/sda" ], ... }:
let
  defaultXfsOpts = [ "defaults" "relatime" "nodiratime" ];
in
{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "nixos";
              start = "1M";
              end = "-4G";
              part-type = "primary";
              bootable = true;
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
                mountOptions = defaultXfsOpts;
              };
            }
            {
              name = "EncSWAP";
              end = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 100; # prefer to encrypt as long as we have space for it
              };
            }
          ];
        };
      };
    };
  };
}
