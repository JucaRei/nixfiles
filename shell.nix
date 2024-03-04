# Shell for bootstrapping flake-enabled nix and home-manager
# Enter it through 'nix develop' or (legacy) 'nix-shell'

{ pkgs ? (import ./nixpkgs.nix) { } }:

{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix # nix
      nil # lsp server
      nixpkgs-fmt # formatter 
      home-manager # manage dots
      git # versioning
      nix-output-monitor # better output from builds
      duf # check space
      cachix # build and share cache
      neofetch # check system
      speedtest-cli # test connection speed
      dropbear # ssh 
      nix-direnv # A shell extension that manages your environment for nix
      bash-completion # completion for bash
      nix-bash-completions # complitions for nix
    ]
      # ++ inputs.pkgs.legacyPackages.${system}.pinix
    ;
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
