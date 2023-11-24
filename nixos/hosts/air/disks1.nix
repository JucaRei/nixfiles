{
  disko.devices =
    let
      defaultBtrfsOpts = [
        "rw"
        "noatime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "nodatacow"
        "commit=120"
        "autodefrag"
        "discard=async"
      ];
    in
    {
      disk = {
        vdb = {
          type = "disk";
          device = "/dev/disk/by-id/ata-APPLE_SSD_TS064C_61UA30RXK6HK";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot/efi";
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  # Subvolumes must set a mountpoint in order to be mounted,
                  # unless their parent is mounted
                  subvolumes = {
                    # Subvolume name is different from mountpoint
                    "@rootfs" = {
                      mountpoint = "/";
                    };
                    # Subvolume name is the same as the mountpoint
                    "@home" = {
                      mountOptions = defaultBtrfsOpts;
                      mountpoint = "/home";
                    };
                    # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
                    "/home/user" = { };
                    # Parent is not mounted so the mountpoint must be set
                    "@nix" = {
                      mountOptions = defaultBtrfsOpts;
                      mountpoint = "/nix";
                    };
                    "@tmp" = {
                      mountOptions = defaultBtrfsOpts;
                      mountpoint = "/var/tmp";
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = defaultBtrfsOpts;
                    };
                    # This subvolume will be created but not mounted
                    "/test" = { };
                    # Subvolume for the swapfile
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap = {
                        swapfile.size = "3G";
                        swapfile2.size = "3G";
                        swapfile2.path = "rel-path";
                      };
                    };
                  };

                  mountpoint = "/.swapvol";
                  swap = {
                    swapfile = {
                      size = "3G";
                    };
                    swapfile1 = {
                      size = "3G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
