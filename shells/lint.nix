{ pkgs, ... }:

pkgs.mkShellNoCC {
  nativeBuildInputs = with pkgs; [
    actionlint
    selene
    stylua
    statix
    nixpkgs-fmt
    nixfmt-rfc-style # Nix code formatter
    nil
    yamllint
  ];
}
