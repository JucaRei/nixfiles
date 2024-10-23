{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkDefault mkIf mkForce getExe;
in
{
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
        # wakeonlan = true;
        custom-interface = "";
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
      };
      extraModulePackages = (with config.boot.kernelPackages; [
        # (callPackage ../../../pkgs/system/kernel/rtl8188gu/test2.nix { })
      ]);
      kernelPackages = pkgs.linuxPackages_xanmod_stable;

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

        enable = true;
        desktopManager.kodi = {
          enable = true;
          package = pkgs.kodi.withPackages (p: with p; [
            # kodi-platform
            youtube
            inputstream-adaptive
            sponsorblock
            invidious
            sendtokodi
            trakt
            osmc-skin
          ]);
        };
        displayManager = {
          autoLogin = {
            enable = true;
            user = lib.mkForce "${username}";
          };

          # disable DPMS
          monitorSection = ''
            Option "DPMS" "false"
          '';

          # x11 no suspend, disable screen blanking in general
          # serverFlagsSection = ''
          #   Option "StandbyTime"  "0"
          #   Option "SuspendTime"  "0"
          #   Option "OffTime"      "0"
          #   Option "BlankTime"    "0"
          # '';

          #disable blank screen
          # setupCommands = ''
          #   /run/current-system/sw/bin/xset -dpms
          #   /run/current-system/sw/bin/xset s off
          # '';

          # This may be needed to force Lightdm into 'autologin' mode.
          # Setting an integer for the amount of time lightdm will wait
          # between attempts to try to autologin again.
          # lightdm.autoLogin.timeout = 3;
        };

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
    };

    nixpkgs = {
      hostPlatform = mkDefault "x86_64-linux";
      config.kodi.enableAdvancedLauncher = true;
    };

    fileSystems = {
      ###################
      ### Smb folders ###
      ###################

      "/media/sharecenter/volume_1" = {
        device = "//192.168.1.207/Volume_1";
        fsType = "cifs";
        # options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "gid=100" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
        options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
      };

      "/media/sharecenter/volume_2" = {
        device = "//192.168.1.207/Volume_2/Transmission/Volume_2";
        fsType = "cifs";
        options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
      };
    };

    powerManagement.cpuFreqGovernor = lib.mkForce
      "schedutil";
  };
}
