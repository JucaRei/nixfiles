{ inputs
, mkShell
, pkgs
, system
, namespace
, ...
}:
let
  inherit (inputs) snowfall-flake;
in
mkShell {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  packages = with pkgs; [
    nix-tree
    nil
    nixfmt-rfc-style
    nixpkgs-hammering
    nixpkgs-lint
    snowfall-flake.packages.${system}.flake
    deploy-rs
    nh

    # Adds all the packages required for the pre-commit checks
    # inputs.self.checks.${system}.pre-commit-hooks.enabledPackages

    figlet
    lolcat
  ];

  shellHook = ''
    # ${inputs.self.checks.${system}.pre-commit-hooks.shellHook}
    echo "🔨 Welcome to ${namespace}" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300


  '';
}
