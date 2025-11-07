{ pkgs ? (import ./nixpkgs.nix) { }, ... }:
{
  default = pkgs.mkShell {
    name = "Flakes SHELL";
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      git
      home-manager
      nil
      nixpkgs-fmt
      duf
      nix-direnv
      direnv
      # dropbear # ssh server
      # nix-output-monitor # better output from builds
      # micro
      # nh
      # nixfmt
      # nixd # lsp server

      vscode-fhs
      nix

      figlet
      lolcat
    ];
    shellHook = ''
      # exec fish
      # alias ssh="dbclient"
      echo "🔨 Welcome to flakes" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
      echo ">>>> ❄️ Entering Nix Development Environment"
    '';
  };
}
