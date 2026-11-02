#!/usr/bin/env bash
set -euo pipefail

NEW_SPEED="${1:-}"

COUNT=0
for id in $(xinput list --id-only 2>/dev/null); do
  dev_name=$(xinput list --name-only "$id" 2>/dev/null | tr '[:upper:]' '[:lower:]')
  has_tapping=$(xinput list-props "$id" 2>/dev/null | grep -c "libinput Tapping Enabled" || true)

  if echo "$dev_name" | grep -q "touchpad" || [ "$has_tapping" -gt 0 ]; then
    real_name=$(xinput list --name-only "$id" 2>/dev/null)
    curr_speed=$(xinput list-props "$id" 2>/dev/null | grep "libinput Accel Speed (" | awk -F':' '{print $2}' | tr -d ' \t')

    if [ -n "$NEW_SPEED" ]; then
      if xinput set-prop "$id" "libinput Accel Speed" "$NEW_SPEED" 2>/dev/null; then
        echo "✓ Touchpad [$id: $real_name]: velocidade alterada de $curr_speed para $NEW_SPEED"
        COUNT=$((COUNT + 1))
      else
        echo "✗ Falha ao definir velocidade para [$id: $real_name]" >&2
      fi
    else
      echo "ℹ Touchpad [$id: $real_name]: velocidade atual = $curr_speed"
      COUNT=$((COUNT + 1))
    fi
  fi
done

if [ "$COUNT" -eq 0 ]; then
  echo "Nenhum touchpad compatível com libinput encontrado via xinput." >&2
  exit 1
fi

if [ -n "$NEW_SPEED" ]; then
  dunstify -a "Touchpad" -u low -i "input-touchpad" -r 9991 -t 2000 "Velocidade do Touchpad" "Nova velocidade: $NEW_SPEED (-1.0 a 1.0)" 2>/dev/null || true
fi

