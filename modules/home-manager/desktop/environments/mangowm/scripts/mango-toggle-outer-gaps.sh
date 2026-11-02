#!/usr/bin/env bash
set -euo pipefail

if [ -z "${MANGO_INSTANCE_SIGNATURE:-}" ]; then
  export MANGO_INSTANCE_SIGNATURE
  MANGO_INSTANCE_SIGNATURE=$(find /run/user/"$(id -u)" -maxdepth 1 -name "mango-*.sock" 2>/dev/null | head -n1 || true)
fi

STATE_FILE="$HOME/.cache/mango_gaps_mode"
mkdir -p "$HOME/.cache"
if [ -f "$STATE_FILE" ]; then
  rm -f "$STATE_FILE"
  mmsg dispatch togglegaps 2>/dev/null || true
  notify-send -u low "MangoWM" "Modo Normal: Gaps restaurados"
else
  touch "$STATE_FILE"
  mmsg dispatch togglegaps 2>/dev/null || true
  notify-send -u low "MangoWM" "Modo Foco: Gaps desativados"
fi

