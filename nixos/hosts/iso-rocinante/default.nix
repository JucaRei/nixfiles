{ lib, pkgs, config, ... }:
let
  inherit (lib) mkForce;
in
{
  config = {
    # Allow insecure broadcom-sta (CVE-2019-9501/9502) — required for BCM43xx Wi-Fi
    # on MacBook Pro 4,1. No maintained alternative exists for this chipset.
    nixpkgs.config.permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-59-6.18"
      "broadcom-sta-6.30.223.271-59-6.18.40"
      "broadcom-sta"
    ];
    # --- MacBook Pro 4,1 Specific Hardware ---
    # The MBP 4,1 has a 32-bit EFI booting a 64-bit CPU.
    # Standard NixOS ISOs assume 64-bit EFI and systemd initrd,
    # both of which fail on this hardware.

    # Use LTS kernel for stability on legacy hardware
    boot.kernelPackages = mkForce pkgs.linuxPackages;

    # Disable systemd initrd — the scripted initrd is more compatible
    # with legacy boot (32-bit EFI / BIOS CSM) and Ventoy/USB quirks.
    # Systemd initrd's "initrd-find-nixos-closure" service fails on
    # non-standard media layouts (Ventoy, dd with wrong labels, etc.)
    boot.initrd.systemd.enable = mkForce false;

    # Essential initrd modules for MacBook Pro 4,1 hardware
    boot.initrd = {
      availableKernelModules = [
        # USB controllers (MacBook Pro 4,1 uses UHCI + EHCI, no xHCI)
        "uhci_hcd"
        "ehci_pci"
        "ehci_hcd"
        "usb_storage"
        "uas"
        # Disk controllers
        "ahci"
        "sd_mod"
        "sr_mod"
        # FireWire (present on MBP 4,1)
        "firewire_ohci"
        # Apple hardware
        "applesmc"
        "usbhid"
        "hid_apple"
        # ISO media & filesystem support
        "iso9660"
        "squashfs"
        "overlay"
        "loop"
        # Common filesystems for rescue
        "btrfs"
      ];
    };

    # Kernel modules for runtime Apple hardware
    boot.kernelModules = [
      "applesmc"
      "hid_apple"
      "coretemp"
    ];

    # Apple keyboard: fnmode=1 (native F-keys), swap_opt_cmd=1
    boot.extraModprobeConfig = ''
      options hid_apple fnmode=1 swap_opt_cmd=1
    '';

    # Disable VM guest drivers (they produce hv_vmbus errors on bare metal)
    virtualisation.hypervGuest.enable = mkForce false;

    # Kernel params for stable boot on Penryn hardware
    boot.kernelParams = [
      "nomodeset"           # Safe video mode — avoids NVIDIA/Nouveau conflicts in live env
      "mitigations=off"     # Penryn: CPU mitigations are expensive and barely relevant
      "nowatchdog"
    ];

    # Enable all firmware for broadest Wi-Fi/Bluetooth/GPU compatibility
    hardware = {
      enableAllFirmware = true;
      enableRedistributableFirmware = true;
      wirelessRegulatoryDatabase = true;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    # Blacklist open-source Broadcom drivers that conflict with broadcom_sta (wl)
    boot.blacklistedKernelModules = [
      "b43"
      "b43legacy"
      "bcma"
      "brcmsmac"
      "brcmfmac"
      "ssb"
    ];

    # Load broadcom_sta for BCM43xx Wi-Fi in the live environment
    boot.extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
    ];

    # Support common filesystems for rescue & installation
    boot.supportedFilesystems = [
      "btrfs"
      "ext4"
      "xfs"
      "vfat"
      "ntfs"
    ];

    # --- Network ---
    networking = {
      networkmanager.enable = true;
      wireless.enable = mkForce false;
      # Fix: repetidores rejeitam MAC aleatório / desconexões com powersave
      networkmanager.wifi.scanRandMacAddress = false;
      networkmanager.wifi.powersave = false;
    };

    # --- ZRAM Swap ---
    zramSwap = {
      enable = true;
      algorithm = "lz4";       # LZ4: lower latency than zstd on Penryn Core 2 Duo
      memoryPercent = 75;
      priority = 100;
    };

    # --- ISO Image Settings ---
    isoImage = {
      squashfsCompression = "zstd -Xcompression-level 15"; # Slightly lower than 19 for faster build
      makeEfiBootable = true;   # Needed even for 32-bit EFI (GRUB handles the 32-bit target)
      makeUsbBootable = true;   # Hybrid MBR for BIOS/Legacy USB boot
      edition = "rocinante";
    };

    # Disable docs to save space
    documentation = {
      enable = false;
      nixos.enable = false;
    };

    # --- Live System Packages ---
    environment.systemPackages = with pkgs; [
      # Partitioning & Filesystem
      gparted
      parted
      disko
      btrfs-progs
      e2fsprogs
      dosfstools
      ntfs3g

      # Hardware diagnosis
      fastfetch
      pciutils
      usbutils
      lshw
      lm_sensors
      htop

      # Network & Transfer
      git
      curl
      wget
      rsync

      # Editors & Browser
      firefox
      neovim

      # MacBook hardware tools
      brightnessctl
      pamixer
    ];

    # --- Live ISO Passwords ---
    users.users = {
      nixos = {
        password = "admin";
        hashedPassword = mkForce null;
        initialPassword = mkForce null;
        initialHashedPassword = mkForce null;
      };
      root = {
        password = "admin";
        hashedPassword = mkForce null;
        initialPassword = mkForce null;
        initialHashedPassword = mkForce null;
      };
    };
  };
}
