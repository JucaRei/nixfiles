{ lib, username, pkgs, ... }:
let
  # inherit (pkgs.stdenv) isLinux;
  inherit (lib) optional optionals;
  isOtherOS = if builtins.isString (builtins.getEnv "__NIXOS_SET_ENVIRONMENT_DONE") then false else true;
  build-all = import ../../resources/nixos/scripts/build-all.nix { inherit pkgs; };
  switch-all = import ../../resources/nixos/scripts/switch-all.nix { inherit pkgs; };
in
{
  imports = optional (builtins.pathExists (./. + "/${username}")) ./${username};

  home.packages = with pkgs; [ ]
    ++ optionals (!isOtherOS) [ build-all switch-all ];

}
