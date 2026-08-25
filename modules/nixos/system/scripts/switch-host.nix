{ pkgs }:

pkgs.writeScriptBin "switch-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "🚀 Switching NixOS host ($HOSTNAME) with $build_cores cores..."
    # Limpar backups antigos para evitar erro de 'would be clobbered'
    find "$HOME/.config" -name "*.hm.backup" -delete 2>/dev/null || true
    if [ -d "$HOME/.dotfiles/nixfiles/.git" ]; then
      ${pkgs.git}/bin/git -C "$HOME/.dotfiles/nixfiles" add -A 2>/dev/null || true
    fi
    ${pkgs.unstable.nh}/bin/nh os switch "$HOME/.dotfiles/nixfiles" -- --show-trace --impure -vL --cores "$build_cores"
    echo "🧹 Cleaning old generations (keeping last 5)..."
    ${pkgs.unstable.nh}/bin/nh clean all --keep 5
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
  fi
''
