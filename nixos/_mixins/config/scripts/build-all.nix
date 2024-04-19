{ pkgs }:

pkgs.writeScriptBin "build-all" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "Building NixOS with $build_cores cores"
    nh os switch --ask ~/.dotfiles/nixfiles/ -- --cores $build_cores
    echo "Building Home Manager with $build_cores cores"
    nh home switch --ask ~/.dotfiles/nixfiles/ -- --impure --cores $build_cores
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
