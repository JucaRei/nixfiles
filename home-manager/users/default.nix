{ lib
, username
  # , pkgs
, config
, ...
}:
let
  # inherit (pkgs.stdenv) isLinux;
  inherit (lib) optional;
in
{
  imports = optional (builtins.pathExists (./. + "/${username}")) ./${username};
}
