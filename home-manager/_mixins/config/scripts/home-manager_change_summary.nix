{pkgs, ...}: let
  home-manager_change_summary = pkgs.writeShellScriptBin "home-manager_change_summary" ''
      BUILDS=$(${pkgs.coreutils-full}/bin/ls -d1v ''${XDG_STATE_HOME}/nix/profiles/home-manager-*-link | tail -n 2)
    ${pkgs.nvd}/bin/nvd diff ''${BUILDS}
  '';
  # sudo ${pkgs.nvd}/bin/nvd diff ''${BUILDS}
in {home.packages = with pkgs; [home-manager_change_summary];}
