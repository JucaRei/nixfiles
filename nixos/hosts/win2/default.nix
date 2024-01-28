{ inputs, lib, pkgs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.gpd-win-2
    (import ./disks.nix { })
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

  # My GPD Win2 has a US keyboard layout
  console.keyMap = lib.mkForce "us";
  services.kmscon.extraConfig = lib.mkForce ''
    font-size=14
    xkb-layout=us
  '';
  services.xserver.layout = lib.mkForce "us";

  environment.systemPackages = with pkgs; [ nvtop-amd ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
