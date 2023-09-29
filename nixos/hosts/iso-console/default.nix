{ lib, ... }:
{
  imports = [
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
