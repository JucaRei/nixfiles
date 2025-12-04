{ lib, username, hostname, ... }:
let
  inherit (lib) optional;
in
{
  imports = [ ../modules/home-manager ]
    ++ optional (builtins.pathExists ./users/${username}) ./users/${username}
    ++ optional (builtins.pathExists ./hosts/${hostname}) ./hosts/${hostname};
}
