{ config, lib, pkgs, modulesPath, ... }: {
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      (import ./disks.nix { })
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-partlabel/disk-sda-root";
        fsType = "xfs";
        options = [ "defaults" "relatime" "nodiratime" ];
      };

    "/boot" =
      {
        device = "/dev/disk/by-partlabel/disk-sda-ESP";
        fsType = "vfat";
        options = [ "defaults" "noatime" "nodiratime" ];
      };
  };

  swapDevices = [ ];

  services.proxmox-ve.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}