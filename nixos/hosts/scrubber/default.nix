{ modulesPath, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # (import ./disks.nix { })
    # (import ./disks-bcache.nix { })
    # (import ./disks2.nix { })
    ./filesystem.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ohci_pci"
      "ehci_pci"
      "virtio_pci"
      "ahci"
      "usbhid"
      "sr_mod"
      "virtio_blk"
    ];

    loader = {
      grub = {
        efiInstallAsRemovable = mkForce false;
      };
      efi = {
        efiSysMountPoint = mkForce "/boot";
        canTouchEfiVariables = mkForce true;
      };
    };
  };

  core = {
    boot = {
      bootmanager = mkForce "grub";
    };
  };
}
