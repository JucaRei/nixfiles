{ pkgs, ... }:

pkgs.writeScriptBin "hm-switch" ''
  #!${pkgs.stdenv.shell}

  if [ -e "$HOME/.dotfiles/nixfiles" ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "🏠 Switching Home Manager with $build_cores cores..."

    ERROR_DIR="$HOME/.config/errors/nix/home-manager"
    mkdir -p "$ERROR_DIR"
    TMP_LOG=$(mktemp /tmp/hm-switch-XXXXXX.log 2>/dev/null || echo "/tmp/hm-switch-$$.log")

    # Limpar backups antigos e arquivos físicos de settings.json para evitar erro de 'would be clobbered'
    find "$HOME/.config" -name "*.hm.backup" -delete 2>/dev/null || true
    for f in "$HOME/.config/Code/User/settings.json" \
             "$HOME/.config/Code/User/profiles"/*/settings.json \
             "$HOME/Library/Application Support/Code/User/settings.json"; do
      if [ -e "$f" ] && [ ! -L "$f" ]; then
        rm -f "$f" 2>/dev/null || true
      fi
    done

    if [ -d "$HOME/.dotfiles/nixfiles/.git" ]; then
      ${pkgs.git}/bin/git -C "$HOME/.dotfiles/nixfiles" add -A 2>/dev/null || true
    fi

    set -o pipefail
    if ${pkgs.unstable.nh}/bin/nh home switch --backup-extension backup "$HOME/.dotfiles/nixfiles" -- --impure --show-trace -vL --cores "$build_cores" 2>&1 | tee "$TMP_LOG"; then
      rm -f "$TMP_LOG" 2>/dev/null || true
      echo "✨ Home Manager switch concluído com sucesso!"

      # Notificação visual de sucesso no desktop
      if command -v ${pkgs.dunst}/bin/dunstify >/dev/null 2>&1; then
        ${pkgs.dunst}/bin/dunstify -a "Home Manager" -u low -i "software-update-available" -r 9998 -t 3000 \
          "Home Manager Atualizado!" "Configurações do usuário reaplicadas com sucesso." 2>/dev/null || true
      fi

      echo "🧹 Cleaning old generations (keeping last 5)..."
      ${pkgs.unstable.nh}/bin/nh clean all --keep 5 2>/dev/null || true
    else
      err_code=$?
      timestamp=$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S)
      error_file="$ERROR_DIR/switch-error-$timestamp.log"
      cp "$TMP_LOG" "$error_file" 2>/dev/null || true
      ln -sf "$error_file" "$ERROR_DIR/last-error.log" 2>/dev/null || true
      rm -f "$TMP_LOG" 2>/dev/null || true

      echo ""
      echo "❌ Erro durante o switch do Home Manager (código de saída: $err_code)!"
      echo "📋 Log de erro salvo em: $error_file"
      echo "🔗 Último erro disponível em: $ERROR_DIR/last-error.log"

      if command -v ${pkgs.dunst}/bin/dunstify >/dev/null 2>&1; then
        ${pkgs.dunst}/bin/dunstify -a "Home Manager" -u critical -i "dialog-error" -r 9998 -t 10000 \
          "Erro no Switch Home Manager" "Log salvo em: $ERROR_DIR/last-error.log" 2>/dev/null || true
      fi
      exit $err_code
    fi
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
    exit 1
  fi
''
