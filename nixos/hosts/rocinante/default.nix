# MacbookPro 4,1 early 2009
# nvidia 8600 gt
{ inputs, lib, pkgs, config, ... }:
let
  inherit (lib) mkForce mkDefault;
in
{
  imports = [
    (import ./disks.nix { })
    inputs.vscode-server.nixosModules.default
  ];

  config = {
    core.boot = {
      boottype = mkForce "legacy";
      plymouth = mkForce true;
      silentBoot = mkForce true;
    };

    desktops.features = {
      audio.manager = mkForce "pulseaudio";
    };

    features = {
      graphics = {
        enable = true;
        gpu = "nvidia-legacy";
      };
    };

    hardware = {
      firmware = [
        pkgs.b43Firmware_6_30_163_46
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
        };
      };
    };

    environment.systemPackages = with pkgs; [
      xorg.xrdb
      glxinfo
      inxi

      cachix
      icloudpd # iCloud Photos Downloader,
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
