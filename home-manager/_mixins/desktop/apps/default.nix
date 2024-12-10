{ lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;

  currentDir = ./.; # Represents the current directory
  isDirectoryAndNotTemplate = name: type: type == "directory" && name != "_template";
  directories = lib.filterAttrs isDirectoryAndNotTemplate (builtins.readDir currentDir);
  importDirectory = name: import (currentDir + "/${name}");
in
{
  imports = lib.mapAttrsToList (name: _: importDirectory name) directories;

  home = {
    packages = with pkgs; lib.optionals isLinux [
      glide-media-player # video player
      unstable.decibels # audio player
      gnome.gnome-calculator # calcualtor
      loupe # image viewer
      papers # document viewer
    ];
  };
}
