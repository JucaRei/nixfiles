#!/usr/bin/env bash
set -euo pipefail

if [ -z "${MANGO_INSTANCE_SIGNATURE:-}" ]; then
  export MANGO_INSTANCE_SIGNATURE
  MANGO_INSTANCE_SIGNATURE=$(find /run/user/"$(id -u)" -maxdepth 1 -name "mango-*.sock" 2>/dev/null | head -n1 || true)
fi

# 1. Recarrega as configurações do MangoWM
mmsg dispatch reload_config 2>/dev/null || true

# 2. Recarrega ou reinicia a barra / shell ativo (Noctalia ou Waybar)
if [ "${1:-}" = "--restart" ]; then
  if systemctl --user is-active noctalia.service >/dev/null 2>&1; then
    systemctl --user restart noctalia
  elif pgrep -x waybar >/dev/null 2>&1; then
    systemctl --user restart waybar 2>/dev/null || pkill -x waybar || true
  fi
  sleep 0.5
  notify-send -u low -i "preferences-desktop" "MangoWM" "Configurações recarregadas e Shell reiniciado com sucesso!" 2>/dev/null || true
else
  if command -v noctalia >/dev/null 2>&1 && (pgrep -x .noctalia-wrapp >/dev/null 2>&1 || pgrep -x noctalia >/dev/null 2>&1); then
    noctalia msg config-reload 2>/dev/null || true
  fi
  pkill -SIGUSR2 waybar 2>/dev/null || true
  notify-send -u low -i "preferences-desktop" "MangoWM" "Configurações do MangoWM e Shell recarregadas com sucesso!" 2>/dev/null || true
fi

