# _: {
#   imports = [
#     ./ananicy.nix
#     ./fwupd.nix
#     # ./check-updates.nix
#     ./irqbalance.nix
#     ./runners.nix
#     ./psd.nix
#     ./thermald.nix
#   ];
# }

{ lib, ... }:
let
  currentDir = ./.; # Represents the current directory
  isDirectoryAndNotTemplate = name: type: type == "directory";
  directories = lib.filterAttrs isDirectoryAndNotTemplate (builtins.readDir currentDir);
  importDirectory = name: import (currentDir + "/${name}");
in
{
  imports = lib.mapAttrsToList (name: _: importDirectory name) directories;
}
