{ pkgs, ... }:
let
  # build-home = import ../config/scripts/build-home.nix { inherit pkgs; };
in
{
  imports = [
    ./bat
    ./btop
    ./fish
    ./htop
    ./lsd
    ./yazi
    # ./aliases.nix
    ./alias_core.nix
    ./aria2.nix
    ./atuin.nix
    ./bash.nix
    ./bottom.nix
    ./cava.nix
    ./dircolors.nix
    ./direnv.nix
    ./eza.nix
    ./fastfetch.nix
    ./git.nix
    ./github-cli.nix
    ./gitui.nix
    ./glow.nix
    ./gpg.nix
    ./micro.nix
    ./mpd.nix
    ./ncmpcpp.nix
    # ./nano.nix
    # ./neofetch.nix
    # ./neovim.nix
    ./ripgrep.nix
    ./skim.nix
    ./ssh.nix
    ./yt-dlp.nix
  ];

  home.packages = with pkgs; [
    # build-home
  ];
}
