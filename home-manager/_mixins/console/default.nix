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
}
