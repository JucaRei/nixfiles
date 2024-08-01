{ config, lib, pkgs, modulesPath, ... }: {
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      (import ./disks.nix { })
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  # boot.loader.grub.devices = [ "nodev" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  # boot.mode.bios.enable = true;
  # boot.loader.grub.device = lib.mkForce "/dev/vda";

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-partlabel/disk-vda-root";
        fsType = "xfs";
        options = [ "defaults" "relatime" "nodiratime" ];
      };

    "/boot" =
      {
        device = "/dev/disk/by-partlabel/disk-vda-ESP";
        fsType = "vfat";
        options = [ "defaults" "noatime" "nodiratime" ];
      };
  };

  swapDevices = [
    # { device = "/dev/disk/by-partlabel/disk-sda-swap"; }
  ];

  programs = {
    fish.enable = true;
  };

  services.proxmox-ve.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
