{ pkgs }:

pkgs.writeScriptBin "switch-host" ''
  #!${pkgs.stdenv.shell}

  if [ -e "$HOME/.dotfiles/nixfiles" ]; then
    all_cores=$(nproc)
    build_cores=$(${pkgs.uutils-coreutils-noprefix}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
    echo "🚀 Switching NixOS host ($HOSTNAME) with $build_cores cores..."

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

    if ${pkgs.unstable.nh}/bin/nh os switch "$HOME/.dotfiles/nixfiles" -- --show-trace --impure -vL --cores "$build_cores"; then
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

      # Notificação visual de sucesso no desktop
      if command -v ${pkgs.dunst}/bin/dunstify >/dev/null 2>&1; then
        ${pkgs.dunst}/bin/dunstify -a "NixOS" -u low -i "software-update-available" -r 9999 -t 3000 \
          "Sistema Atualizado!" "Configurações, regras e atalhos recarregados com sucesso." 2>/dev/null || true
      fi

      echo "🧹 Cleaning old generations (keeping last 5)..."
      ${pkgs.unstable.nh}/bin/nh clean all --keep 5 2>/dev/null || true
    else
      echo "❌ Erro durante o switch. Verifique as mensagens acima."
      exit 1
    fi
  else
    ${pkgs.uutils-coreutils-noprefix}/bin/echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
    exit 1
  fi
''
