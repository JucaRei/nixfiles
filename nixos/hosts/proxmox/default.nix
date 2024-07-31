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

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/f8e74554-58c0-4b4e-a364-b14d137f324d";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/D4B8-378E";
      fsType = "vfat";
    };

  swapDevices = [ ];

  services.proxmox-ve.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
