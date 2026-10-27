#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

hidden_nodes=$(bspc query -N -d focused -n .window.hidden 2>/dev/null)
    if [ -z "$hidden_nodes" ]; then
      exit 0
    fi

    entries=""
    for node in $hidden_nodes; do
      title=$(xdotool getwindowname "$node" 2>/dev/null || echo "Janela $node")
      entries="$entries$node: 󰖯 $title\n"
    done

    chosen=$(printf "%s" "$entries" | rofi -dmenu -i -p " 󰖯 Restaurar Janela " -theme-str 'window { width: 700px; border-radius: 14px; } listview { columns: 1; lines: 8; }')
    if [ -n "$chosen" ]; then
      selected_node=$(echo "$chosen" | cut -d: -f1)
      bspc node "$selected_node" -g hidden=off -f
    fi
