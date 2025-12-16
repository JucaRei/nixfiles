{ pkgs, lib, ... }: {
  programs.fish.enable = true;
  apps = {
    console.ssh.enable = true;
    graphical.terminal.alacritty.enable = true;
  };
}
