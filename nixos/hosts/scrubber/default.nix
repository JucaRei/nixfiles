{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # (import ./disks.nix { })
    # (import ./disks-bcache.nix { })
    (import ./disks-btrfs.nix { })
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
}
