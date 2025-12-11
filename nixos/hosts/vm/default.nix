{ modulesPath, lib, config, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    boot = {
      initrd = {
        availableKernelModules = [
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

      loader = {
        grub = {
          enable = true;
          devices = [ "/dev/sda" ];
        };
      };
    };

    fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    nixpkgs = {
      hostPlatform = "x86_64-linux";
    };

    hardware.audio = {
      enable = true;
      manager = "pipewire";
    };
  };
}
