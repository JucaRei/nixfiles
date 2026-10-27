#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

dev=""
    for d in intel_backlight nv_backlight apple_backlight acpi_video0; do
      if [ -d "/sys/class/backlight/$d" ]; then
        dev="$d"
        break
      fi
    done
    if [ -z "$dev" ] && [ -d /sys/class/backlight ]; then
      for b in /sys/class/backlight/*; do
        if [ -d "$b" ]; then
          dev=$(basename "$b")
          break
        fi
      done
    fi
    [ -z "$dev" ] && exit 0

    case "${1:-}" in
      up) brightnessctl -d "$dev" set +5% >/dev/null 2>&1 ;;
      down) brightnessctl -d "$dev" set 5%- >/dev/null 2>&1 ;;
      *)
        pct=$(brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' || true)
        if [ -n "$pct" ]; then
          echo "%{F${COLOR_YELLOW:-}}󰃠%{F-} $pct%"
        fi
        ;;
    esac
