{ pkgs ? (import ./nixpkgs.nix) { }, ... }:

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
      # nix-output-monitor # better output from builds
      nh
      dropbear # ssh

      figlet
      lolcat
    ];

    shellHook = ''
      alias ssh="dbclient"
      echo "🔨 Welcome to flakes" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
    '';
  };
}
