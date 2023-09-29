{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.gpd-micropc
    (import ./disks.nix { })
    ../../_mixins/hardware/boot/systemd-boot.nix
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/services/network/zerotier.nix
    ../../_mixins/virtualization
  ];

  swapDevices = [{
    device = "/swap";
    size = 2048;
  }];

  boot = {
    initrd.availableKernelModules = [
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
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # My GPD MicroPC has a US keyboard layout
  console.keyMap = lib.mkForce "us";
  services.kmscon.extraConfig = lib.mkForce ''
    font-size=14
    xkb-layout=us
  '';
  services.xserver.layout = lib.mkForce "us";

  environment.systemPackages = with pkgs; [
    nvtop-amd
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
