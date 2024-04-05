{ pkgs, config, lib, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
in
{

  home = {
    packages = with pkgs; [
      ### Window
      bpswm
      wmname
      sxhkd
      dunst
      betterlockscreen

      ### File Manager
      gnome.gvfs # Virtual Filesystem support library
      cifs-utils # Tools for managing Linux CIFS client filesystems
    ];
  };
}
