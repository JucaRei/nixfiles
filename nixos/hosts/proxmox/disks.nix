{ disks ? [ "/dev/sda" ], ... }:
let
  defaultXfsOpts = [ "defaults" "relatime" "nodiratime" ];
in
{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        content = {
          type = "table";
          format = "msdos";
          partitions = {
            nixos = {
              start = "1M";
              end = "-4G";
              bootable = true;
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
                mountOptions = defaultXfsOpts;
              };
              encryptedSwap = {
                size = "100%";
                content = {
                  type = "swap";
                  randomEncryption = true;
                  priority = 100; # prefer to encrypt as long as we have space for it
                };
              };
            };
          };
        };
      };
    };
  };
}
