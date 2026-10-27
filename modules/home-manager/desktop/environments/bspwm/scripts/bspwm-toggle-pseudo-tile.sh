#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

target="focused"
    action="toggle"

    case "${1:-}" in
      on|enable|--on|--enable)
        action="on"
        ;;
      off|disable|--off|--disable)
        action="off"
        ;;
      status|--status|-s)
        action="status"
        ;;
      toggle|--toggle|"")
        action="toggle"
        ;;
      0x*|[0-9]*)
        target="$1"
        case "${2:-}" in
          on|enable) action="on" ;;
          off|disable) action="off" ;;
          status) action="status" ;;
          *) action="toggle" ;;
        esac
        ;;
    esac

    # Validar se há janela válida focada ou selecionada
    wid=$(bspc query -N -n "$target.window" 2>/dev/null || bspc query -N -n "focused.window" 2>/dev/null)
    if [ -z "$wid" ]; then
      exit 0
    fi

    if [ "$action" = "status" ]; then
      state=$(bspc query -T -n "$wid" 2>/dev/null | jq -r '.client.state // empty' 2>/dev/null)
      echo "${state:-unknown}"
      exit 0
    elif [ "$action" = "on" ]; then
      bspc node "$wid" -t pseudo_tiled 2>/dev/null || true
    elif [ "$action" = "off" ]; then
      bspc node "$wid" -t tiled 2>/dev/null || true
    else
      bspc node "$wid" -t '~pseudo_tiled' 2>/dev/null || true
    fi

    state=$(bspc query -T -n "$wid" 2>/dev/null | jq -r '.client.state // empty' 2>/dev/null)
    if [ "$state" = "pseudo_tiled" ]; then
      dunstify -a "BSPWM" -u low -i "view-restore" -h string:x-dunst-stack-tag:window-state -r 9994 -t 1500 "󱒆 Janela: Pseudo-Tiled" "Janela em grade preservando dimensões naturais" 2>/dev/null || true
    else
      dunstify -a "BSPWM" -u low -i "view-grid" -h string:x-dunst-stack-tag:window-state -r 9994 -t 1500 "󰄬 Janela: Tiled" "Modo tiling em grade completa restaurado" 2>/dev/null || true
    fi
