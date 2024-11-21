{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkIf mkForce getExe;

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

  # if echo $XDG_SESSION_TYPE == x11
in
{
  config = {
    core.boot = {
      isDualBoot = true;
    };


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
        # verbose = mkForce false;
      };
      extraModulePackages = (with config.boot.kernelPackages; [
        # (callPackage ../../../pkgs/system/kernel/rtl8188gu/test2.nix { })
      ]);
      # kernelPackages = pkgs.linuxPackages_xanmod_stable;
      # kernelPackages = mkForce pkgs.linuxPackages_6_6;

      kernelModules = [
        "z3fold"
        "lz4hc"
        "lz4hc_compress"
      ];
      kernelParams = [
        "zswap.enabled=1"
        "mem_sleep_default=deep"
        "usbcore.autosuspend=-1" # Disable USB autosuspend
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

      extraModprobeConfig = "options kvm_intel nested=1";
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
        # spotube
        youtube-music
      ];
    };

    services =
      let
        isXorg = if ("${pkgs.uutils-coreutils-noprefix}/bin/echo $XDG_SESSION_TYPE" == "x11") then true else false;
      in
      {
        nfs.server.enable = true;

        xserver = mkIf (config.features.graphics.backend != "wayland") {
          # FUCK NVIDIA
          config = mkForce ''
             Section "ServerLayout"
               Identifier "layout"
               Screen "nvidia" 0 0
             EndSection

             Section "Module"
                 Load "modesetting"
                 Load "glx"
             EndSection

             Section "Device"
               Identifier "nvidia"
               Driver "nvidia"
               BusID "PCI:1:0:0"
               Option "AllowEmptyInitialConfiguration"
             EndSection

             Section "Device"
               Identifier "intel"
               Driver "modesetting"
               Option "AccelMethod" "sna"
             EndSection

            Section "Screen"
              Identifier     "nvidia"
              Device         "nvidia"
              DefaultDepth    24
              Option         "AllowEmptyInitialConfiguration"
              SubSection     "Display"
                Depth       24
                Modes      "nvidia-auto-select"
              EndSubSection
            EndSection

             Section "Screen"
               Identifier "intel"
               Device "intel"
             EndSection
          '';
          displayManager = mkIf isXorg {
            setupCommands = ''
              RIGHT='eDP-1'
              LEFT='HDMI-1-0'
              ${lib.getExe pkgs.xorg.xrandr} --output $LEFT --mode 1920x1080 --rotate right --output $LEFT --mode 1920x1080 --rotate left --right-of $LEFT
            '';
            sessionCommands = ''${lib.getExe pkgs.xorg.xrandr} --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal'';
          };

          # xrandrHeads = [
          #   {
          #     output = "HDMI-1-0";
          #     monitorConfig = ''
          #       Option "PreferredMode"  "1920x1080"
          #       Option "Primary"        "true"
          #       Option "RightOf"        "eDP-1"
          #     '';
          #   }
          #   {
          #     output = "eDP-1";
          #     monitorConfig = ''
          #       Option "right-of" "DP1"
          #       Option "Rotate" "left"
          #       Option "PreferredMode" "1920x1080"
          #     '';
          #   }
          # ];
          xkb = {
            # Brazil layout
            layout = "br"; # Keyboard layout
            model = "pc105";
            variant = "nodeadkeys";
            options = "terminate:ctrl_alt_bksp";
          };
          # xrandrHeads = [
          #   {
          #     output = "eDP-1";
          #     primary = true;
          #     monitorConfig = ''
          #       Option "PreferredMode" "1920x1080"
          #       Option "Position" "1920 0"
          #     '';
          #   }
          #   {
          #     output = "HDMI-1-0";
          #     primary = false;
          #     monitorConfig = ''
          #       Option "PreferredMode" "1920x1080"
          #       Option "Position" "0 0"
          #     '';
          #   }
          # ];
          # This must be done manually to ensure my screen spaces are arranged
          # exactly as I need them to be *and* the correct monitor is "primary".
          # Using xrandrHeads does not work.
          # monitorSection = ''
          #   VendorName     "PlayStation"
          #   Identifier     "HDMI-1-0"
          #   HorizSync       30.0 - 81.0
          #   VertRefresh     50.0 - 75.0
          #   Option         "DPMS"
          # '';
          # screenSection = ''
          #   Option "metamodes" "HDMI-0: nvidia-auto-select +1920+0, DP-1: 1920x1080_75 +0+0"
          #   Option "SLI" "Off"
          #   Option "MultiGPU" "Off"
          #   Option "BaseMosaic" "o ff"
          #   Option "Stereo" "0"
          #   Option "nvidiaXineramaInfoOrder" "DFP-1"
          # '';


          # Section "Monitor"
          # Monitor Identity - Typically HDMI-0 or DisplayPort-0
          # Identifier    "HDMI1"

          # Setting Resolution and Modes
          # Modeline is usually not required, but you can force resolution with it
          # Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
          # Option "PreferredMode" "1920x1080"
          # Option        "TargetRefresh" "60"

          # Positioning the Monitor
          # Basic
          # Option "LeftOf or RightOf or Above or Below" "DisplayPort-0"
          # Advanced
          # Option        "Position" "1680 0"

          # Disable a Monitor
          # Option        "Disable" "true"
          # EndSection .

          resolutions = [

            # { x = 2048; y = 1152; }
            { x = 1920; y = 1080; }
            { x = 1600; y = 900; }
            { x = 1366; y = 768; }
            # { x = 2560; y = 1440; }
            # { x = 3072; y = 1728; }
            # { x = 3840; y = 2160; }
          ];
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

    programs = {
      virt-manager.enable = true;
      dconf = {
        enable = true;
        profiles = {
          user = {
            databases = [{
              settings = with lib.gvariant; {
                "org/virt-manager/virt-manager" = {
                  xmleditor-enabled = true;
                };
                "org/virt-manager/virt-manager/connections" = {
                  autoconnect = [ "qemu:///system" ];
                  uris = [ "qemu:///system" ];
                };
              };
            }];
          };
        };
      };
    };

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };

    users.users.juca = {
      extraGroups = [ "libvirtd" ];
    };


    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixsystem";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [
          "subvol=@rootfs"
          "x-gvfs-hide" # hide from filemanager
        ] ++ BTRFS_OPTS;
      };

      "/home" = {
        device = "/dev/disk/by-label/nixsystem";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [
          "subvol=@home"
        ] ++ BTRFS_OPTS;
      };

      "/.snapshots" = {
        device = "/dev/disk/by-label/nixsystem";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [
          "subvol=@snapshots"
        ] ++ BTRFS_OPTS;
      };

      "/var/log" = {
        device = "/dev/disk/by-label/nixsystem";
        fsType = "btrfs";
        options = [
          "subvol=@logs"
        ] ++ BTRFS_OPTS;
      };

      "/var/tmp" = {
        device = "/dev/disk/by-label/nixsystem";
        fsType = "btrfs";
        options = [
          "subvol=@tmp"
        ] ++ BTRFS_OPTS;
      };

      "/nix" = {
        device = "/dev/disk/by-label/nixsystem";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [
          "subvol=@nix"
        ] ++ BTRFS_OPTS;
      };

      "/boot" = {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
          "defaults"
          "noatime"
          "nodiratime"
          "x-gvfs-hide" # hide from filemanager
        ];
        noCheck = true;
      };

      # "/var/swap" = {
      #   # device = "/dev/disk/by-label/nixsystem";
      #   device = "/dev/disk/by-uuid/62107246-5335-41d1-a94b-076b7baae356";
      #   fstype = "btrfs";
      #   options = [ "noatime" "ssd_spread" "subvol=@swap" ];
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

    # swapDevices = [
    #   {
    #     device = "/var/swap/swapfile";
    #     size = 16384;
    #     # device = "/var/swap/swapfile";
    #     # device = "/dev/disk/by-label/swap";
    #     # device = "/dev/disk/by-partlabel/disk-nvme0-SWAP";
    #     # size = "20G";
    #   }
    # ];

    swapDevices = [{
      device = "/swapfile";
      size = 16 * 1024; # 16GB
    }];
  };
}

# sudo mount -t nfs 192.168.2.200:/mnt/HD/HD_b2 /home/juca/Media/Videos/Volume1
# sudo mount -t nfs 192.168.2.200:/mnt/HD/HD_a2/ /home/juca/Media/Videos/Volume2
