{ ... }: {
  imports = [ ./filesystem.nix ];

  boot = {
    availableKernelModules = [
      "xhci_pci" # USB 3.0
      "ahci" # SATA devices on modern AHCI controllers
      "nvme"
      "usb_storage" # USB mass storage devices
      "usbhid" # USB human interface devices
      "sd_mod" # SCSI, SATA, and IDE devices
      "rtsx_pci_sdmmc"
      "aesni_intel"
      "cryptd"
    ];
  };
}
