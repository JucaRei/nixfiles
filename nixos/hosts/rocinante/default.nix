# MacbookPro 4,1 early 2009
# nvidia 8600 gt
{ inputs, lib, pkgs, config, ... }:
let
  inherit (lib) mkForce mkDefault;
in
{
  imports = [
    (import ./disks.nix { })
    ./specialisations.nix
    inputs.vscode-server.nixosModules.default
  ];

  config = {
    core.boot = {
      boottype = mkForce "legacy";
      plymouth = mkForce true;
      silentBoot = mkForce true;
    };

    features = {
      graphics = {
        enable = true;
        gpu = "nvidia-legacy"; # 340xx
      };

      audio.manager = mkForce "pulseaudio";

      container-manager = {
        enable = true;
        manager = "docker";
      };
    };

    hardware = {
      firmware = [
        pkgs.b43Firmware_6_30_163_46 # BCM4321 wifi
      ];
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "uhci_hcd"
          "ehci_pci"
          "ata_piix"
          "ahci"
          "firewire_ohci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "sr_mod"
        ];
      };
      # blacklist similar modules to avoid collision
      blacklistedKernelModules = [
        # B43 driver
        "bcma"
        "ssb"
        "brcmfmac"
        "brcmsmac"
        "bcma"
        "wl"

        # USB rtl8811gu
        # "rtw88_8821gu"
      ];
      kernelModules = [
        # "kvm-intel"
        # "applesmc"
        "b43"
        "bcm5974" # touchpad
        "8188gu" # realtek driver
      ];

      extraModulePackages = [
        config.boot.kernelPackages.broadcom_sta
        config.boot.kernelPackages.rtl8821cu # rtl8811cu
      ];

      kernelPackages = mkForce pkgs.linuxPackages_6_6;
      kernelParams = [
        "intel_idle.max_cstate=1"
        "acpi_backlight=vendor"
        "net.ifnames=0"
        # "acpi_mask_gpe=0x15"
      ];
      loader.grub = {
        gfxpayloadBios = mkForce "1920x1200";
        copyKernels = true;
        # theme = pkgs.cyberre-grub-theme;
        device = "/dev/sda";
      };
    };

    services = {
      vscode-server = {
        enable = true;
      };

      # nfs
      rpcbind = {
        enable = true;
      };

      mbpfan = {
        enable = true;
        aggressive = true;
      };

      libinput = {
        enable = mkForce true;
        touchpad = {
          horizontalScrolling = true;
          naturalScrolling = true;
          tapping = true;
          tappingDragLock = false;
          scrollMethod = "twofinger";
          middleEmulation = true;
        };
      };

      xserver = {
        xkb = {
          layout = "us";
          variant = "mac"; # "altgr-intl"
          model = "pc105";
          options = "eurosign:5";
        };

        synaptics = {
          enable = mkForce false;
          twoFingerScroll = true;
          tapButtons = true;
          horizontalScroll = true;
          buttonsMap = [ 1 3 2 ];
          dev = "/dev/input/event*";
          # minSpeed = "1.5";
          # maxSpeed = "100";
          # accelFactor = "0.34";
          scrollDelta = 10;
          minSpeed = "0.7";
          maxSpeed = "1.7";
          palmDetect = true;
          accelFactor = "0.001";
          additionalOptions =
            ''
              Option "FingerHigh" "50"
              Option "FingerLow" "30"
              Option "TapAndDragGesture" "off"
              Option "TapButton1" "1"
              Option "TapButton2" "3"
              Option "TapButton3" "2"
              Option "VertScrollDelta" "-500"
              Option "HorizScrollDelta" "-500"
            ''
            # ''
            #   # "Natural" scrolling
            #   Option "VertScrollDelta" "-30"
            #   Option "HorizScrollDelta" "-30"

            #   Option "EmulateMidButtonTime" "100"
            # ''
          ;
        };
      };

      # actkbd = {
      #   enable = true;
      #   bindings = [
      #     { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/backlight/mba6x_backlight -A 10"; }
      #     { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/backlight/mba6x_backlight -U 10"; }
      #     { keys = [ 230 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/leds/smc::kbd_backlight -A 10"; }
      #     { keys = [ 229 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/leds/smc::kbd_backlight -U 10"; }
      #   ];
      # };
    };

    environment.systemPackages = with pkgs; [
      xorg.xrdb
      glxinfo
      inxi
      nixos-tweaker

      thorium

      cachix
      icloudpd # iCloud Photos Downloader
      vscode-fhs

      nfs-utils
      libnfs
      unfs3
      liblockfile

      nil
      nixpkgs-fmt
    ];

    networking.enableB43Firmware = true;

    # ens5
    # wlp0s26f7u4

    powerManagement.cpuFreqGovernor = mkForce "performance";

    nixpkgs.hostPlatform = mkDefault "x86_64-linux";

    nix.settings = {
      substituters = [
        "https://oldarch.cachix.org"
      ];
      trusted-public-keys = [
        "oldarch.cachix.org-1:LockJVSaehQ+nEXQPR1tJR6TcnVRve19QVsusuEmKqA="
      ];
    };
  };
}
