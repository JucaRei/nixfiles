_:
# { disks ? [ "/dev/sda" ], ... }:

let
  # "subvol=@"
  options = [ "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
  options2 = [ "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:3" "space_cache=v2" "commit=120" "discard=async" ];
in
{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-APPLE_SSD_TS064C_61UA30RXK6HK";
        # device = "/dev/sda";
        # device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            # ESP = {
            #   priority = 1;
            #   name = "ESP";
            #   # start = "1M";
            #   # end = "650M";
            #   size = "650M";
            #   type = "EF00";
            #   content = {
            #     type = "filesystem";
            #     format = "vfat";
            #     # mountpoint = "/boot";
            #     mountpoint = "/boot/efi";
            #     mountOptions = [ "defaults" "noatime" "nodiratime" ];
            #   };
            # };
            EFI = {
              priority = 1;
              name = "EFI";
              start = "0%";
              end = "1024MiB";
              # bootable = true;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [ "defaults" "noatime" "nodiratime" ];
              };
            };
            root = {
              name = "NixOS";
              end = "-5G";
              content = {
                type = "btrfs";
                # Override existing partition
                extraArgs = [ "-f" ];

                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:3"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                      "x-gvfs-hide"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:3"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:15"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:3"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:15"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                  };
                };
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            # root = {
            #   # size = "100%";
            #   end = "-5G";
            #   content = {
            #     type = "btrfs";
            #     extraArgs = [ "-f" ]; # Override existing partition
            #     # Subvolumes must set a mountpoint in order to be mounted,
            #     # unless their parent is mounted
            #     subvolumes = {
            #       # Subvolume name is different from mountpoint
            #       "@" = {
            #         mountpoint = "/";
            #         mountOptions = [
            #           "subvol=@"
            #           "rw"
            #           "noatime"
            #           "nodiratime"
            #           "ssd"
            #           "nodatacow"
            #           "compress-force=zstd:15"
            #           "space_cache=v2"
            #           "commit=120"
            #           "discard=async"
            #           "x-gvfs-hide" # hide from filemanager
            #         ];
            #       };
            #       # Subvolume name is the same as the mountpoint
            #       "/home" = {
            #         mountOptions = [ "subvol=@home" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:5" "space_cache=v2" "commit=120" "discard=async" ];
            #         mountpoint = "/home";
            #       };
            #       # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
            #       # "/home/user" = { };
            #       # Parent is not mounted so the mountpoint must be set
            #       "@nix" = {
            #         mountOptions = [ "subvol=@nix" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
            #         mountpoint = "/nix";
            #       };
            #       "@tmp" = {
            #         mountOptions = [ "subvol=@tmp" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:5" "space_cache=v2" "commit=120" "discard=async" ];
            #         mountpoint = "/tmp";
            #       };
            #       "@snapshots" = {
            #         mountOptions = [ "subvol=@snapshots" "rw" "noatime" "nodiratime" "ssd" "nodatacow" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
            #         mountpoint = "/.snapshots";
            #       };
            #       "@swap" = {
            #         mountpoint = "/swapvol";
            #         mountOptions = [ "subvol=@swap" "noatime" "defaults" ];
            #         swap.swapfile.size = "5G";
            #       };
            #       # This subvolume will be created but not mounted
            #       # "/test" = { };
            #       # Subvolume for the swapfile
            #       # "/swap" = {
            #       #   mountpoint = "/.swapvol";
            #       #   swap = {
            #       #     swapfile.size = "3G";
            #       #     swapfile2.size = "2G";
            #       #     swapfile2.path = "rel-path";
            #       #   };
            #       # };
            #     };
            #   };
            # };
            # SWAPNIX = {
            #   # start = "512MiB";
            #   # end = "6GiB";
            #   size = "100%";
            #   # size = "6GiB";
            #   content = {
            #     type = "swap";
            #     randomEncryption = false;
            #     resumeDevice = true;
            #   };
            # };
          };
        };
      };
    };
  };
}
