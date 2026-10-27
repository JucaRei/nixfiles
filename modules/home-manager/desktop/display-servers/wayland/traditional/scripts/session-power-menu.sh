#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2016,SC2028,SC2034,SC2046,SC2059,SC2076,SC2086,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

chosen=$(printf "󰌾 Bloquear\n󰤄 Suspender\n󰍃 Encerrar Sessão\n󰑐 Reiniciar\n󰐥 Desligar" | rofi -dmenu -p " 󰐥 Energia " -theme-str 'window {width: 320px; height: 320px;} listview {columns: 1; lines: 5;}')
    case "$chosen" in
      *"Bloquear") hyprlock ;;
      *"Suspender") systemctl suspend ;;
      *"Encerrar Sessão")
        if [ "$XDG_CURRENT_DESKTOP" = "mango" ] || [ "$DESKTOP_SESSION" = "mango" ] || pgrep -x mango >/dev/null 2>&1; then
          pkill -SIGTERM -x mango 2>/dev/null || loginctl terminate-session "${XDG_SESSION_ID:-}" 2>/dev/null || loginctl terminate-user "$USER"
        elif command -v hyprctl >/dev/null 2>&1 && pgrep -x Hyprland >/dev/null 2>&1; then
          hyprctl dispatch exit
        elif [ -n "${XDG_SESSION_ID:-}" ]; then
          loginctl terminate-session "$XDG_SESSION_ID"
        else
          loginctl terminate-user "$USER"
        fi
        ;;
      *"Reiniciar") systemctl reboot ;;
      *"Desligar") systemctl poweroff ;;
    esac
