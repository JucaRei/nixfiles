# MacbookPro 4,1 early 2009
# nvidia 8600 gt
{ inputs, lib, pkgs, config, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    #inputs.nixos-hardware.nixosModules.common-cpu-intel
    #inputs.nixos-hardware.nixosModules.common-pc-laptop
    #inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ./disks.nix { })
    ../../_mixins/hardware/graphics/nvidia-legacy.nix
    ../../_mixins/services/security/sudo.nix
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
    core = {
      boottype = mkForce "legacy";
      plymouth = true;
      silentBoot = true;
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
      extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
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
      # kernelPackages = lib.mkDefault pkgs.linuxPackages_6_1;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_5_4;
      # kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_stable;
      # kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
      #kernelParams = [ "intel_idle.max_cstate=1" "hid_apple.iso_layout=0" "acpi_backlight=vendor" "acpi_mask_gpe=0x15" ];
      kernelParams = [
        "intel_idle.max_cstate=1"
        "acpi_backlight=vendor"
        # "acpi_mask_gpe=0x15"
      ];
      loader.grub = {
        gfxpayloadBios = "1920x1200";
        theme = pkgs.cyberre-grub-theme;
      };
      #extraModprobeConfig = ''
      #  options bcm5974
      #'';
    };

    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
        nvidiaSettings = true;
        modesetting.enable = true;
      };
      acpilight.enable = true;
    };

    services = {
      mbpfan = {
        enable = true;
        aggressive = true;
      };
      xserver = {
        libinput = {
          enable = lib.mkForce false;
          touchpad = {
            horizontalScrolling = true;
            naturalScrolling = false;
            tapping = true;
            tappingDragLock = false;
          };
        };
        synaptics = {
          enable = lib.mkDefault true;
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
    ];

    # networking.enableB43Firmware = true;

    # ens5
    # wlp0s26f7u4

    powerManagement.cpuFreqGovernor = mkForce "performance";

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
