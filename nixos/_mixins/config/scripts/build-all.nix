{ pkgs }:

pkgs.writeScriptBin "build-all" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    pushd $HOME/.dotfiles/nixfiles 2>&1 > /dev/null
    echo "Building NixOS with $build_cores cores"
    nixos-rebuild build --flake .# -L --cores $build_cores
    echo "Building Home Manager with $build_cores cores"
    ${pkgs.home-manager}/bin/home-manager build --flake $HOME/.dotfiles/nixfiles -L --impure --cores $build_cores
    popd 2>&1 > /dev/null
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
