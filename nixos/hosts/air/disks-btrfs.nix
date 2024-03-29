_: let
  # "subvol=@"
  options = [
    "rw"
    "noatime"
    "nodiratime"
    "ssd"
    "nodatacow"
    "compress-force=zstd:15"
    "space_cache=v2"
    "commit=120"
    "discard=async"
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
            # boot = {
            #   size = "1M";
            #   type = "EF02"; # for grub MBR
            # };
            ESP = {
              priority = 1;
              # name = "boot";
              start = "0";
              end = "512MiB";
              # size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = ["defaults" "noatime" "nodiratime"];
              };
            };
            # swap = {
            #   start = "512MiB";
            #   end = "6GiB";
            #   # size = "6G";
            #   # size = "100%";
            #   content = {
            #     type = "swap";
            #     randomEncryption = true;
            #     resumeDevice = true;
            #     # mountOptions = [ "defaults" "noatime" ];
            #   };
            # };
            root = {
              size = "100%";
              # size = "-5GiB";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Override existing partition
                # extraArgs = [ "-L" "NIXOS" "-f" ];
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                # postCreateHook = ''
                #   mount -t btrfs /dev/disk/by-label/NIXOS /mnt
                #   btrfs subvolume snapshot -r /mnt /mnt/root-blank
                #   umount /mnt
                # '';
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "/" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=@"
                      # "rw"
                      "noatime"
                      "nodiratime"
                      "ssd"
                      # "nodatacow"
                      "compress-force=zstd:15"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                      "x-gvfs-hide" # hide from filemanager
                    ];
                  };
                  # Subvolume name is the same as the mountpoint
                  "/home" = {
                    mountOptions = [
                      "subvol=@home"
                      "rw"
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:5"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                    mountpoint = "/home";
                  };
                  "/.snapshots" = {
                    mountOptions = [
                      "subvol=@snapshots"
                      "rw"
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:15"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                    mountpoint = "/.snapshots";
                  };
                  "/tmp" = {
                    mountOptions = [
                      "subvol=@tmp"
                      "rw"
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:5"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                    mountpoint = "/tmp";
                  };
                  "/nix" = {
                    mountOptions = [
                      "subvol=@nix"
                      # "rw"
                      "noatime"
                      "nodiratime"
                      "ssd"
                      "nodatacow"
                      "compress-force=zstd:15"
                      "space_cache=v2"
                      "commit=120"
                      "discard=async"
                    ];
                    mountpoint = "/nix";
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "5G";
                    mountOptions = ["defaults" "noatime"];
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
