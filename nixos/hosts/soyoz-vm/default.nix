{ modulesPath, lib, inputs, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # (import ./disks.nix { })
    # (import ./disks-btrfs.nix { })
    (import ./disks-xfs.nix { })
    # ./filesystem.nix
    inputs.vscode-server.nixosModules.default
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

      loader = {
        grub = {
          device = mkForce "/dev/vda";
          # efiInstallAsRemovable = mkForce true;
        };
        # efi = {
        #   efiSysMountPoint = mkForce "/boot";
        #   canTouchEfiVariables = mkForce false;
        # };
      };
      # supportedFilesystems.bcachefs = mkForce true;
    };

    system = {
      boot = {
        boottype = mkForce "legacy";
      };
      services.zram = {
        enable = true;
      };
    };

    nixpkgs = {
      hostPlatform = "x86_64-linux";
    };

    services = {
      vscode-server = {
        enable = true;
      };
      smartd = {
        enable = mkForce false;
      };
    };

    # features = {
    # bcachefs.enable = true;
    # };
  };
}
