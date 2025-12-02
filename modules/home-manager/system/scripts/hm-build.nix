{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  home.packages = [
    (pkgs.writeScriptBin "hm-build" ''
      #!${pkgs.stdenv.shell}

      if [ -e $HOME/.dotfiles/nixfiles ]; then
        all_cores=$(nproc)
        build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
        echo "Building Nix Home-manager 🏠️ with $build_cores cores"
        ${pkgs.unstable.nh}/bin/nh home build ~/.dotfiles/nixfiles/ -- --impure --show-trace -vL --cores $build_cores
      else
        ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nixfiles found in $HOME/.dotfiles/nixfiles"
      fi
    '')
  ];
}

