_: let
  defaultsBoot = ["defaults" "noatime" "nodiratime"];
  defaultExtOpts = ["defaults" "data=writeback" "commit=60" "barrier=0" "discard" "noatime" "nodiratime"];
in {
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-APPLE_SSD_TS064C_61UA30RXK6HK";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              start = "0";
              end = "300MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = defaultsBoot;
              };
            };
            swap = {
              start = "300MiB";
              end = "6GiB";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true;
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                extraArgs = ["-f"];
                format = "ext4";
                mountpoint = "/";
                mountOptions = defaultExtOpts;
              };
            };
          };
        };
      };
    };
  };
}
