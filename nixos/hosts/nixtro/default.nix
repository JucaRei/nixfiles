{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkForce;
in
{
  imports = [
    ./disk-default.nix
    # ./disko-btrfs.nix
  ];

  config = {
    timeZone = mkForce "America/Sao_Paulo";

    programs = {
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          # Add any missing dynamic libraries for unpackaged
          # programs here, NOT in environment.systemPackages
        ];
      };
    };

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

    hardware = {
      cpu = {
        enable = true;
        hardenKernel = true;
        improveTCP = true;
        enableKvm = true;
        cpuVendor = "intel";
      };

      audio = {
        enable = true;
        manager = "pipewire";
      };

      graphics.cards = {
        enable = true;
        acceleration = true;
        gpu = "hybrid-nvidia";
      };
    };
  };
}
