{ device ? throw "Set this to your disk device, e.g. /dev/sda"
, ...
}:
let
  defaultEXT4 = [
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
            swap = {
              name = "SWAP";
              size = "8G";
              content = {
                type = "swap";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            root = {
              name = "nixroot";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "ext4";
              extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = defaultEXT4;
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "subvol=persist" ] ++ defaultEXT4;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "subvol=nix" ] ++ defaultEXT4;
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
