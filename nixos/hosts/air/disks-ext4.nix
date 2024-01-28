_:
let
  defaultsBoot = [ "defaults" "noatime" "nodiratime" ];
  defaultExtOpts = [
    "defaults"
    "data=ordered"
    "commit=60"
    # "barrier=0"
    "errors=remount-ro"
    "discard"
    # "noatime"
    "relatime"
    "nodiratime"
  ];
in {
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-APPLE_SSD_TS064C_61UA30RXK6HK";
        content = {
          type = "gpt";
          partitions = {
            EFIBOOT = {
              start = "0";
              end = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = defaultsBoot;
              };
            };
            NixSystem = {
              # size = "100%";
              end = "-5G";
              content = {
                type = "filesystem";
                # extraArgs = [ "-f" ];
                format = "ext4";
                mountpoint = "/";
                mountOptions = defaultExtOpts;
              };
            };
            SWAPNIX = {
              # start = "512MiB";
              # end = "6GiB";
              size = "100%";
              # size = "6GiB";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
  };
}
