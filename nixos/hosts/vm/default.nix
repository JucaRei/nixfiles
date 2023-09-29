{ lib, modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ./disks.nix { })
    ../../_mixins/hardware/boot/systemd-boot.nix
    ../../_mixins/hardware/sound/pipewire.nix
  ];

  swapDevices = [{
    device = "/swap";
    size = 1024;
  }];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ohci_pci" "ehci_pci" "virtio_pci" "ahci" "usbhid" "sr_mod" "virtio_blk" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
