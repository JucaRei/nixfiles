#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

case "$1" in
      up)
        pamixer --allow-boost --set-limit 150 -i 2 2>/dev/null || {
          if command -v pactl >/dev/null 2>&1; then
            curr_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o -E '[0-9]+%' | head -n1 | tr -d '%')
            if [ -n "$curr_vol" ] && [ "$curr_vol" -lt 150 ]; then
              next_vol=$(( curr_vol + 2 ))
              [ "$next_vol" -gt 150 ] && next_vol=150
              pactl set-sink-volume @DEFAULT_SINK@ "$next_vol%" 2>/dev/null || true
            fi
          fi
        }
        ;;
      down)
        pamixer -d 2 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ -2% 2>/dev/null || true
        ;;
      mute)
        pamixer -t 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null || true
        ;;
    esac

    vol=$(pamixer --get-volume 2>/dev/null)
    is_muted=$(pamixer --get-mute 2>/dev/null || echo "false")
    if [ -z "$vol" ] && command -v pactl >/dev/null 2>&1; then
      vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o -E '[0-9]+%' | head -n1 | tr -d '%')
      pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -qi "yes" && is_muted="true"
    fi
    [ -z "$vol" ] && vol="0"

    if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
      icon="audio-volume-muted"
      text="Volume: Mudo"
      bar_val=0
    else
      if [ "$vol" -lt 30 ]; then
        icon="audio-volume-low"
      elif [ "$vol" -lt 70 ]; then
        icon="audio-volume-medium"
      else
        icon="audio-volume-high"
      fi
      text="Volume: $vol%"
      bar_val=$(( vol * 100 / 150 ))
      [ "$bar_val" -gt 100 ] && bar_val=100
    fi

    dunstify -a "OSD" \
      -u low \
      -i "$icon" \
      -h string:x-dunst-stack-tag:volume \
      -h int:value:"$bar_val" \
      -t 1500 \
      "$text"
