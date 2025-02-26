{ modulesPath, lib, config, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ./disks.nix { })
    # (import ./disks-xfs.nix { })
    # (import ./disks-bcache.nix { })
    # (import ./disks2.nix { })
    # ./filesystem.nix
  ];

  config = {

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
          efiInstallAsRemovable = mkForce true;
        };
        efi = {
          efiSysMountPoint = mkForce "/boot";
          canTouchEfiVariables = mkForce false;
        };
      };
    };

    system.services.zram = {
      enable = true;
    };

    nixpkgs = {
      hostPlatform = "x86_64-linux";
    };
  };
}


# nix run github:nix-community/nixos-anywhere -- --flake .#scrubber --target-host root@192.168.122.105
