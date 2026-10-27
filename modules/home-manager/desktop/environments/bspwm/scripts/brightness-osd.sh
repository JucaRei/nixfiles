#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

# Identificar dispositivo de tela real (priorizar intel_backlight > nv_backlight > apple_backlight > acpi_video0)
    dev=""
    for d in intel_backlight nv_backlight apple_backlight acpi_video0; do
      if [ -d "/sys/class/backlight/$d" ]; then
        dev="$d"
        break
      fi
    done
    if [ -z "$dev" ] && [ -d /sys/class/backlight ]; then
      dev=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1)
    fi

    dev_args=()
    if [ -n "$dev" ]; then
      dev_args=(-d "$dev")
    fi

    case "$1" in
      up)
        prev=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
        brightnessctl "${dev_args[@]}" set +2% >/dev/null 2>&1
        curr=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          brightnessctl "${dev_args[@]}" set +1 >/dev/null 2>&1
        fi
        ;;
      down)
        prev=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
        brightnessctl "${dev_args[@]}" set 2%- >/dev/null 2>&1
        curr=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          brightnessctl "${dev_args[@]}" set 1- >/dev/null 2>&1
        fi
        ;;
    esac

    val=$(brightnessctl "${dev_args[@]}" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
    if [ -n "$val" ]; then
      if [ "$val" -lt 33 ]; then
        icon="display-brightness-low"
      elif [ "$val" -lt 66 ]; then
        icon="display-brightness-medium"
      else
        icon="display-brightness-high"
      fi

      dunstify -a "OSD" \
        -u low \
        -i "$icon" \
        -h string:x-dunst-stack-tag:brightness \
        -h int:value:"$val" \
        -t 1500 \
        "Brilho da Tela: $val%"
    fi
