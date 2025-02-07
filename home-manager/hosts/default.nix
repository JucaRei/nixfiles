{ lib, hostname, pkgs, ... }:
let
  home-build = import ../../resources/hm-configs/nix/home-build.nix { inherit pkgs; };
  home-switch = import ../../resources/hm-configs/nix/home-switch.nix { inherit pkgs; };
  home-manager_change_summary = import ../../resources/hm-configs/nix/home-manager_change_summary.nix { inherit pkgs; };
in
{
  imports = lib.optional (builtins.pathExists (./. + "/${hostname}")) ./${hostname};

  home.packages = with pkgs; [
    home-build
    home-switch
    home-manager_change_summary
  ];
}
