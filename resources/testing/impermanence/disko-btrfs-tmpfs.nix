{ device ? throw "Set this to your disk device, e.g. /dev/sda"
, ...
}:
{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        # "size=32G"

        # set mode to 755, otherwise systemd will set it to 777, which cause problems.
        # relatime: Update inode access times relative to modify or change time.
        "mode=755"
      ];
    };

    disk.main = {
      type = "disk";
      # When using disko-install, we will overwrite this value from the commandline
      # device = "/dev/nvme0n1"; # The device to partition
      inherit device; # The device to partition
      content = {
        type = "gpt";
        partitions = {
          # The EFI & Boot partition
          ESP = {
            priority = 1;
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
              ];
            };
          };

          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "encrypted";
              settings = {
                allowDiscards = true;
              };
              # encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
              # cryptsetup luksFormat
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--iter-time 5000"
                "--key-size 256"
                "--pbkdf argon2id"
                # use true random data from /dev/random, will block until enough entropy is available
                "--use-random"
              ];
              extraOpenArgs = [
                "--timeout 10"
              ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  nix = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  persist = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  log = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  tmp = {
                    mountpoint = "/tmp";
                    mountOptions = [ "noatime" ];
                  };
                  swap = {
                    mountpoint = "/swap";
                    mountOptions = [ "noatime" ];
                    swap.swapfile.size = "8G";
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
