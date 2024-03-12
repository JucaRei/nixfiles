{ lib, ... }: {
  imports = [
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/apps/text-editor/vscode.nix
    ../../_mixins/virtualization/podman.nix
  ];

  boot.kernelParams = [ "nomodeset" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
