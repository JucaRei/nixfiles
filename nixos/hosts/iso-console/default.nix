{ lib, ... }: {
  imports = [
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
  ];

  boot.zfs.enabled = lib.mkForce false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
