{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkForce;

  # if echo $XDG_SESSION_TYPE == x11
in
{
  imports = [
    ./filesystem.nix
    # ./externalMonitor.nix
    # ./disks-btrfs.nix
  ];
  config = {
    core = {
      boot = {
        isDualBoot = true;
      };
    };

    features = {
      graphics = {
        enable = true;
        gpu = "hybrid-nvidia";
        # gpu = "intel";
        acceleration = true;
      };

      container-manager = {
        enable = true;
        manager = "docker";
      };

      virtualisation.enable = true;

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
        # verbose = mkForce false;
      };
      # extraModulePackages = (with config.boot.kernelPackages; [
      #   # (callPackage ../../../pkgs/system/kernel/rtl8188gu/test2.nix { })
      # ]);

      # kernelPackages = pkgs.linuxPackages_cachyos;
      # kernelPackages = pkgs.linuxPackages_xanmod_latest;
      # kernelPackages = pkgs.linuxPackages_lqx;
      # kernelPackages = mkForce pkgs.linuxPackages_6_6;

      kernelModules = [
        "z3fold"
        "lz4hc"
        "lz4hc_compress"
      ];
      kernelParams = [
        "nosgx"
        "zswap.enabled=1"
        "mem_sleep_default=deep"
        # "i8042.reset"
        # "i8042.noloop"
        "i8042.nomux" # Don't check presence of an active multiplexing controller
        "i8042.nopnp" # Don't use ACPIPn<P / PnPBIOS to discover KBD/AUX controllers
        # "usbcore.autosuspend=-1" # Disable USB autosuspend

        ### CGROUPS v1
        # "systemd.unified_cgroup_hierachy=0"
        # "SYSTEMD_CGROUP_ENABLE_LEGACY_FORCE=1"
      ];
      loader = {
        grub = {
          theme = mkForce pkgs.cyberre;
          efiInstallAsRemovable = mkForce false;
        };
        efi = {
          efiSysMountPoint = mkForce "/boot";
          canTouchEfiVariables = mkForce true;
        };
      };
    };

    environment = {
      systemPackages = with pkgs; [
        btdu
        btrfs-progs
        compsize
        gparted
        lm_sensors
        vscode-fhs

        transmission_3-gtk
        vlc

        duf
        gnupg
        pinentry-curses
      ];
    };

    services = {
      nfs.server.enable = true;

      # ollama = {
      #   enable = false;
      #   acceleration = "cuda";
      #   loadModels = [
      #     "mxbai-embed-large:335m"
      #     "nomic-embed-text:latest"
      #     "codestral:22b"
      #     "deepseek-r1:1.5b"
      #     "qwen2.5-coder:7b" #128k
      #   ];
      # };
      # open-webui = {
      #   enable = true;
      # };

      # scx.enable = true; # by default uses scx_rustland scheduler

      xserver = {
        xkb = {
          # Brazil layout
          layout = "br"; # Keyboard layout
          model = "pc105";
          # variant = "nodeadkeys";
          options = "terminate:ctrl_alt_bksp";
        };
      };

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
        # package = mkForce (config.boot.kernelPackages.nvidiaPackages.mkDriver {
        #   version = "555.58.02";
        #   sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
        #   sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
        #   openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
        #   settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        #   persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
        # });

        prime = {
          #     offload.enable = lib.mkForce true;
          #     offload.enableOffloadCmd = lib.mkForce true;
          nvidiaBusId = "PCI:1:0:0";
          intelBusId = "PCI:0:2:0";

          #     reverseSync.enable = lib.mkForce true;
        };

        #nvidiaSettings = true;
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
                    echo 1 > shrinker_enabled&& \
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
            # CPUQuota = "${toString (config.system.nproc * 20)}%";
            # weights default is 100
            # CPUWeight = "idle";
            # IOWeight = "20";
            # MemoryHigh = "20%";
            MemoryMax = "4G";
            MemorySwapMax = "8G";
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
  };
}

# sudo mount -t nfs 192.168.2.200:/mnt/HD/HD_b2 /home/juca/Media/Videos/Volume1
# sudo mount -t nfs 192.168.2.200:/mnt/HD/HD_a2/ /home/juca/Media/Videos/Volume2
