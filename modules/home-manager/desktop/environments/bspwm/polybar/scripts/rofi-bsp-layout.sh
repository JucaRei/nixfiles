#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

curr_layout=$(bsp-layout get 2>/dev/null)
    if [ -z "$curr_layout" ] || [ "$curr_layout" = "-" ]; then
      curr_layout=$(bspc query -T -d focused 2>/dev/null | jq -r '.layout' 2>/dev/null || echo "tiled")
    fi

    OPTIONS="󰕰  Tall (Master DWL)\n󰹑  Columns (Colunas Niri)\n󰕰  Wide (Bottom-Stack DWM)\n󰝘  Grid (Grade balanceada)\n󱒅  Even (Divisão simétrica)\n󰕰  RTall (Master à direita)\n󰕰  RWide (Master abaixo)\n󰍹  Monocle (Janela cheia DWL)\n󱒆  Tiled (Padrão BSPWM)"

    CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Layout ($curr_layout)" -theme-str 'window { width: 440px; } listview { lines: 9; }')

    case "$CHOSEN" in
      *Columns*)
        bsp-layout-switch columns
        ;;
      *RTall*)
        bsp-layout-switch rtall
        ;;
      *Tall*)
        bsp-layout-switch tall
        ;;
      *RWide*)
        bsp-layout-switch rwide
        ;;
      *Wide*)
        bsp-layout-switch wide
        ;;
      *Grid*)
        bsp-layout-switch grid
        ;;
      *Even*)
        bsp-layout-switch even
        ;;
      *Monocle*)
        bsp-layout-switch monocle
        ;;
      *Tiled*)
        bsp-layout-switch tiled
        ;;
    esac
