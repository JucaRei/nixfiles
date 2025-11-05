{ config, pkgs, inputs, outputs, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  imports = with inputs; [ ];
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
