{ pkgs }:

pkgs.writeScriptBin "build-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "Building NixOS with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh os switch --ask ~/.dotfiles/nixfiles/ -- --show-trace --cores $build_cores
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No Nix configurations found in $HOME/.dotfiles/nixfiles"
  fi
''
