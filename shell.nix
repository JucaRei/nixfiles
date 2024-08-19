# Shell for bootstrapping flake-enabled nix and home-manager
# Enter it through 'nix develop' or (legacy) 'nix-shell'

{ pkgs ? (import ./nixpkgs.nix) { }, ... }:
{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes repl-flake";
    nativeBuildInputs = with pkgs; [
      git
      home-manager # manage dots
      duf # check space
      nix-output-monitor # better output from builds
      nix-direnv # A shell extension that manages your environment for nix
      # dropbear # ssh
      figlet
      lolcat
    ];

    shellHook = ''
      # alias ssh="dbclient"
      echo "Flakes!" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
    '';
  };
}
