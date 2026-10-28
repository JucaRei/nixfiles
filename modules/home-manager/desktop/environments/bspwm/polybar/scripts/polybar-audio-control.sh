#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

action="${1:-}"

    notify_vol() {
      local vol
      vol=$(pamixer --get-volume 2>/dev/null || echo "0")
      local is_muted
      is_muted=$(pamixer --get-mute 2>/dev/null || echo "false")
      local icon="audio-volume-medium"
      local text="Volume: $vol%"
      local bar_val=0

      if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
        icon="audio-volume-muted"
        text="Volume: Mudo"
        bar_val=0
      else
        if [ "$vol" -lt 30 ]; then
          icon="audio-volume-low"
        elif [ "$vol" -gt 70 ]; then
          icon="audio-volume-high"
        fi
        bar_val=$(( vol * 100 / 150 ))
        [ "$bar_val" -gt 100 ] && bar_val=100
      fi

      if command -v dunstify >/dev/null 2>&1; then
        dunstify -a "OSD" -u low -i "$icon" -h string:x-dunst-stack-tag:volume -h int:value:"$bar_val" -t 1200 "$text"
      fi
    }

    case "$action" in
      volume-up)
        pamixer --allow-boost --set-limit 150 -i 2 2>/dev/null || {
          raw_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null || true)
          curr_vol=0
          if [[ "$raw_vol" =~ ([0-9]+)% ]]; then
            curr_vol="${BASH_REMATCH[1]}"
          fi
          if [ "$curr_vol" -lt 150 ]; then
            next_vol=$(( curr_vol + 2 ))
            [ "$next_vol" -gt 150 ] && next_vol=150
            pactl set-sink-volume @DEFAULT_SINK@ "$next_vol%" 2>/dev/null || true
          fi
        }
        notify_vol
        ;;
      volume-down)
        pamixer -d 2 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ -2% 2>/dev/null || true
        notify_vol
        ;;
      toggle-mute)
        pamixer -t 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null || true
        notify_vol
        ;;
      next-sink)
        if command -v pactl >/dev/null 2>&1; then
          sinks=($(pactl list short sinks 2>/dev/null | awk '{print $2}'))
          if [ "${#sinks[@]}" -gt 1 ]; then
            current=$(pactl get-default-sink 2>/dev/null)
            next_sink=""
            for i in "${!sinks[@]}"; do
              if [ "${sinks[$i]}" = "$current" ]; then
                next_idx=$(( (i + 1) % ${#sinks[@]} ))
                next_sink="${sinks[$next_idx]}"
                break
              fi
            done
            [ -z "$next_sink" ] && next_sink="${sinks[0]}"
            pactl set-default-sink "$next_sink" 2>/dev/null
            for input in $(pactl list short sink-inputs 2>/dev/null | awk '{print $1}'); do
              pactl move-sink-input "$input" "$next_sink" 2>/dev/null || true
            done
            desc=$(pactl list sinks 2>/dev/null | awk -v s="$next_sink" '
              $1 == "Name:" && $2 == s { f=1 }
              f && /Description:/ { sub(/^[[:space:]]*Description:[[:space:]]*/, ""); print; exit }
            ')
            [ -z "$desc" ] && desc="$next_sink"
            if command -v dunstify >/dev/null 2>&1; then
              dunstify -a "Áudio" -u low -i "audio-card" -h string:x-dunst-stack-tag:audio-sink -t 2000 "Saída de Áudio" "$desc"
            fi
          fi
        fi
        ;;
    esac
