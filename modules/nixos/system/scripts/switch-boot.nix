{ pkgs }:

pkgs.writeScriptBin "switch-boot" ''
  #!${pkgs.stdenv.shell}

  if [ -e "$HOME/.dotfiles/nixfiles" ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "📦 Building NixOS boot configuration ($HOSTNAME) with $build_cores cores..."

    ERROR_DIR="$HOME/.config/errors/nix/nixos"
    mkdir -p "$ERROR_DIR"
    TMP_LOG=$(mktemp /tmp/nixos-boot-XXXXXX.log 2>/dev/null || echo "/tmp/nixos-boot-$$.log")

    # Limpar backups antigos para evitar erro de 'would be clobbered'
    find "$HOME/.config" -name "*.hm.backup" -delete 2>/dev/null || true
    if [ -d "$HOME/.dotfiles/nixfiles/.git" ]; then
      ${pkgs.git}/bin/git -C "$HOME/.dotfiles/nixfiles" add -A 2>/dev/null || true
    fi

    set -o pipefail
    if ${pkgs.unstable.nh}/bin/nh os boot "$HOME/.dotfiles/nixfiles" -- --show-trace --impure -vL --cores "$build_cores" 2>&1 | tee "$TMP_LOG"; then
      rm -f "$TMP_LOG" 2>/dev/null || true
      echo "🧹 Cleaning old generations (keeping last 5)..."
      ${pkgs.unstable.nh}/bin/nh clean all --keep 5 2>/dev/null || true
    else
      err_code=$?
      timestamp=$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S)
      error_file="$ERROR_DIR/boot-error-$timestamp.log"
      cp "$TMP_LOG" "$error_file" 2>/dev/null || true
      ln -sf "$error_file" "$ERROR_DIR/last-error.log" 2>/dev/null || true
      rm -f "$TMP_LOG" 2>/dev/null || true

      echo ""
      echo "❌ Erro durante o boot switch do NixOS (código de saída: $err_code)!"
      echo "📋 Log de erro salvo em: $error_file"
      echo "🔗 Último erro disponível em: $ERROR_DIR/last-error.log"
      exit $err_code
    fi
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
    exit 1
  fi
''
