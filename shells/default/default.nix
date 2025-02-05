{
  pkgs ? inputs.nixpkgs-unstable.pkgs,
  inputs,
  ...
}:
pkgs.mkShell {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";

  packages = with pkgs; [
    nh
    inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere
    statix
    deadnix
    alejandra
    nixd
    nil
    nixpkgs-fmt
    nixfmt-rfc-style
    home-manager
    git
    duf
    htop
    # sops
    # ssh-to-age
    # gnupg
    # age
  ];
}
