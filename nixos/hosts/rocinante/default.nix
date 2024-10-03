# MacbookPro 4,1 early 2009
# nvidia 8600 gt
{ inputs, lib, pkgs, config, ... }:
let
  inherit (lib) mkForce mkDefault;
in
{
  imports = [
    #inputs.nixos-hardware.nixosModules.common-cpu-intel
    #inputs.nixos-hardware.nixosModules.common-pc-laptop
    #inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ./disks.nix { })
    # ../../_mixins/hardware/graphics/nvidia-legacy.nix
    # ../../_mixins/services/security/sudo.nix
  ];

  ## disko does manage mounting of / /boot /home, but I want to mount by-partlabel
  #fileSystems."/" = lib.mkForce {
  #  device = "/dev/disk/by-label/NIXOS";
  #  fsType = "xfs";
  #  options = [ "defaults" "noatime" "nodiratime" ];
  #};

  # swapDevices = [
  #   {
  #     device = "/swap";
  #     size = 2048;
  #   }
  # ];

  config = {
    core.boot = {
      boottype = mkForce "legacy";
      plymouth = mkForce false;
      silentBoot = mkForce false;
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
      ];
      kernelModules = [
        # "kvm-intel"
        # "applesmc"
        "bcm5974" # touchpad
        # "b43"
        "wl" # set of kernel modules loaded in second stage of boot process
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
      # kernelPackages = mkDefault pkgs.linuxPackages_5_4;
      # kernelPackages = mkDefault pkgs.linuxPackages_xanmod_stable;
      # kernelPackages = mkDefault pkgs.linuxPackages_5_15;
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
      mbpfan = {
        enable = true;
        aggressive = true;
      };
      xserver = {
        libinput = {
          enable = mkForce false;
          touchpad = {
            horizontalScrolling = true;
            naturalScrolling = false;
            tapping = true;
            tappingDragLock = false;
          };
        };
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
      # xorg.xbacklight
      xorg.xrdb
      #intel-gpu-tools
      glxinfo
      inxi

      cachix
    ];

    # networking.enableB43Firmware = true;

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
