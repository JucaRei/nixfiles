{ lib, ... }:
let
  currentDir = ./.; # Represents the current directory
  isDirectoryAndNotTemplate = name: type: type == "directory";
  directories = lib.filterAttrs isDirectoryAndNotTemplate (builtins.readDir currentDir);
  importDirectory = name: import (currentDir + "/${name}");
in
{
  imports = lib.mapAttrsToList (name: _: importDirectory name) directories;

  boot = {
    kernel.sysctl = {
      "vm.dirty_ratio" = 10; # sync disk when buffer reach 6% of memory
    };
  };
}
