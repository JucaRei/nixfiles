{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./disk-default.nix
    # ./disko-btrfs.nix
  ];

  config = {
    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        kernelModules = [ ];
      };

      kernelModules = [
        # "kvm-intel"
      ];
      extraModulePackages = [ ];
    };

    hardware.graphics.cards = {
      enable = true;
      acceleration = true;
      gpu = "hybrid-nvidia";
    };
  };
}
