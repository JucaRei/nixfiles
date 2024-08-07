{ disks ? [ "/dev/vda" ], ... }:
let
  defaultXfsOpts = [ "defaults" "relatime" "nodiratime" ];
in
{
  # disko.devices = {
  #   disk = {
  #     vda = {
  #       type = "disk";
  #       device = builtins.elemAt disks 0;
  #       content = {
  #         format = "gpt";
  #         partitions = {
  #           MBR = {
  #             type = "EF02"; # for grub MBR
  #             size = "1M";
  #             priority = 1; # Needs to be first partition
  #           };
  #           ESP = {
  #             type = "EF00";
  #             size = "500M";
  #             fs-type = "fat32";
  #             content = {
  #               type = "filesystem";
  #               format = "vfat";
  #               mountpoint = "/boot";
  #             };
  #           };
  #           root = {
  #             size = "100%";
  #             type = "8300";
  #             content = {
  #               type = "filesystem";
  #               # Overwirte the existing filesystem
  #               extraArgs = [ "-f" ];
  #               format = "xfs";
  #               mountpoint = "/";
  #               mountOptions = defaultXfsOpts;
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };

  disko.devices = {
    disk = {
      vda = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                extraArgs = [ "-f" ]; # Overwirte the existing filesystem
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
