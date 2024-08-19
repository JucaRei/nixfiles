{ device ? throw "Set this to your disk device, e.g. /dev/sda"
, ...
}:
let
  defaultBtrfsOpts = [
    "noatime"
    "nodiratime"
    "nodatacow"
    "ssd"
    "compress-force=zstd:15"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ];
in
{
  # required by impermanence
  # fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    disk = {
      main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              start = "0%";
              end = "1M";
              type = "EF02";
            };
            ESP = {
              # priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            # swap = {
            #   name = "SWAP";
            #   size = "4G";
            #   content = {
            #     type = "swap";
            #     resumeDevice = true; # resume from hiberation from this device
            #   };
            # };
            # root = {
            #   name = "nixroot";
            #   size = "100%";
            #   content = {
            #     type = "lvm_pv";
            #     vg = "root_vg";
            #   };
            # };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "luks_lvm_encrypted";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "nix";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      nix = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "8G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          main = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
              subvolumes = {
                # mount the top-level subvolume at /btr_pool
                # it will be used by btrbk to create snapshots
                "/" = {
                  mountpoint = "/btr_pool";
                  # btrfs's top-level subvolume, internally has an id 5
                  # we can access all other subvolumes from this subvolume.
                  mountOptions = [ "subvolid=5" ] ++ defaultBtrfsOpts;
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = defaultBtrfsOpts;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = defaultBtrfsOpts;
                };
                "@tmp" = {
                  mountpoint = "/tmp";
                  mountOptions = defaultBtrfsOpts;
                };
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = defaultBtrfsOpts;
                };
                "@swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "8192M";
                };
              };
            };
          };
        };
      };
    };
  };
}

# sudo nix --experimental-features "nix-command flakes" \
# run github:nix-community/disko -- \
# --mode disko /tmp/disko.nix \
# --arg device '"/dev/vda"'

# sudo nix run github:nix-community/disko \
#     --extra-experimental-features "nix-command flakes" \
#     --no-write-lock-file \
#     -- \
#     --mode zap_create_mount \
#     "nixos/hosts/vm/impermanance-btrfs.nix" --show-trace

# sudo nixos-generate-config \
#   --no-filesystems --root /mnt

# sudo umount -Rv /mnt
# sudo lvchange -an /dev/root_vg
