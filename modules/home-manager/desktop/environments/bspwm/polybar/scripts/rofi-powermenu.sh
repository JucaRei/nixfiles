#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

chosen=$(printf "󰐥  Desligar\n󰜉  Reiniciar\n󰤄  Suspender\n󰒲  Hibernar\n󰈆  Sair (logout)\n󰌾  Bloquear" \
      | rofi \
          -dmenu \
          -i \
          -p "Power Menu" \
          -theme-str 'window {width: 320px; border-radius: 14px;} listview {columns: 1; lines: 6;}' \
          -no-custom)

    case "$chosen" in
      *"Desligar"*)    systemctl poweroff || loginctl poweroff ;;
      *"Reiniciar"*)   systemctl reboot || loginctl reboot ;;
      *"Suspender"*)   systemctl suspend || loginctl suspend ;;
      *"Hibernar"*)    systemctl hibernate || loginctl hibernate ;;
      *"Sair"*)       bspc quit ;;
      *"Bloquear"*)    bspwm-lock || loginctl lock-session ;;
    esac
