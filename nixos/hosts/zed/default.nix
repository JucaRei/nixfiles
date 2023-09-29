{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z13
    (import ./disks.nix { })
    ../../_mixins/hardware/boot/systemd-boot.nix
    ../../_mixins/hardware/bluetooth
    ../../_mixins/services/tools/maestral.nix
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/services/network/tailscale.nix
    ../../_mixins/services/network/zerotier.nix
    ../../_mixins/virtualization
  ];

  swapDevices = [{
    device = "/swap";
    size = 2048;
  }];

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "sdhci_pci"
        "uas"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];
    };
    kernelModules = [ "amdgpu" "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  services.kmscon.extraConfig = lib.mkForce ''
    font-size=18
    xkb-layout=gb
  '';

  environment.systemPackages = with pkgs; [
    nvtop-amd
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
