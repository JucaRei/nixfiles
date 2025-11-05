{ pkgs ? (import ./nixpkgs.nix) { }, ... }:
{
  teste = pkgs.mkShell {
    name = "Testing Shell";
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      git
      duf
      neofetch
      htop
      # nil
      # nixpkgs-fmt
      # home-manager
      # dropbear # ssh server
      # nix-output-monitor # better output from builds
      # micro
      # nh
      # nixfmt
      # nixd # lsp server

      figlet
      lolcat
    ];
    shellHook = ''
      # exec fish
      # alias ssh="dbclient"
      echo "TESTING SHELL" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
      echo ">>>> ❄️ Entering Nix Development Environment"
    '';
  };
}
