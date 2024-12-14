{ pkgs }:

pkgs.writeScriptBin "boot-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    pushd $HOME/.dotfiles/nixfiles
    sudo nixos-rebuild boot --flake .#
    popd
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No Nix configurations found in $HOME/.dotfiles/nixfiles"
  fi
''
