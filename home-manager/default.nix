{ config, pkgs, inputs, outputs, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  imports = with inputs; [ ../modules/home-manager ];
  nixpkgs = {
    overlays = with outputs; [
      overlays.localPackages
      overlays.modifiedPackages
      overlays.unstablePackages
      overlays.oldstablePackages
      # Add more overlays here as needed
    ];
  };
}
