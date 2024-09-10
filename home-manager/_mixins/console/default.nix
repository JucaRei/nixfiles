{ pkgs, lib, desktop, hostname, config, isWorkstation, ... }:
let
  inherit (lib) mkDefault;
  currentDir = ./.; # Represents the current directory
  isDirectoryAndNotTemplate = name: type: type == "directory";
  directories = lib.filterAttrs isDirectoryAndNotTemplate (builtins.readDir currentDir);
  importDirectory = name: import (currentDir + "/${name}");
in
{
  imports = lib.mapAttrsToList (name: _: importDirectory name) directories;

  custom = {
    programs = {
      mpd.enable = mkDefault false;
      nano.enable = mkDefault false;
      git.enable = mkDefault true;
      gpg.enable = mkDefault false;
      ncmpcpp.enable = mkDefault true;
      yt-dlp-custom.enable = isWorkstation;
    };

    console = {
      aliases.enable = mkDefault true;
      aria2.enable = mkDefault false;
      atuin.enable = mkDefault false;
      bash.enable = if (hostname == "vm") then mkDefault true else mkDefault false;
      btop.enable = mkDefault false;
      bottom.enable = mkDefault false;
      bat.enable = mkDefault true;
      cava.enable = mkDefault false;
      direnv.enable = mkDefault true;
      dircolors.enable = mkDefault false;
      fzf.enable = mkDefault false;
      fish.enable = if (hostname == "vm") then mkDefault false else mkDefault true;
      fastfetch.enable = mkDefault true;
      eza.enable = isWorkstation;
      glow.enable = mkDefault false;
      gitui.enable = isWorkstation;
      github-cli.enable = mkDefault false;
      htop.enable = mkDefault true;
      lsd.enable = mkDefault false;
      powerline-go.enable = if (config.custom.console.fish.enable) then mkDefault true else mkDefault false;
      ripgrep.enable = mkDefault true;
      micro.enable = mkDefault true;
      man.enable = mkDefault true;
      neofetch.enable = mkDefault true;
      starship.enable = mkDefault false;
      ssh.enable = mkDefault true;
      skim.enable = mkDefault false;
      yazi.enable = mkDefault false;
      zoxide.enable = mkDefault true;
    };
  };
}
