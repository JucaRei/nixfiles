# Dual boot with win10 https://github.com/ksevelyar/carbicide
{ pkgs, lib, ... }: {
  imports = [
    ../../services/network/multiboot.nix
  ];
  boot.loader = {
    grub.useOSProber = lib.mkForce true;
  };
  environment.systemPackages = with pkgs; [
    os-prober
  ];
}
