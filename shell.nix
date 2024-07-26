# Shell for bootstrapping flake-enabled nix and home-manager
# Enter it through 'nix develop' or (legacy) 'nix-shell'

{ pkgs ? (import ./nixpkgs.nix) { }, ... }:

# with pkgs; let
#   nixBin = writeShellScriptBin "nix" ''
#     ${nixVersions.stable}/bin/nix --option experimental-features "nix-command flakes" "$@"
#   '';
# in
{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix # nix
      nil # lsp server
      nix-direnv # A shell extension that manages your environment for nix
      home-manager # manage dots
      duf # check space
      nixpkgs-fmt # formatter
      git # versioning
      nix-output-monitor # better output from builds
      dropbear # ssh
    ];
    # ++ inputs.pkgs.legacyPackages.${system}.pinix

    shellHook = ''
      alias ssh="dbclient"
      echo "
        . _____   _           _
        |  ____| | |         | |
        | |__    | |   __ _  | | __   ___   ___
        |  __|   | |  / _\` | | |/ /  / _ \ / __|
        | |      | | | (_| | |   <  |  __/ \\__ \\
        |_|      |_|  \__,_| |_|\_\  \___| |___/
      "
    '';
    #   shellHook = ''
    #     export FLAKE="$(pwd)"
    #     export PATH="$FLAKE/bin:${nixBin}/bin:$PATH"
    #   '';
    # }
  };
}
