{ pkgs }:

pkgs.writeScriptBin "switch-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    pushd $HOME/.dotfiles/nixfiles
    sudo nixos-rebuild switch --flake .#
    popd
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
