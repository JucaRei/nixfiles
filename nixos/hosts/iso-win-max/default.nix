{ lib, ... }:
{
  imports = [
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/hardware/misc/gpd-win-max.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
