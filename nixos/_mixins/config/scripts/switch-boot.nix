{ pkgs }:

pkgs.writeScriptBin "switch-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.coreutils-full}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "Switching NixOS with $build_cores cores"
    ${pkgs.unstable.nh}/bin/nh os boot ~/.dotfiles/nixfiles -- --impure --cores $build_cores
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
