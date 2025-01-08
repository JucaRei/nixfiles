{ modulesPath, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # (import ./disks.nix { })
    # (import ./disks-bcache.nix { })
    (import ./disks2.nix { })
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

  };

  core = {
    boot = {
      bootmanager = mkForce "systemd-boot";
    };
  };
}
