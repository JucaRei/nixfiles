{ lib, ... }:
{
  # Pocket, Pocket 3, MicroPC, Win 3, TopJoy Falcon
  imports = [
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/hardware/misc/gpd-dsi.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
