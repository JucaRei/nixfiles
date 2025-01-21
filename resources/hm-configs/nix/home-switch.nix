{ pkgs }:

pkgs.writeScriptBin "home-switch" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.coreutils-full}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "Building Nix Home-manager 🏠️ with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh home switch --backup-extension backup ~/.dotfiles/nixfiles/ -- --impure --show-trace -vL --cores $build_cores
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
