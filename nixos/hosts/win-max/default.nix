{ inputs, lib, pkgs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    (import ./disks.nix { })
    ../../_mixins/hardware/misc/gpd-win-max.nix
    ../../_mixins/hardware/boot/systemd-boot.nix
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/services/network/zerotier.nix
    ../../_mixins/games/steam.nix
  ];

  swapDevices = [{
    device = "/swap";
    size = 2048;
  }];

  boot = {
    initrd.availableKernelModules =
      [ "xhci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  environment.systemPackages = with pkgs; [ nvtop-amd ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
