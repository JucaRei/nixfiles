{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  nixCapped = pkgs.callPackage ./pkgs/tools/nix-capped { };
  nixCheckCapped = pkgs.callPackage ./pkgs/tools/nix-check-capped { nix-capped = nixCapped; };
  nx = pkgs.callPackage ./pkgs/tools/nx { };
  shell = pkgs.mkShell {
    name = "Flakes SHELL";
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      git
      nil
      statix
      deadnix
      shellcheck
      home-manager
      (pkgs.nixfmt or pkgs.nixfmt-tree)
      nix-direnv
      direnv
      htop
      duf
      # dropbear # ssh server
      nix-output-monitor # better output from builds
      nx
      nixCapped
      nixCheckCapped
      # micro
      # nh
      # nixfmt
      # nixd # lsp server

      # vscode-fhs
      # nix

      figlet
      lolcat
    ];
    shellHook = ''
      # exec fish
      # alias ssh="dbclient"
      alias nfc="nix-check-capped"
      alias check="nix-check-capped"
      alias nfc60="nix-check-capped"
      alias check60="nix-check-capped"
      echo "🔨 Welcome to flakes" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
      echo ">>>> ❄️ Entering Nix Development Environment"
      echo ">>>> 💡 Execute 'nfc' para 'nix flake check --no-build' (50% de CPU, 50% de RAM e até 60% de swap; use NX_LOW_MEMORY=1 para modo econômico)."
      echo ">>>> 💡 Execute 'nix-capped <comando>' para rodar qualquer verificação dentro do limite."
    '';
  };
in
shell
