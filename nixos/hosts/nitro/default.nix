{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkIf mkForce;
in
{
  config = {

    features = {
      graphics = {
        enable = true;
        gpu = "hybrid-nvidia";
      };

      container-manager = {
        enable = true;
        manager = "podman";
      };

      autocpufreq = {
        enable = true;
        autosuspend = false;
      };
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci" # USB 3.0
          "ahci" # SATA devices on modern AHCI controllers
          "nvme"
          "usb_storage" # USB mass storage devices
          "usbhid" # USB human interface devices
          "sd_mod" # SCSI, SATA, and IDE devices
          "rtsx_pci_sdmmc"
          "aesni_intel"
          "cryptd"
        ];
        # systemd.enable = true;
        compressor = "zstd";
        compressorArgs = [ "-19" "-T0" ];
        # verbose = lib.mkForce false;
      };
      kernelPackages = pkgs.linuxPackages_xanmod_stable; #pkgs.linuxPackages_xanmod_latest;
      kernelModules = [
        "z3fold"
        "lz4hc"
        "lz4hc_compress"
      ];
      kernelParams = [
        "zswap.enabled=1"
        "mem_sleep_default=deep"
      ];
      loader = {
        grub = {
          theme = mkForce pkgs.cyberre;
        };
      };
    };

    environment = {
      systemPackages = with pkgs; [
        btdu
        btrfs-progs
        compsize
        cloneit
        gparted
        lm_sensors

        floorp
        vscode-fhs
        nil
        nixpkgs-fmt
        duf
        htop
        neofetch
        unstable.mpv
        spotube
      ];
    };

    services = {

      ### Touchpad
      libinput = {
        enable = true;
        touchpad = {
          accelProfile = "adaptive";
          accelSpeed = "0.6";
          tapping = true;
          scrollMethod = "twofinger";
          disableWhileTyping = true;
          clickMethod = "clickfinger";
          naturalScrolling = true;
          # natural scrolling for touchpad only, not mouse
          additionalOptions = ''
            MatchIsTouchpad "on"
          '';
        };
        mouse = {
          naturalScrolling = false;
          disableWhileTyping = true;
          accelProfile = "adaptive";
          accelSpeed = "0.3";
        };
      };
    };

    hardware = {
      # 555.78 not working with xanmod
      nvidia = {
        package = mkForce (config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "555.58.02";
          sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
          sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
          openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
          settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
          persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
        });

        prime = {
          #     offload.enable = lib.mkForce true;
          #     offload.enableOffloadCmd = lib.mkForce true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
          #     reverseSync.enable = lib.mkForce true;
        };
      };
    };

    systemd = {
      oomd = {
        enable = false;
      };
      services = {
        zswap = {
          description = "Enable ZSwap, set to LZ4 and Z3FOLD";
          enable = true;
          wantedBy = [ "basic.target" ];
          path = [ pkgs.bash ];
          serviceConfig = {
            ExecStart = ''
              ${pkgs.bash}/bin/bash -c 'cd /sys/module/zswap/parameters&& \
                    echo 1 > enabled&& \
                    echo 10 > max_pool_percent&& \
                    echo lz4hc > compressor&& \
                    echo z3fold > zpool'
            '';
            Type = "simple";
          };
        };

        nix-daemon = {
          ### Limit resources used by nix-daemon
          serviceConfig = {
            MemoryMax = "8G";
            MemorySwapMax = "12G";
          };
        };
      };

      sleep.extraConfig = ''
        AllowHibernation=yes
        AllowSuspend=yes
        AllowSuspendThenHibernate=yes
        AllowHybridSleep=yes
      '';
    };

    nixpkgs = {
      hostPlatform = mkDefault "x86_64-linux";
    };

    fileSystems =
      let
        BTRFS_OPTS = [
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
        "/" = {
          device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
          # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
          fsType = "btrfs";
          options = [
            "subvol=@"
            "x-gvfs-hide" # hide from filemanager
          ] ++ BTRFS_OPTS;
        };

        "/home" = {
          device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
          # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
          fsType = "btrfs";
          options = [
            "subvol=@home"
          ] ++ BTRFS_OPTS;
        };

        "/.snapshots" = {
          device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
          # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
          fsType = "btrfs";
          options = [
            "subvol=@snapshots"
          ] ++ BTRFS_OPTS;
        };

        "/var" = {
          device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
          fsType = "btrfs";
          options = [
            "subvol=@var"
          ] ++ BTRFS_OPTS;
        };


        "/nix" = {
          device = "/dev/disk/by-partlabel/disk-nvme0-NixOS";
          # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
          fsType = "btrfs";
          options = [
            "subvol=@nix"
          ] ++ BTRFS_OPTS;
        };

        "/boot" = {
          device = "/dev/disk/by-partlabel/ESP";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
            "defaults"
            "noatime"
            "nodiratime"
            "x-gvfs-hide" # hide from filemanager
          ];
        };

        # "swap" = {
        #   device = "/dev/disk/by-partlabel/disk-nvme0-SWAP";
        #   fstype = "btrfs";
        #   # options = [ "subvol=@swap" ];
        # };

        # "/boot/efi" = {
        #   device = "/dev/disk/by-label/EFI";
        #   # device = "/dev/disk/by-uuid/076D-BEC9";
        #   fsType = "vfat";
        #   options = [
        #     "defaults"
        #     "noatime"
        #     "nodiratime"
        #     "x-gvfs-hide" # hide from filemanager
        #   ];
        #   noCheck = true;
        # };
      };

    swapDevices = [
      {
        # device = "/var/swap/swapfile";
        # device = "/dev/disk/by-label/swap";
        device = "/dev/disk/by-partlabel/disk-nvme0-SWAP";
        # size = "20G";
      }
    ];
  };
}
