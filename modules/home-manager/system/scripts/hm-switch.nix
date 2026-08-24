{ pkgs, ... }:

pkgs.writeScriptBin "hm-switch" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "Building Nix Home-manager 🏠️ with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh home switch --backup-extension backup ~/.dotfiles/nixfiles/ -- --impure --show-trace -vL --cores $build_cores
    echo "🧹 Cleaning old generations (keeping last 5)..."
    ${pkgs.unstable.nh}/bin/nh clean all --keep 5
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
