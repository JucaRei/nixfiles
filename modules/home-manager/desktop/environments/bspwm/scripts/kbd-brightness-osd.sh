#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

# 1. Identificar dispositivo de iluminação de teclado via brightnessctl
    dev=""
    for candidate in "smc::kbd_backlight" "apple::kbd_backlight" "dell::kbd_backlight" "asus::kbd_backlight" "tpacpi::kbd_backlight"; do
      if brightnessctl -d "$candidate" info >/dev/null 2>&1; then
        dev="$candidate"
        break
      fi
    done

    if [ -z "$dev" ]; then
      dev=$(brightnessctl --list 2>/dev/null | grep -E -m1 "kbd_backlight|keyboard" | cut -d\' -f2 || true)
    fi

    if [ -n "$dev" ]; then
      case "$1" in
        up)
          prev=$(brightnessctl -d "$dev" get 2>/dev/null)
          brightnessctl -d "$dev" set +5% >/dev/null 2>&1 || brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          curr=$(brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          fi
          ;;
        down)
          prev=$(brightnessctl -d "$dev" get 2>/dev/null)
          brightnessctl -d "$dev" set 5%- >/dev/null 2>&1 || brightnessctl -d "$dev" set 1- >/dev/null 2>&1
          curr=$(brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            brightnessctl -d "$dev" set 1- >/dev/null 2>&1
          fi
          ;;
        toggle)
          b_curr=$(brightnessctl -d "$dev" -m 2>/dev/null || true)
          curr=0
          if [[ "$b_curr" =~ ,([0-9]+)% ]]; then
            curr="${BASH_REMATCH[1]}"
          fi
          if [ "$curr" -gt 0 ] 2>/dev/null; then
            brightnessctl -d "$dev" set 0%
          else
            brightnessctl -d "$dev" set 50%
          fi
          ;;
      esac

      b_val=$(brightnessctl -d "$dev" -m 2>/dev/null || true)
      val=""
      if [[ "$b_val" =~ ,([0-9]+)% ]]; then
        val="${BASH_REMATCH[1]}"
      fi
      if [ -n "$val" ]; then
        dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -h int:value:"$val" -t 1500 "Luz do Teclado: $val%"
      fi
    else
      # 2. Teclados externos (Logitech MX Keys / sem interface direta em /sys/class/leds)
      SOLAAR_CMD=""
      if command -v solaar >/dev/null 2>&1; then
        SOLAAR_CMD="solaar"
      elif [ -x "solaar" ]; then
        SOLAAR_CMD="solaar"
      fi

      if [ -n "$SOLAAR_CMD" ]; then
        case "$1" in
          up|toggle)
            "$SOLAAR_CMD" config "MX Keys" backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight true 2>/dev/null || true
            dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Aumentar / Ativada"
            ;;
          down)
            "$SOLAAR_CMD" config "MX Keys" backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight false 2>/dev/null || true
            dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Diminuir / Desativada"
            ;;
        esac
      else
        case "$1" in
          up)   dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F4 / MX Keys): Aumentar" ;;
          down) dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F3 / MX Keys): Diminuir" ;;
          toggle) dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Alternar" ;;
        esac
      fi
    fi
