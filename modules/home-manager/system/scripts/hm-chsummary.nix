{ pkgs, ... }:

pkgs.writeShellScriptBin "hm-chsummary" ''
    BUILDS=$(${pkgs.uutils-coreutils-noprefix}/bin/ls -d1v ''${XDG_STATE_HOME}/nix/profiles/home-manager-*-link | tail -n 2)
  ${pkgs.nvd}/bin/nvd diff ''${BUILDS}
''
