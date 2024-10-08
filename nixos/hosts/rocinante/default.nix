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
      enableAllFirmware = true;
      # firmware = [ pkgs.b43Firmware_5_1_138 ];

      # opengl = {
      #   driSupport = true;
      #   driSupport32Bit = true;
      # };
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
        kernelModules = [
          "wl" # load broadcom wireless driver
          # "b43"
          # "bcm5974"
        ];
      };
      # blacklist similar modules to avoid collision
      blacklistedKernelModules = [
        "b43"
        "bcma"
        "ssb"
        "brcmfmac"
        "brcmsmac"
        "bcma"
        # "wl"
      ];
      kernelModules = [
        # "kvm-intel"
        # "applesmc"
        "b43"
        # "wl" # set of kernel modules loaded in second stage of boot process
        "bcm5974" # touchpad
      ];

      extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      # extraModulePackages = [
      #   (config.boot.kernelPackages.broadcom_sta.overrideAttrs (old: {
      #     patches = old.patches ++ [
      #       (builtins.fetchurl {
      #         url = "https://raw.githubusercontent.com/archlinux/svntogit-community/5ec5b248976f84fcd7e3d7fae49ee91289912d12/trunk/012-linux517.patch";
      #         sha256 = "df557afdb0934ed2de6ab967a350d777cbb7b53bf0b1bdaaa7f77a53102f30ac";
      #       })
      #     ];
      #   }))
      # ];

      kernelPackages = mkForce pkgs.linuxPackages_6_6;
      #kernelParams = [ "intel_idle.max_cstate=1" "hid_apple.iso_layout=0" "acpi_backlight=vendor" "acpi_mask_gpe=0x15" ];
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
      #extraModprobeConfig = ''
      #  options bcm5974
      #'';
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
      icloudpd # iCloud Photos Downloader
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
