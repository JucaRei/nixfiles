{ pkgs, lib, desktop, hostname, config, ... }:
with lib;
let
  # build-home = import ../config/scripts/build-home.nix { inherit pkgs; };
  isWorkstation = if (desktop != null) then true else false;
in
{
  imports = [
    ./alias_core
    ./aria2
    ./atuin
    ./bash
    ./bat
    ./bottom
    ./btop
    ./cava
    ./dircolors
    ./direnv
    ./eza
    ./fastfetch
    ./fish
    ./fzf
    ./git
    ./github-cli
    ./gitUI
    ./glow
    ./gpg
    ./htop
    ./lsd
    ./man
    ./micro
    ./mpd
    ./nano
    ./ncmpcpp
    ./neofetch
    ./neovim
    ./powerline-go
    ./properties
    ./ripgrep
    ./skim
    ./ssh
    ./starship
    ./yazi
    ./yt-dlp
    ./zoxide
  ];

  home.packages = with pkgs; [
    # build-home
  ];

  programs = mkDefault {
    mpd.enable = false;
    nano.enable = false;
  };

  services = mkDefault {
    aliases.enable = true;
    aria2.enable = false;
    atuin.enable = false;
    bash.enable = if (hostname == "vm") then true else false;
    btop.enable = false;
    bottom.enable = false;
    bat.enable = true;
    cava.enable = false;
    direnv.enable = true;
    dircolors.enable = false;
    fzf.enable = false;
    fish.enable = if (hostname == "vm") then false else true;
    fastfetch.enable = true;
    eza.enable = isWorkstation;
    gpg.enable = false;
    glow.enable = false;
    git.enable = true;
    gitui.enable = isWorkstation;
    github-cli.enable = false;
    htop.enable = true;
    lsd.enable = false;
    powerline-go.enable = if (config.services.fish.enable) then true else false;
    ripgrep.enable = true;
    micro.enable = true;
    man.enable = true;
    mpd.enable = false;
    neovim.enable = false;
    neofetch.enable = true;
    ncmpcpp.enable = false;
    starship.enable = false;
    ssh.enable = true;
    skim.enable = false;
    yt-dlp-custom.enable = isWorkstation;
    yazi.enable = false;
    zoxide.enable = true;
  };
}
