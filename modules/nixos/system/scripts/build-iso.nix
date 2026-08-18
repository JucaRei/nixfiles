{ pkgs }:

pkgs.writeScriptBin "build-iso" ''
  #!${pkgs.stdenv.shell}
  if [ -z "$1" ]; then
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "Usage: build-iso <xfce4|gnome|mate|pantheon|bspwm|console>"
    exit 1
  fi

  TARGET_DIR="."
  if [ ! -f "$TARGET_DIR/flake.nix" ]; then
    if [ -n "$FLAKE" ] && [ -f "$FLAKE/flake.nix" ]; then
      TARGET_DIR="$FLAKE"
    elif [ -f "$HOME/.dotfiles/nixfiles/flake.nix" ]; then
      TARGET_DIR="$HOME/.dotfiles/nixfiles"
    elif [ -f "$HOME/workspace/MyRepos/nixfiles/flake.nix" ]; then
      TARGET_DIR="$HOME/workspace/MyRepos/nixfiles"
    else
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No flake.nix found in current directory, \$FLAKE, or standard paths."
      exit 1
    fi
  fi

  all_cores=$(nproc)
  build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
  [ "$build_cores" -lt 1 ] && build_cores=1

  pushd "$TARGET_DIR" > /dev/null || exit 1
  echo "Building ISO ($1) with $build_cores cores..."
  ${pkgs.nix-output-monitor}/bin/nom build .#nixosConfigurations.iso-$1.config.system.build.isoImage -L --show-trace --cores "$build_cores"
  
  if [ -d "result/iso" ]; then
    ISO_PATH=$(${pkgs.uutils-coreutils-noprefix}/bin/ls result/iso/*.iso 2>/dev/null | ${pkgs.uutils-coreutils-noprefix}/bin/head -n1)
    if [ -n "$ISO_PATH" ] && [ -f "$ISO_PATH" ]; then
      DOWNLOADS_DIR="''${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
      ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p "$DOWNLOADS_DIR"
      ISO_NAME=$(${pkgs.uutils-coreutils-noprefix}/bin/basename "$ISO_PATH")
      echo "Copying $ISO_NAME to $DOWNLOADS_DIR/..."
      ${pkgs.uutils-coreutils-noprefix}/bin/cp -L "$ISO_PATH" "$DOWNLOADS_DIR/$ISO_NAME"
      ${pkgs.uutils-coreutils-noprefix}/bin/chmod 644 "$DOWNLOADS_DIR/$ISO_NAME"
      echo "✅ ISO saved to: $DOWNLOADS_DIR/$ISO_NAME"
    fi
  fi
  popd > /dev/null || exit 1
''
