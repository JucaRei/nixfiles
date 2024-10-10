_:
let
  device = "/dev/vda";
in
{
  disko.devices = {
    disk = {
      ${baseNameOf device} = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              end = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" "umask=0077" ];
              };
            };
            root = {
              name = "Nixos";
              end = "-0";
              content = {
                mountpoint = "/";
                # extraArgs = [ "-f" "--compression=lz4" "--discard" "--encrypted" ];
                extraArgs = [ "-f" "--compression=lz4" "--discard" ];
                mountOptions = [ "defaults" "compression=lz4" "discard" "relatime" "nodiratime" ];
                type = "filesystem";
                format = "bcachefs";
              };
            };
          };
        };
      };
    };
  };
}
