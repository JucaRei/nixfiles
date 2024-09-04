{ config, pkgs, hostname, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  home-build = import ../../resources/scripts/nix/home-build.nix { inherit pkgs; };
  home-switch = import ../../resources/scripts/nix/home-switch.nix { inherit pkgs; };
  gen-ssh-key = import ../../resources/scripts/nix/gen-ssh-key.nix { inherit pkgs; };
  home-manager_change_summary = import ../../resources/scripts/nix/home-manager_change_summary.nix { inherit pkgs; };
  samba = import ./_mixins/config/scripts/samba.nix { inherit pkgs; };


  cfg = config.services.nonNixOs;
  isOld = if (hostname == "oldarch") then false else true;
  isGeneric = if (config.services.nonNixOs.enable) then true else false;
in
{ }
