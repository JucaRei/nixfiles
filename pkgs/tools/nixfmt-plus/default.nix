{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "nixfmt-plus";
  runtimeInputs = with pkgs; [
    deadnix
    nixpkgs-fmt
    statix
  ];
  text = ''
    set -x
    deadnix --edit
    statix fix
    nixfmt .
  '';
}
