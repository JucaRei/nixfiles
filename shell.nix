# Shell for bootstrapping flake-enabled nix and home-manager
# Enter it through 'nix develop' or (legacy) 'nix-shell'
{ pkgs ? (import ./nixpkgs.nix) { } }:
with pkgs;
let
  nixBin = writeShellScriptBin "nix" ''
    ${nixVersions.stable}/bin/nix --option experimental-features "nix-command flakes" "$@"
  '';
in
{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      # jq
      cachix
      alejandra
      home-manager
      dropbear
      speedtest-cli
      direnv
      zsh
      git
      nil
      duf
      htop
      nixpkgs-fmt
      nixfmt
      nix-output-monitor
      #fira-code-nerdfont
      # neofetch
    ];
    shellHook = ''
      alias ssh=dbclient
      export FLAKE="$(pwd)"
      export PATH="$FLAKE/bin:${nixBin}/bin:$PATH"
      echo "
      . _____   _           _
      |  ____| | |         | |
      | |__    | |   __ _  | | __   ___   ___
      |  __|   | |  / _\` | | |/ /  / _ \ / __|
      | |      | | | (_| | |   <  |  __/ \\__ \\
      |_|      |_|  \__,_| |_|\_\  \___| |___/
          "
    '';
  };
}
