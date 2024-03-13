{ pkgs }:

pkgs.writeScriptBin "switch-all" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    sudo ${pkgs.coreutils-full}/bin/true
    pushd $HOME/.dotfiles/nixfiles
    sudo nixos-rebuild switch --flake .#
    ${pkgs.home-manager}/bin/home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
    popd
  else
    ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
