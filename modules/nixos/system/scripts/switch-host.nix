{ pkgs }:

pkgs.writeScriptBin "switch-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e "$HOME/.dotfiles/nixfiles" ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "🚀 Switching NixOS host ($HOSTNAME) with $build_cores cores..."

    # Diretório de logs de erro do NixOS
    ERROR_DIR="$HOME/.config/errors/nix/nixos"
    mkdir -p "$ERROR_DIR"
    TMP_LOG=$(mktemp /tmp/nixos-switch-XXXXXX.log 2>/dev/null || echo "/tmp/nixos-switch-$$.log")

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
    if ${pkgs.unstable.nh}/bin/nh os switch "$HOME/.dotfiles/nixfiles" -- --show-trace --impure -vL --cores "$build_cores" 2>&1 | tee "$TMP_LOG"; then
      rm -f "$TMP_LOG" 2>/dev/null || true
      echo "✨ Switch concluído com sucesso! Recarregando ambiente gráfico ao vivo..."

      # Recarregar atalhos do sxhkd
      ${pkgs.procps}/bin/pkill -USR1 -x sxhkd 2>/dev/null || true

      # Recarregar bspwm (reaplica regras e bspwmrc)
      if command -v ${pkgs.bspwm}/bin/bspc >/dev/null 2>&1; then
        ${pkgs.bspwm}/bin/bspc wm -r 2>/dev/null || true
      fi

      # Recarregar Polybar
      if command -v ${pkgs.polybar}/bin/polybar-msg >/dev/null 2>&1; then
        ${pkgs.polybar}/bin/polybar-msg cmd restart 2>/dev/null || true
      fi

      # Recarregar / Iniciar Picom
      systemctl --user restart picom 2>/dev/null || (${pkgs.picom}/bin/picom -b 2>/dev/null || true)

      # Notificação visual de sucesso no desktop
      if command -v ${pkgs.dunst}/bin/dunstify >/dev/null 2>&1; then
        ${pkgs.dunst}/bin/dunstify -a "NixOS" -u low -i "software-update-available" -r 9999 -t 3000 \
          "Sistema Atualizado!" "Configurações, regras e atalhos recarregados com sucesso." 2>/dev/null || true
      fi

      # Verificar se o serviço de ativação do Home Manager falhou
      if systemctl is-failed --quiet home-manager-*.service 2>/dev/null; then
        HM_ERROR_DIR="$HOME/.config/errors/nix/home-manager"
        mkdir -p "$HM_ERROR_DIR"
        hm_timestamp=$(${pkgs.uutils-coreutils-noprefix}/bin/date +%Y-%m-%d_%H-%M-%S)
        hm_error_file="$HM_ERROR_DIR/activation-error-$hm_timestamp.log"
        journalctl --user -u "home-manager-*.service" --no-pager > "$hm_error_file" 2>/dev/null || \
          journalctl -u "home-manager-*.service" --no-pager > "$hm_error_file" 2>/dev/null || true
        ln -sf "$hm_error_file" "$HM_ERROR_DIR/last-error.log" 2>/dev/null || true

        echo "⚠️ Atenção: A ativação do Home Manager falhou!"
        echo "📋 Log de erro salvo em: $hm_error_file"
        echo "🔗 Último erro do Home Manager em: $HM_ERROR_DIR/last-error.log"

        if command -v ${pkgs.dunst}/bin/dunstify >/dev/null 2>&1; then
          ${pkgs.dunst}/bin/dunstify -a "Home Manager" -u critical -i "dialog-error" -r 9998 -t 10000 \
            "Erro na Ativação do Home Manager" "Log salvo em: $HM_ERROR_DIR/last-error.log" 2>/dev/null || true
        fi
      fi

      echo "🧹 Cleaning old generations (keeping last 5)..."
      ${pkgs.unstable.nh}/bin/nh clean all --keep 5 2>/dev/null || true
    else
      err_code=$?
      timestamp=$(${pkgs.uutils-coreutils-noprefix}/bin/date +%Y-%m-%d_%H-%M-%S)
      error_file="$ERROR_DIR/switch-error-$timestamp.log"
      cp "$TMP_LOG" "$error_file" 2>/dev/null || true
      ln -sf "$error_file" "$ERROR_DIR/last-error.log" 2>/dev/null || true

      # Se o erro envolver o Home Manager, replicar também na pasta de erro do home-manager
      if grep -Ei "home-manager|home\.file|collision|would be clobbered|hm_picom" "$TMP_LOG" >/dev/null 2>&1; then
        HM_ERROR_DIR="$HOME/.config/errors/nix/home-manager"
        mkdir -p "$HM_ERROR_DIR"
        hm_error_file="$HM_ERROR_DIR/switch-error-$timestamp.log"
        cp "$TMP_LOG" "$hm_error_file" 2>/dev/null || true
        ln -sf "$hm_error_file" "$HM_ERROR_DIR/last-error.log" 2>/dev/null || true
        echo "⚠️ O erro possui mensagens relacionadas ao Home Manager!"
        echo "🔗 Log replicado em: $HM_ERROR_DIR/last-error.log"
      fi

      rm -f "$TMP_LOG" 2>/dev/null || true

      echo ""
      echo "❌ Erro durante o switch do NixOS (código de saída: $err_code)!"
      echo "📋 Log de erro salvo em: $error_file"
      echo "🔗 Último erro disponível em: $ERROR_DIR/last-error.log"

      if command -v ${pkgs.dunst}/bin/dunstify >/dev/null 2>&1; then
        ${pkgs.dunst}/bin/dunstify -a "NixOS" -u critical -i "dialog-error" -r 9999 -t 10000 \
          "Erro no Switch NixOS" "Log salvo em: $ERROR_DIR/last-error.log" 2>/dev/null || true
      fi
      exit $err_code
    fi
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
    exit 1
  fi
''
