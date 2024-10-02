{ pkgs }:

pkgs.writeScriptBin "switch-all" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "Switching NixOS ❄️ with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh os switch $HOME/.dotfiles/nixfiles -- --cores $build_cores
    echo "Switching Home Manager with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh home switch --backup-extension backup $HOME/.dotfiles/nixfiles/ -- --impure --cores $build_cores
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nixfiles found in $HOME/.dotfiles/nixfiles"
  fi
''
