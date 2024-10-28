{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # (import ./disks.nix { })
    (import ./disks-bcachefs.nix { })
  ];

  config = {
    boot = {
      initrd.availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        # "virtio_blk"
        # "usbhid"
        "sr_mod"
        "sd_mod"
      ];
    };

    features.zram.enable = true;
  };
}
