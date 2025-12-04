{ inputs, lib, config, pkgs, modulesPath, hostname, username, stateVersion, ... }:
let
  inherit (lib) optional;
in
{
  # You can import other NixOS modules here
  imports = [
    ./users
  ] ++
  optional (builtins.pathExists ./hosts/${hostname}) ./hosts/${hostname};
}
