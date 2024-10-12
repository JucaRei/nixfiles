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

    desktop.features = {
      audio.manager = mkForce "pulseaudio";
    };

    features = {
      graphics = {
        enable = true;
        gpu = "nvidia-legacy"; # 340xx
      };

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
        "bcma"
        "ssb"
        "brcmfmac"
        "brcmsmac"
        "bcma"
        "wl"
      ];
      kernelModules = [
        # "kvm-intel"
        # "applesmc"
        "b43"
        "bcm5974" # touchpad
      ];

      extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

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

      mbpfan = {
        enable = true;
        aggressive = true;
      };

      libinput = {
        enable = mkForce false;
        touchpad = {
          horizontalScrolling = true;
          naturalScrolling = false;
          tapping = true;
          tappingDragLock = false;
        };
      };

      xserver = {
        synaptics = {
          enable = mkDefault true;
          twoFingerScroll = true;
          tapButtons = true;
          palmDetect = true;
          horizontalScroll = true;
          buttonsMap = [ 1 3 2 ];
          # minSpeed = "1.5";
          # maxSpeed = "100";
          # accelFactor = "0.34";
          minSpeed = "0.70";
          maxSpeed = "1.20";
          accelFactor = "0.001";
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
