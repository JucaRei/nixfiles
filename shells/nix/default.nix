{
  inputs,
  mkShell,
  pkgs,
  system,
  namespace,
  ...
}:
let
  inherit (inputs) snowfall-flake;
in
mkShell {
  packages = with pkgs; [
    deadnix
    hydra-check
    nix-inspect
    nix-bisect
    nix-diff
    nix-health
    nix-index
    # FIXME: broken nixpkgs
    # nix-melt
    nix-prefetch-git
    nix-search-cli
    nix-tree
    nix-update
    nixpkgs-hammering
    nixpkgs-lint
    nixpkgs-review
    snowfall-flake.packages.${system}.flake
    statix

    figlet
    lolcat
  ];

  shellHook = ''
    echo "🔨 Welcome to ${namespace}" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300


  '';
}