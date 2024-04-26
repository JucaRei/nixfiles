{ pkgs }:

pkgs.writeScriptBin "switch-all" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "Switching NixOS with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh os switch ~/.dotfiles/nixfiles -- --cores $build_cores
    echo "Switching Home Manager with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh home switch ~/.dotfiles/nixfiles/ -- --impure --cores $build_cores
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
