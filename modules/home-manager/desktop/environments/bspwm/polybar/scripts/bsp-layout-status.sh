#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

layout=$(bsp-layout get 2>/dev/null)

    if [ -z "$layout" ] || [ "$layout" = "-" ]; then
      layout=$(bspc query -T -d focused 2>/dev/null | jq -r '.layout' 2>/dev/null || echo "tiled")
    fi

    case "$layout" in
      tall)
        icon="󰕰"
        name="Tall"
        ;;
      columns|niri)
        icon="󰹑"
        name="Columns"
        ;;
      rtall)
        icon="󰕰"
        name="RTall"
        ;;
      wide)
        icon="󰕰"
        name="Wide"
        ;;
      rwide)
        icon="󰕰"
        name="RWide"
        ;;
      grid)
        icon="󰝘"
        name="Grid"
        ;;
      even)
        icon="󱒅"
        name="Even"
        ;;
      monocle)
        icon="󰍹"
        name="Monocle"
        ;;
      tiled|*)
        icon="󱒆"
        name="Tiled"
        ;;
    esac

    echo "%{F${COLOR_BLUE:-}}$icon%{F-} %{F${COLOR_TEXT:-}}$name%{F-}"
