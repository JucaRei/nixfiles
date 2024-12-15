{ pkgs, ... }:
{
  home.packages = with pkgs ; [
    cloneit
    typora
    unstable.obsidian
    deluge-gtk
    nil
    nixpkgs-fmt
    unstable.mpv
  ];
}
