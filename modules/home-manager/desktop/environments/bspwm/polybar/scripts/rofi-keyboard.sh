#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

current=$(xkb-switch -p 2>/dev/null || true)
    layouts=$(xkb-switch -l 2>/dev/null || true)

    if [ -z "$layouts" ]; then
      dunstify -a "Teclado" -u low -i "input-keyboard" -r 9992 "Nenhum layout adicional configurado"
      exit 0
    fi

    menu=""
    while IFS= read -r l; do
      [ -z "$l" ] && continue
      if [ "$l" = "$current" ]; then
        menu+="󰄬  $l\n"
      else
        menu+="    $l\n"
      fi
    done <<< "$layouts"

    chosen=$(echo -e "$menu" | rofi \
      -dmenu \
      -i \
      -p "Layout" \
      -theme-str 'window {width: 360px; border-radius: 14px;} listview {columns: 1; lines: 4;}' \
      -no-custom)

    if [ -n "$chosen" ]; then
      selected_layout=$(echo "$chosen" | sed 's/^[ 󰄬]*//')
      if [ -n "$selected_layout" ]; then
        xkb-switch -s "$selected_layout"
        dunstify -a "Teclado" -u low -i "input-keyboard" -r 9992 -t 1500 "Layout: $selected_layout"
      fi
    fi
