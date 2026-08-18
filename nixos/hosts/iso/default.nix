{ lib, pkgs, desktop, isWorkstation, ... }:
let
  inherit (lib) mkForce;
in
{
  config = {
    # --- Generic Hardware & Drivers for all x86_64 machines ---
    hardware = {
      # Enable all free and redistributable firmwares (Wi-Fi, Bluetooth, Intel/AMD Microcode)
      enableAllFirmware = true;
      enableRedistributableFirmware = true;

      # Generic GPU acceleration (Mesa / Vulkan / KMS for AMD, Intel, NVIDIA Nouveau)
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Wireless regulatory database
      wirelessRegulatoryDatabase = true;
    };

    # Use stable LTS kernel for ISOs (ensures pre-built binary cache & full ZFS compatibility)
    boot.kernelPackages = mkForce pkgs.linuxPackages;

    # Support all common filesystems for rescue and installation
    boot.supportedFilesystems = [
      "btrfs"
      "ext4"
      "xfs"
      "f2fs"
      "vfat"
      "ntfs"
      "zfs"
    ];

    # --- Network Management ---
    networking = {
      networkmanager.enable = true;
      wireless.enable = mkForce false; # Avoid wpa_supplicant conflict with NetworkManager
    };

    # --- Memory & ZRAM (2x Host RAM) ---
    zramSwap = {
      enable = true;
      memoryPercent = 200;
      algorithm = "zstd";
      priority = 100;
    };

    # --- ISO Image Compression & Boot Options ---
    isoImage = {
      # Extreme zstd compression for minimum ISO file size and fast decompression
      squashfsCompression = "zstd -Xcompression-level 19";
      makeEfiBootable = true;
      makeUsbBootable = true;
      edition = if isWorkstation && desktop != null then "${desktop}" else "console";
    };

    # Disable static documentation to save hundreds of MBs in ISO size
    documentation = {
      enable = false;
      nixos.enable = false;
    };

    # --- Live System Utility Packages ---
    environment.systemPackages = with pkgs; [
      # Partitioning & Filesystem repair
      gparted
      parted
      disko
      btrfs-progs
      e2fsprogs
      dosfstools
      ntfs3g

      # Hardware info & diagnosis
      fastfetch
      pciutils
      usbutils
      lshw
      lm_sensors
      htop
      btop

      # Transfer & Networking
      git
      curl
      wget
      rsync

      # Core Editors & Browsers
      firefox
      vscode-fhs
      neovim
    ];

    # --- Default Password for Live ISO ---
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
