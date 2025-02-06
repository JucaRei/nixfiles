{ pkgs ? (import ./nixpkgs.nix) { }, ... }:
# let
#   nixfmt-plus = pkgs.callPackage import ./pkgs/tools/nixfmt-plus { };
# in

{
  default = pkgs.mkShell {
    name = "dots flake ";
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";

    nativeBuildInputs = with pkgs; [
      vscode-fhs
      nix # nix
      nil # lsp server
      nixd
      direnv
      nix-direnv # A shell extension that manages your environment for nix
      home-manager # manage dots
      duf # check space
      nixpkgs-fmt # formatter
      git # versioning
      nix-output-monitor # better output from builds
      nh
      dropbear # ssh

      figlet
      lolcat
    ];

    shellHook = ''
      # exec fish
      export NIXPKGS_ALLOW_UNFREE=1
      alias ssh="dbclient"
      echo "🔨 Welcome to flakes" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
      echo ">>>> ❄️ Entering Nix Development Environment"
    '';
  };
}
