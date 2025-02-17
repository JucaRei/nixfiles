{ pkgs ? inputs.nixpkgs-unstable.pkgs, inputs, namespace, ... }:
let
  inherit (inputs) snowfall-flake;
in
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

    #  Adds all the packages required for the pre-commit checks
    # inputs.self.checks.${system}.pre-commit-hooks.enabledPackages

    figlet
    lolcat
  ];

  shellHook = ''
    # exec fish
    alias ssh="dbclient"
    echo "🔨 Welcome to flakes" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
    echo ">>>> ❄️ Entering Nix Development Environment"
    echo 🔨 Welcome to ${namespace}

  '';
}
