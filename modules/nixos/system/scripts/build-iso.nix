{ pkgs }:

pkgs.writeScriptBin "build-iso" ''
  #!${pkgs.stdenv.shell}
  if [ -z $1 ]; then
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "Usage: build-iso <console|gnome|mate|pantheon>"
    exit 1
  fi

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    pushd $HOME/.dotfiles/nixfiles 2>&1 > /dev/null
    echo "Building ISO ($1) with $build_cores cores"
    ${pkgs.nix-output-monitor}/bin/nom build .#nixosConfigurations.iso-$1.config.system.build.isoImage -L --show-trace -vL --cores $build_cores
    ISO=$(${pkgs.uutils-coreutils-noprefix}/bin/head -n1 result/nix-support/hydra-build-products | ${pkgs.uutils-coreutils-noprefix}/bin/cut -d'/' -f6)
    ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p $HOME/virtualmachines/nixos-$1 2>/dev/null
    ${pkgs.uutils-coreutils-noprefix}/bin/cp result/iso/$ISO $HOME/virtualmachines/nixos-$1/nixos.iso
    ${pkgs.uutils-coreutils-noprefix}/bin/chown $USER: $HOME/virtualmachines/nixos-$1/nixos.iso
    ${pkgs.uutils-coreutils-noprefix}/bin/chmod 644 $HOME/virtualmachines/nixos-$1/nixos.iso
    popd 2>&1 > /dev/null || exit 1
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
