#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

STATE_FILE="/tmp/polybar_redshift_state"
    TEMP_FILE="/tmp/polybar_redshift_temp"

    DEFAULT_TEMP=4500
    DAY_TEMP=6500

    get_temp() {
      if [ -f "$TEMP_FILE" ]; then
        cat "$TEMP_FILE" 2>/dev/null || echo "$DEFAULT_TEMP"
      else
        echo "$DEFAULT_TEMP"
      fi
    }

    set_temp() {
      temp="$1"
      echo "$temp" > "$TEMP_FILE"
      echo "on" > "$STATE_FILE"
      redshift -P -O "$temp" 2>/dev/null
      dunstify -a "Redshift" -u low -i "weather-clear-night" -r 9991 -t 1500 "Filtro Noturno: ${temp}K"
    }

    toggle() {
      state=$(cat "$STATE_FILE" 2>/dev/null || echo "off")
      if [ "$state" = "on" ]; then
        echo "off" > "$STATE_FILE"
        redshift -x 2>/dev/null
        dunstify -a "Redshift" -u low -i "weather-clear" -r 9991 -t 1500 "Filtro Noturno: Desativado (6500K)"
      else
        temp=$(get_temp)
        set_temp "$temp"
      fi
    }

    increase() {
      step="${1:-100}"
      temp=$(get_temp)
      temp=$((temp + step))
      [ "$temp" -gt 6500 ] && temp=6500
      set_temp "$temp"
    }

    decrease() {
      step="${1:-100}"
      temp=$(get_temp)
      temp=$((temp - step))
      [ "$temp" -lt 2500 ] && temp=2500
      set_temp "$temp"
    }

    case "$1" in
      toggle)
        toggle
        ;;
      increase)
        increase "${2:-100}"
        ;;
      decrease)
        decrease "${2:-100}"
        ;;
      reset)
        echo "off" > "$STATE_FILE"
        echo "$DEFAULT_TEMP" > "$TEMP_FILE"
        redshift -x 2>/dev/null
        dunstify -a "Redshift" -u low -i "weather-clear" -r 9991 -t 1500 "Filtro Noturno: Resetado (6500K)"
        ;;
      status|*)
        state=$(cat "$STATE_FILE" 2>/dev/null || echo "off")
        if [ "$state" = "on" ]; then
          temp=$(get_temp)
          echo "%{F${COLOR_PEACH:-}}󰛩%{F-} ${temp}K"
        else
          echo "%{F${COLOR_SURFACE2:-}}󰛨%{F-} Off"
        fi
        ;;
    esac
