{ disks ? [
    "/dev/vda"
  ]
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
    disk.main = {
      vda = {
        type = "disk";
        # device = builtins.elemAt disks 0;
        device = disks;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            ESP = {
              # priority = 1;
              name = "ESP";
              # label = "ESP";
              start = "1M";
              # start = "0%";
              end = "1024M";
              # size = "1024M";
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
            # root = {
            #   name = "nixroot";
            #   # size = "100%";
            #   # start = "1024M";
            #   end = "-4GiB";
            #   content = {
            #     type = "btrfs";
            #     extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
            #     # Subvolumes must set a mountpoint in order to be mounted,
            #     # unless their parent is mounted
            #     subvolumes = {
            #       # Subvolume name is different from mountpoint
            #       "@" = {
            #         mountpoint = "/";
            #         mountOptions = defaultBtrfsOpts;
            #       };
            #       # Subvolume name is the same as the mountpoint
            #       "@home" = {
            #         mountpoint = "/home";
            #         mountOptions = defaultBtrfsOpts;
            #       };
            #       # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
            #       # "@home/user" = { };
            #       # Parent is not mounted so the mountpoint must be set
            #       "@nix" = {
            #         mountpoint = "/nix";
            #         mountOptions = defaultBtrfsOpts;
            #       };
            #       "@var" = {
            #         mountpoint = "/var";
            #         mountOptions = defaultBtrfsOpts;
            #       };
            #       "@snapshots" = {
            #         mountpoint = "/.snapshots";
            #         mountOptions = defaultBtrfsOpts;
            #       };
            #       # This subvolume will be created but not mounted
            #       # "/test" = { };
            #       # "@swap" = {
            #       #   # mountpoint = "/swap";
            #       #   swap = {
            #       #     swapfile = {
            #       #       size = "8G";
            #       #       path = "rel-path";
            #       #     };
            #       #     swapfile2 = {
            #       #       size = "8G";
            #       #       path = "rel-path";
            #       #     };

            #       #   };
            #       # };
            #       # mountpoint = "/partition-root";
            #     };
            #   };
            # };
            root = {
              name = "root";
              size = "-4GiB";
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
            swap = {
              name = "SWAP";
              # start = "-16GiB";
              # end = "100%";
              size = "100%";
              # part-type = "primary";
              content = {
                type = "swap";
                # randomEncryption = true;
                # resumeDevice = true; # resume from hiberation from this device
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
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
              };
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = defaultBtrfsOpts;
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "subvol=persist" ] ++ defaultBtrfsOpts;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "subvol=nix" ] ++ defaultBtrfsOpts;
                };
              };
            };
          };
        };
      };
    };
  };
}
