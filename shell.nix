# Shell for bootstrapping flake-enabled nix and home-manager
# Enter it through 'nix develop' or (legacy) 'nix-shell'

{ pkgs ? (import ./nixpkgs.nix) { } }:

{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    packages = with pkgs; [
      bash-completion # completion for bash
      nix-direnv # A shell extension that manages your environment for nix
      direnv
      neofetch # check system
      duf # check space
      nix-bash-completions # complitions for nix
      speedtest-cli # test connection speed
    ];
    nativeBuildInputs = with pkgs; [
      nix # nix
      nil # lsp server
      nixpkgs-fmt # formatter
      home-manager # manage dots
      git # versioning
      nix-output-monitor # better output from builds
      cachix # build and share cache
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
  };
}
