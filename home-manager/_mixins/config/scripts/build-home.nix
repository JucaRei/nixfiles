{ pkgs }:

pkgs.writeScriptBin "build-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    pushd $HOME/.dotfiles/nixfiles 2>&1 > /dev/null
    echo "Building Home-manager nix with $build_cores cores"
    home-manager switch -b backup --flake .# -L --impure --cores $build_cores
    popd 2>&1 > /dev/null
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
