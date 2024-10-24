{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkDefault mkIf mkForce getExe;
in
{
  imports = [
    (import ./disks-emmc.nix { })
    ./kodi.nix
  ];
  config = {
    core = {
      boot = {
        silentBoot = false;
        plymouth = false;
      };

      cpu = {
        improveTCP = true;
      };

      network = {
        wakeonlan = true;
        custom-interface = "eth0";
      };
    };

    features = {
      audio = {
        manager = mkForce "pulseaudio";
      };

      graphics = {
        enable = true;
        gpu = "intel";
      };

      container-manager = {
        enable = true;
        manager = "podman";
      };

      autocpufreq = {
        enable = false;
        autosuspend = false;
      };
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "ahci" # Enables the Advanced Host Controller Interface (AHCI) driver, typically used for SATA (Serial ATA) controllers.
          "xhci_pci" # Enables the eXtensible Host Controller Interface (xHCI) driver for PCI-based USB controllers, providing support for USB 3.0 and later standards.
          "usbhid" # module is very simple, it takes no parameters, detects everything automatically and when a HID device is inserted, it detects it appropriately.
          "usb_storage" # Enables the USB Mass Storage driver, allowing the system to recognize and use USB storage devices like USB flash drives and external hard drives.
          "sd_mod" # Enables the SCSI disk module (sd_mod), which allows the system to recognize and interact with SCSI-based storage devices.
          "uas" # Enables the USB Attached SCSI (UAS) driver, which provides a faster and more efficient way to access USB storage devices.
          "sdhci_pci" #  The sdhci driver supports PCI devices with class 8 and subclass 5 according to SD Host Controller Specification.
        ];
        # systemd.enable = true;
        compressor = "zstd";
        compressorArgs = [ "-19" "-T0" ];
        # verbose = mkForce false;

        # supportedFilesystems = [
        #   "f2fs"
        # ];
        kernelModules = [ "coretemp" ];
      };
      supportedFilesystems = [ "vfat" "f2fs" "cifs" "nfs" ];
      extraModulePackages = (with config.boot.kernelPackages; [
        # (callPackage ../../../pkgs/system/kernel/rtl8188gu/test2.nix { })
      ]);
      kernelPackages = pkgs.linuxPackages_xanmod_stable;

      kernelModules = [
        "coretemp" # Temperature monitoring on Intel CPUs
        "z3fold"
        "lz4hc"
        "lz4hc_compress"
        "tcp_cubic" # Cubic: A traditional and widely used congestion control algorithm
        "tcp_westwood" # Westwood: Particularly effective in wireless networks
      ];
      kernelParams = [
        "zswap.enabled=1"
        "mem_sleep_default=deep"
        "elevator=kyber" # Change IO scheduler to Kyber
        "rootflags=atgc"

        # "boot.shell_on_fail"

        # "pcie_aspm=force" # pcie active state power management
        # "elevator=kyber" # Change IO scheduler to Kyber
        # "fbcon=nodefer" # Prevent the kernel from blanking plymouth out of the framebuffer
        # "intel_iommu=on" # Enable IOMMU
        # "io_delay=none" # Disable I/O delay accounting
        # "iomem=relaxed" # Allow more relaxed I/O memory access
        # "iommu=pt" # Enables passthrough mode for the IOMMU, allowing direct access to hardware devices
        # "irqaffinity=0-7" # Set IRQ affinity to CPUs 0-7
        # "loglevel=3" # Set kernel log level to 3 (default)
        # # "logo.nologo" # Disable boot logo if any
        # "mitigations=off" # Turn off certain CPU security mitigations. It might enhance performance
        # "nmi-watchdog=0" # Disable the non-maskable interrupt (NMI) watchdog
        # "noirqdebug" # Disable IRQ debugging
        # "rootdelay=0" # No delay when mounting root filesystem
        # "video.allow_duplicates=1" # Allow duplicate frames or similar, helps smooth video playback
        # "zswap.max_pool_percent=10" # Set zswap maximum pool percentage to 10%
        # "zswap.compressor=lz4" # Set zswap compressor to lz4
        # "zswap.enabled=1" # Enable zswap
        # "zswap.zpool=zsmalloc" # Set zswap zpool to zsmalloc
      ];
      loader = {
        grub = {
          theme = mkForce pkgs.cyberre;
        };
      };

      extraModprobeConfig = "options kvm_intel nested=1";
    };

    environment = {
      systemPackages = with pkgs; [
        cloneit
        lm_sensors
        duf
      ];

      etc."sysconfig/lm_sensors".text = ''
        HWMON_MODULES="coretemp"
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [ 8080 ]; # for web interface / remote control Kodi
      allowedUDPPorts = [ 8080 ];
    };

    services = {
      xserver = {
        # Brazil layout
        layout = "br"; # Keyboard layout
        xkbModel = "pc105";
        xkbVariant = "nativo";
      };

      rpcbind.enable = true; # Enable RPC bind service

      ### Touchpad
      libinput = {
        mouse = {
          naturalScrolling = false;
          disableWhileTyping = true;
          accelProfile = "adaptive";
          accelSpeed = "0.3";
        };
      };

      samba = {
        enable = true;
        #package = pkgs.unstable.samba4Full; # samba4Full broken
        # securityType = "user";
        # openFirewall = true;
        extraConfig = ''
          # My old nas dlink-325 uses v1
          client min protocol = NT1
        '';
      };
    };


    systemd = {
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
            MemoryMax = "2G";
            MemorySwapMax = "4G";
          };
        };
      };

      sleep.extraConfig = ''
        AllowHibernation=no
      '';

      ### HWP
      # tmpfiles = {
      #   rules = [ "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power" ];
      # };
    };

    nixpkgs = {
      hostPlatform = mkDefault "x86_64-linux";
      config.kodi.enableAdvancedLauncher = true;
    };

    fileSystems = {
      ###################
      ### Smb folders ###
      ###################

      # "/media/sharecenter/volume_1" = {
      #   device = "//192.168.1.207/Volume_1";
      #   fsType = "cifs";
      #   # options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "gid=100" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
      #   options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
      # };

      # "/media/sharecenter/volume_2" = {
      #   device = "//192.168.1.207/Volume_2/Transmission/Volume_2";
      #   fsType = "cifs";
      #   options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
      # };
    };

    powerManagement.cpuFreqGovernor = lib.mkForce
      "schedutil";
  };
}
