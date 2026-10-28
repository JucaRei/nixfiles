#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

notify_layout() {
      layout=$(bsp-layout get 2>/dev/null)
      if [ -z "$layout" ] || [ "$layout" = "-" ]; then
        layout=$(bspc query -T -d focused 2>/dev/null | jq -r '.layout' 2>/dev/null || echo "tiled")
      fi

      case "$layout" in
        tall)
          icon="preferences-desktop-display"
          label="Tall (Master-Stack DWL)"
          ;;
        columns|niri)
          icon="preferences-desktop-display"
          label="Columns (Estilo Niri)"
          ;;
        rtall)
          icon="preferences-desktop-display"
          label="RTall (Master-Stack Invertido)"
          ;;
        wide)
          icon="preferences-desktop-display"
          label="Wide (Master-Stack H)"
          ;;
        rwide)
          icon="preferences-desktop-display"
          label="RWide (Wide Invertido)"
          ;;
        grid)
          icon="preferences-desktop-display"
          label="Grid (Grade)"
          ;;
        even)
          icon="preferences-desktop-display"
          label="Even (Divisão Igual)"
          ;;
        monocle)
          icon="view-fullscreen"
          label="Monocle (Tela Única)"
          ;;
        tiled|*)
          icon="preferences-desktop-display"
          label="Tiled (Padrão BSPWM)"
          ;;
      esac

      dunstify -a "BSPWM Layout" -u low -i "$icon" -r 9993 -t 1500 "Layout: $label"
    }

    ACTION="${1:-next}"

    case "$ACTION" in
      next|cycle)
        bsp-layout next
        notify_layout
        ;;
      prev|previous)
        bsp-layout prev
        notify_layout
        ;;
      tall|rtall|wide|rwide|columns|niri|grid|even|monocle|tiled)
        bsp-layout set "$ACTION"
        notify_layout
        ;;
      remove|reset)
        bsp-layout remove
        notify_layout
        ;;
      *)
        bsp-layout next
        notify_layout
        ;;
    esac
