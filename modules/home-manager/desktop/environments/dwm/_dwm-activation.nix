{ pkgs }:
''
  # 1. Se ~/.config/dwm-titus for symlink do Nix store (geração anterior), remover para permitir escrita
  if [ -L "$HOME/.config/dwm-titus" ]; then
    $DRY_RUN_CMD rm -f "$HOME/.config/dwm-titus"
  fi
  $DRY_RUN_CMD mkdir -p "$HOME/.config/dwm-titus"
  $DRY_RUN_CMD chmod 700 "$HOME/.config/dwm-titus" 2>/dev/null || true
  $DRY_RUN_CMD chmod go-w "$HOME/.config/dwm-titus" 2>/dev/null || true
  $DRY_RUN_CMD mkdir -p "$HOME/.config/dwm-titus/display-profiles"
  $DRY_RUN_CMD chmod 700 "$HOME/.config/dwm-titus/display-profiles" 2>/dev/null || true
  $DRY_RUN_CMD mkdir -p "$HOME/.local/share/dwm-titus/config"
  $DRY_RUN_CMD mkdir -p "$HOME/.local/share/dwm-titus/scripts"
  $DRY_RUN_CMD mkdir -p "$HOME/.local/state/dwm-titus/appearance/wallpaper"
  $DRY_RUN_CMD chmod 700 "$HOME/.local/state/dwm-titus" "$HOME/.local/state/dwm-titus/appearance" "$HOME/.local/state/dwm-titus/appearance/wallpaper" 2>/dev/null || true

  # Sincronizar fallbacks e scripts em ~/.local/share/dwm-titus (usados pelo dwm.c e theme-apply)
  $DRY_RUN_CMD cp -rf ${./configs/config}/* "$HOME/.local/share/dwm-titus/config/" 2>/dev/null || true
  $DRY_RUN_CMD cp -rf ${./configs/scripts}/* "$HOME/.local/share/dwm-titus/scripts/" 2>/dev/null || true
  $DRY_RUN_CMD chmod -R u+w "$HOME/.local/share/dwm-titus" 2>/dev/null || true
  $DRY_RUN_CMD chmod +x "$HOME/.local/share/dwm-titus/scripts/"* 2>/dev/null || true

  # 2. Provisionar ~/.config/quickshell como diretório REAL gravável (permite testar em Live Mode / Hot Reload)
  if [ -L "$HOME/.config/quickshell" ]; then
    $DRY_RUN_CMD rm -f "$HOME/.config/quickshell"
  fi
  $DRY_RUN_CMD mkdir -p "$HOME/.config/quickshell"
  $DRY_RUN_CMD cp -rf ${./configs/config/quickshell}/* "$HOME/.config/quickshell/" 2>/dev/null || true
  $DRY_RUN_CMD chmod -R u+w "$HOME/.config/quickshell" 2>/dev/null || true

  # 3. Inicializar arquivos de configuração do usuário em ~/.config/dwm-titus se não existirem
  if [ ! -f "$HOME/.config/dwm-titus/themes.toml" ]; then
    $DRY_RUN_CMD cp -f ${./configs/config/themes.toml} "$HOME/.config/dwm-titus/themes.toml"
  fi
  if [ ! -f "$HOME/.config/dwm-titus/hotkeys.toml" ]; then
    $DRY_RUN_CMD cp -f ${./configs/config/hotkeys.toml} "$HOME/.config/dwm-titus/hotkeys.toml"
  else
    # Assegurar que a variável filemanager exista no bloco [vars]
    if ! grep -q 'filemanager' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null; then
      $DRY_RUN_CMD sed -i '/\[vars\]/a filemanager = "file-manager"' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
    fi
    # Migrar atalhos legados para o despachante agnóstico de gerenciador de arquivos (file-manager)
    $DRY_RUN_CMD sed -i 's|cmd="xdg-open \."|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
    $DRY_RUN_CMD sed -i 's|cmd = "xdg-open \."|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
    $DRY_RUN_CMD sed -i 's|cmd="file-manager \|\| thunar \|\| xdg-open ~"|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
    $DRY_RUN_CMD sed -i 's|cmd = "file-manager \|\| thunar \|\| xdg-open ~"|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
  fi
  if [ ! -f "$HOME/.config/dwm-titus/window-rules.toml" ]; then
    $DRY_RUN_CMD cp -f ${./configs/config/window-rules.toml} "$HOME/.config/dwm-titus/window-rules.toml"
  fi

  # 4. Todos os arquivos de estado, persistência e integração para os modelos QML do Quickshell
  # (Aparência, Wallpaper, Fontes, Painel, Acessibilidade, Notificações, Picom)
  # Se estiverem ausentes ou vazios (0 bytes - gerados por touch anterior), copiar os templates válidos
  for cfg_file in \
    "theme-env.sh" \
    "personalization.conf" \
    "cursor.Xresources" \
    "xsettingsd.conf" \
    "wallpaper.conf" \
    "font.conf" \
    "accessibility.conf" \
    "panel-widgets.conf" \
    "notification-settings.json" \
    "picom.conf"; do
    if [ -L "$HOME/.config/dwm-titus/$cfg_file" ]; then
      $DRY_RUN_CMD rm -f "$HOME/.config/dwm-titus/$cfg_file"
    fi
    # Se não existir ou tiver 0 bytes: copiar template válido se disponível
    if [ ! -s "$HOME/.config/dwm-titus/$cfg_file" ]; then
      if [ -f "${./configs/config}/$cfg_file" ]; then
        $DRY_RUN_CMD cp -f "${./configs/config}/$cfg_file" "$HOME/.config/dwm-titus/$cfg_file"
      else
        $DRY_RUN_CMD touch "$HOME/.config/dwm-titus/$cfg_file"
      fi
    fi
    $DRY_RUN_CMD chmod 600 "$HOME/.config/dwm-titus/$cfg_file" 2>/dev/null || true
    $DRY_RUN_CMD chmod go-w "$HOME/.config/dwm-titus/$cfg_file" 2>/dev/null || true
  done

  # Limpar arquivo espúrio display-profiles.json se tiver sido criado anteriormente
  if [ -f "$HOME/.config/dwm-titus/display-profiles.json" ]; then
    $DRY_RUN_CMD rm -f "$HOME/.config/dwm-titus/display-profiles.json"
  fi

  # Assegurar permissões estritas para evitar falhas de validação de segurança
  $DRY_RUN_CMD chmod 700 "$HOME/.config/dwm-titus" 2>/dev/null || true
  $DRY_RUN_CMD chmod go-w "$HOME/.config/dwm-titus" 2>/dev/null || true
  $DRY_RUN_CMD chmod -R u+rw,go-w "$HOME/.config/dwm-titus" 2>/dev/null || true

  # 5. Converter eventuais symlinks read-only do GTK em cópias reais graváveis
  for ini in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini" "$HOME/.gtkrc-2.0"; do
    if [ -L "$ini" ]; then
      target=$($DRY_RUN_CMD readlink -f "$ini" 2>/dev/null || true)
      if [ -n "$target" ] && [ -f "$target" ]; then
        $DRY_RUN_CMD cp --remove-destination "$target" "$ini"
        $DRY_RUN_CMD chmod u+w "$ini" 2>/dev/null || true
      fi
    fi
  done

  # 6. Converter eventuais symlinks read-only do Picom em arquivos reais graváveis
  for pconf in "$HOME/.config/picom/picom.conf" "$HOME/.config/picom.conf"; do
    if [ -L "$pconf" ]; then
      target=$($DRY_RUN_CMD readlink -f "$pconf" 2>/dev/null || true)
      if [ -n "$target" ] && [ -f "$target" ]; then
        $DRY_RUN_CMD cp --remove-destination "$target" "$pconf"
        $DRY_RUN_CMD chmod u+w "$pconf" 2>/dev/null || true
      fi
    fi
  done

  # 7. Inicializar active-theme.toml do Alacritty e kitty se os diretórios existirem
  if [ -d "$HOME/.config/alacritty" ]; then
    if [ -L "$HOME/.config/alacritty/active-theme.toml" ]; then
      $DRY_RUN_CMD rm -f "$HOME/.config/alacritty/active-theme.toml"
    fi
    if [ ! -f "$HOME/.config/alacritty/active-theme.toml" ]; then
      $DRY_RUN_CMD touch "$HOME/.config/alacritty/active-theme.toml"
    fi
    $DRY_RUN_CMD chmod u+w "$HOME/.config/alacritty/active-theme.toml" 2>/dev/null || true
  fi
  if [ -d "$HOME/.config/kitty" ]; then
    if [ -L "$HOME/.config/kitty/active-theme.conf" ]; then
      $DRY_RUN_CMD rm -f "$HOME/.config/kitty/active-theme.conf"
    fi
    if [ ! -f "$HOME/.config/kitty/active-theme.conf" ]; then
      $DRY_RUN_CMD touch "$HOME/.config/kitty/active-theme.conf"
    fi
    $DRY_RUN_CMD chmod u+w "$HOME/.config/kitty/active-theme.conf" 2>/dev/null || true
  fi

  # 8. Garantir permissão de escrita em diretórios qt5ct e qt6ct
  for qtdir in "$HOME/.config/qt5ct" "$HOME/.config/qt6ct"; do
    if [ -d "$qtdir" ]; then
      $DRY_RUN_CMD chmod -R u+w "$qtdir" 2>/dev/null || true
    fi
  done

  # 9. Provisionar diretório ~/Pictures/backgrounds e wallpaper base do NixOS se vazio
  $DRY_RUN_CMD mkdir -p "$HOME/Pictures/backgrounds"
  if [ -z "$($DRY_RUN_CMD ls -A "$HOME/Pictures/backgrounds" 2>/dev/null)" ]; then
    if [ -f "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}" ]; then
      $DRY_RUN_CMD cp -f "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}" "$HOME/Pictures/backgrounds/nixos-wallpaper.png" 2>/dev/null || true
    fi
  fi
''
