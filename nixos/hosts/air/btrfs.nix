{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-APPLE_SSD_TS064C_61UA30RXK6HK";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [ "defaults" "noatime" "nodiratime" ];
              };
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
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = [
                    "subvol=@rootfs"
                    "rw"
                    "noatime"
                    "nodiratime"
                    "ssd"
                    "nodatacow"
                    "compress-force=zstd:15"
                    "space_cache=v2"
                    "commit=120"
                    "discard=async"
                    "x-gvfs-hide" # hide from filemanager
                  ];
                };
                # Subvolume name is the same as the mountpoint
                "/home" = {
                  mountOptions = [ "subvol=@home" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:5" "space_cache=v2" "commit=120" "discard=async" ];
                  mountpoint = "/home";
                };
                # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
                "/home/user" = { };
                # Parent is not mounted so the mountpoint must be set
                "/nix" = {
                  mountOptions = [ "subvol=@nix" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
                  mountpoint = "/nix";
                };
                "/tmp" = {
                  mountOptions = [ "subvol=@tmp" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:5" "space_cache=v2" "commit=120" "discard=async" ];
                  mountpoint = "/tmp";
                };
                "/.snapshots" = {
                  mountOptions = [ "subvol=@snapshots" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
                  mountpoint = "/.snapshots";
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

              mountpoint = "/partition-root";
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
