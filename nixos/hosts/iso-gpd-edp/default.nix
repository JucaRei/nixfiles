{lib, ...}: {
  # Pocket 2, Win 2, Win Max
  imports = [
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/hardware/misc/gpd-edp.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
