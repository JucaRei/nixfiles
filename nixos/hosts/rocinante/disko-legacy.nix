_:
let
  defaultBtrfsOpts = [
    "noatime"
    "nodiratime"
    "ssd"
    "compress-force=zstd:2"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "swap";
              part-type = "primary";
              fs-type = "linux-swap";
              start = "1M";
              end = "6G";
              content = {
                type = "swap";
                extraArgs = [
                  "-L"
                  "swap"
                ];
                priority = 10;
              };
            }
            {
              name = "NixOS";
              part-type = "primary";
              fs-type = "btrfs";
              start = "6G";
              end = "100%";
              bootable = true;
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "NixOS"
                  "-f"
                ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@var_log" = {
                    mountpoint = "/var/log";
                    mountOptions = defaultBtrfsOpts;
                  };
                };
              };
            }
          ];
        };
      };
    };
  };
}
