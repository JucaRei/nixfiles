{lib, ...}: {
  imports = [
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
  ];

  boot.kernelParams = ["nomodeset"];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
