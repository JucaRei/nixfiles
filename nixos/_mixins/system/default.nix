{ lib, isWorkstation, pkgs, ... }:
let
  inherit (lib) optionals;

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

  services = {
    userborn.enable = true;

    dbus = {
      packages = optionals isWorkstation (with pkgs ; [ gnome-keyring gcr ]);
      implementation = if isWorkstation then "broker" else "dbus";
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" # symlink executable's to normal linux path
  ];
}
