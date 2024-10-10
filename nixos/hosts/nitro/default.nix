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
        "usbcore.autosuspend=-1" # Disable USB autosuspend
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

      btrfs = {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
      };
    };

    hardware = {
      # 555.78 not working with xanmod
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
  };
}
