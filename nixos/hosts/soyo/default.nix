{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    ../../_mixins/hardware/boot/efi.nix
    ../../_mixins/hardware/other/usb.nix
    ../../_mixins/services/security/sudo.nix
  ];

  config = {
    boot = {
      mode.efi.enable = true;
      loader = {
        efi = {
          efiSysMountPoint = lib.mkForce "/boot/efi";
        };
        grub = {
          theme = pkgs.cyberre-grub-theme;
        };
      };
      initrd = {
        availableKernelModules = [ "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "uas" "sdhci_pci" ];
        kernelModules = [ ];
        systemd.enable = true;
        compressor = "zstd";
        compressorArgs = [ "-19" "-T0" ];
        verbose = lib.mkForce false;
      };
      consoleLogLevel = lib.mkForce 0;
      tmp = {
        # useTmpfs = true;
        cleanOnBoot = true;
      };
      kernelModules = [ "kvm-intel" "z3fold" "crc32c-intel" "lz4hc" "lz4hc_compress" ];
      kernelParams = [
        # intel cpu
        "i915.fastboot=1"
        "enable_gvt=1"
        "mem_sleep_default=deep"
      ];
      kernel.sysctl = lib.mkForce {
        "net.ipv4.ip_unprivileged_port_start" = 80; # Podman access port 80
      };
      extraModulePackages = [ ];
      blacklistedKernelModules = [ "nouveau" "nvidia" ];
    };

    # Intel GPU
    hardware = {
      opengl = {
        enable = true;
        extraPackages = with pkgs; [
          # Quick Sync Video
          # vpl-gpu-rt # or intel-media-sdk for QSV
          intel-media-sdk

          # Accelerated Video Playback
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiIntel
          libvdpau-va-gl
        ];
      };
    };
    environment = {
      sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
      systemPackages = with pkgs; [
        btdu
        btrfs-progs
        compsize
        cloneit
        lm_sensors
      ];
    };
    ##################
    ### FILESYSTEM ###
    ##################
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/Soyos";
        fsType = "btrfs";
        options = [
          "subvol=@rootfs"
          "rw"
          "noatime"
          "nodiratime"
          "ssd"
          "compress-force=zstd:3"
          "space_cache=v2"
          "nodatacow"
          "commit=120"
          "discard=async"
          "x-gvfs-hide" # hide from filemanager
        ];
      };
      "/home" = {
        device = "/dev/disk/by-label/Soyos";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "rw"
          "noatime"
          "nodiratime"
          "ssd"
          "compress-force=zstd:15"
          "space_cache=v2"
          "commit=120"
          "discard=async"
        ];
      };
      "/.snapshots" = {
        device = "/dev/disk/by-label/Soyos";
        fsType = "btrfs";
        options = [
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
      };
      "/var/tmp" = {
        device = "/dev/disk/by-label/Soyos";
        fsType = "btrfs";
        options = [
          "subvol=@tmp"
          "rw"
          "noatime"
          "nodiratime"
          "nodatacow"
          "ssd"
          "compress-force=zstd:15"
          "space_cache=v2"
          "commit=120"
          "discard=async"
        ];
      };
      "/var/log" = {
        device = "/dev/disk/by-label/Soyos";
        fsType = "btrfs";
        options = [
          "subvol=@logs"
          "rw"
          "noatime"
          "nodiratime"
          "ssd"
          "compress-force=zstd:15"
          "space_cache=v2"
          "commit=120"
          "discard=async"
        ];
      };
      # "/var/swap" = {
      #   device = "/dev/disk/by-label/Soyos";
      #   fsType = "btrfs";
      #   options = [
      #     "subvol=@swap"
      #     "defaults"
      #     "noatime"
      #   ];
      # };
      "/nix" = {
        device = "/dev/disk/by-label/Soyos";
        fsType = "btrfs";
        options = [
          "subvol=@nix"
          "rw"
          "noatime"
          "nodiratime"
          "ssd"
          "compress-force=zstd:15"
          "space_cache=v2"
          "commit=120"
          "discard=async"
        ];
      };
      # "/boot" = {
      #   device = "/dev/disk/by-label/BOOT";
      #   fsType = "ext4";
      # };
      "/boot/efi" = {
        device = "/dev/disk/by-label/EFI";
        # device = "/dev/disk/by-uuid/076D-BEC9";
        fsType = "vfat";
        options = [
          "defaults"
          "noatime"
          "nodiratime"
          "x-gvfs-hide" # hide from filemanager
        ];
        noCheck = true;
      };
    };
    swapDevices = [
      {
        device = "/dev/disk/by-label/SWAP";
        # device = "/var/swap/swapfile";
        # size = "20G";
      }
    ];
    services = {
      acpid = {
        enable = true;
      };
      btrfs = {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
      };
      earlyoom = {
        enable = true;
        freeSwapThreshold = 2;
        freeMemThreshold = 2;
        extraArgs = [
          "-g"
          "--avoid '^(X|plasma.*|konsole|kwin|foot)$'"
          "--prefer '^(electron|libreoffice|gimp)$'"
        ];
      };
      fstrim = { enable = true; };
    };
    systemd = {
      oomd = { enable = false; };
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
                    echo 20 > max_pool_percent&& \
                    echo lz4hc > compressor&& \
                    echo z3fold > zpool'
            '';
            Type = "simple";
          };
        };
        nix-daemon = {
          ### Limit resources used by nix-daemon
          serviceConfig = {
            MemoryMax = "4G";
            MemorySwapMax = "8G";
          };
        };
      };
    };
    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
    };
    console.keyMap = lib.mkForce "br";
    systemd.enableUnifiedCgroupHierarchy = true;
  };
}
