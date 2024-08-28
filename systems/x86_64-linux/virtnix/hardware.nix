{ config
, lib
, modulesPath
, pkgs
, ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    # ./disks-btrfs.nix
  ];

  ##
  # Desktop VM config
  ##
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub.devices = mkForce [ "nodev" ];

    initrd = {
      kernelModules = [
        # "kvm-amd"
        "kvm-intel"
      ];
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
    };

    extraModulePackages = [ ];
  };

  fileSystems =
    let
      BTRFS_OPTS = [
        "noatime"
        "nodiratime"
        "nodatacow"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    in
    {
      "/" = {
        device = "/dev/disk/by-partlabel/disk-vda-NixOS";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [
          "subvol=@"
          "x-gvfs-hide" # hide from filemanager
        ] ++ BTRFS_OPTS;
      };

      "/home" = {
        device = "/dev/disk/by-partlabel/disk-vda-NixOS";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [ "subvol=@home" ] ++ BTRFS_OPTS;
      };

      "/.snapshots" = {
        device = "/dev/disk/by-partlabel/disk-vda-NixOS";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [ "subvol=@snapshots" ] ++ BTRFS_OPTS;
      };

      "/var" = {
        device = "/dev/disk/by-partlabel/disk-vda-NixOS";
        fsType = "btrfs";
        options = [ "subvol=@var" ] ++ BTRFS_OPTS;
      };

      "/nix" = {
        device = "/dev/disk/by-partlabel/disk-vda-NixOS";
        # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
        fsType = "btrfs";
        options = [ "subvol=@nix" ] ++ BTRFS_OPTS;
      };

      "/boot" = {
        device = "/dev/disk/by-partlabel/ESP";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
          "defaults"
          "noatime"
          "nodiratime"
          "x-gvfs-hide" # hide from filemanager
        ];
      };
    };

  swapDevices = [
    {
      # device = "/var/swap/swapfile";
      # device = "/dev/disk/by-label/swap";
      device = "/dev/disk/by-partlabel/disk-vda-SWAP";
      # size = "20G";
    }
  ];

  hardware = {
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
  };
}
