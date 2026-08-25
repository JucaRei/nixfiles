{ pkgs }:

pkgs.writeScriptBin "build-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e $HOME/.dotfiles/nixfiles ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "🔨 Building and testing NixOS ($HOSTNAME) with $build_cores cores..."
    if [ -d "$HOME/.dotfiles/nixfiles/.git" ]; then
      ${pkgs.git}/bin/git -C "$HOME/.dotfiles/nixfiles" add -A 2>/dev/null || true
    fi
    ${pkgs.unstable.nh}/bin/nh os test "$HOME/.dotfiles/nixfiles" -- --show-trace --impure -vL --cores "$build_cores"
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No Nix configurations found in $HOME/.dotfiles/nixfiles"
  fi
''
