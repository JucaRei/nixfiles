#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

get_audio_info() {
      local vol=""
      local is_muted="false"

      if command -v pamixer >/dev/null 2>&1; then
        vol=$(pamixer --get-volume 2>/dev/null)
        is_muted=$(pamixer --get-mute 2>/dev/null || echo "false")
      fi

      if [ -z "$vol" ] && command -v pactl >/dev/null 2>&1; then
        vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o -E '[0-9]+%' | head -n1 | tr -d '%')
        pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -qi "yes" && is_muted="true"
      fi

      [ -z "$vol" ] && vol="0"

      local dev_type="speaker"
      if command -v pactl >/dev/null 2>&1; then
        local default_sink
        default_sink=$(pactl get-default-sink 2>/dev/null)
        [ -z "$default_sink" ] && default_sink=$(pactl info 2>/dev/null | grep "Default Sink:" | cut -d: -f2- | xargs)

        local sink_info
        sink_info=$(pactl list sinks 2>/dev/null | awk -v sink="$default_sink" '
          $1 == "Sink" { in_sink=0 }
          $1 == "Name:" && $2 == sink { in_sink=1 }
          in_sink { print }
        ')
        [ -z "$sink_info" ] && sink_info=$(pactl list sinks 2>/dev/null)

        local active_port
        active_port=$(echo "$sink_info" | grep -E '^[[:space:]]*Active Port:' | head -n1 | cut -d: -f2- | tr '[:upper:]' '[:lower:]' | xargs)

        local form_factor
        form_factor=$(echo "$sink_info" | grep -E 'device.form_factor' | head -n1 | cut -d= -f2- | tr -d ' "' | tr '[:upper:]' '[:lower:]' | xargs)

        local bus
        bus=$(echo "$sink_info" | grep -E 'device.bus' | head -n1 | cut -d= -f2- | tr -d ' "' | tr '[:upper:]' '[:lower:]' | xargs)

        local desc
        desc=$(echo "$sink_info" | grep -E '^[[:space:]]*Description:' | head -n1 | cut -d: -f2- | xargs)
        local desc_lower
        desc_lower=$(echo "$desc" | tr '[:upper:]' '[:lower:]')

        if [ "$bus" = "bluetooth" ] || [[ "$default_sink" =~ bluez_sink|bluez_output ]]; then
          dev_type="bluetooth"
        elif [[ "$active_port" =~ hdmi|displayport ]] || [[ "$default_sink" =~ hdmi ]] || [[ "$desc_lower" =~ hdmi|displayport ]]; then
          dev_type="hdmi"
        elif [[ "$active_port" =~ headset ]] || [ "$form_factor" = "headset" ] || [[ "$desc_lower" =~ headset ]]; then
          dev_type="headset"
        elif [[ "$active_port" =~ headphone ]] || [ "$form_factor" = "headphone" ] || [[ "$desc_lower" =~ headphone|fone|earphone|earbuds|buds|airpod ]]; then
          dev_type="headphone"
        elif [ "$bus" = "usb" ]; then
          dev_type="usb"
        else
          dev_type="speaker"
        fi
      fi

      if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
        echo "%{F${COLOR_RED:-}}󰝟%{F-} %{F${COLOR_SUBTEXT0:-}}0%%{F-}"
        return
      fi

      local icon="󰕾"
      local icon_color="${COLOR_BLUE:-}"

      case "$dev_type" in
        headphone)
          icon="󰋋"
          icon_color="${COLOR_SAPPHIRE:-}"
          ;;
        headset)
          icon="󰋎"
          icon_color="${COLOR_SAPPHIRE:-}"
          ;;
        bluetooth)
          icon="󰂰"
          icon_color="${COLOR_LAVENDER:-}"
          ;;
        hdmi)
          icon="󰡁"
          icon_color="${COLOR_SKY:-}"
          ;;
        usb)
          icon="󰟵"
          icon_color="${COLOR_TEAL:-}"
          ;;
        speaker|*)
          if [ "$vol" -lt 30 ]; then
            icon="󰕿"
          elif [ "$vol" -lt 70 ]; then
            icon="󰖀"
          else
            icon="󰕾"
          fi
          icon_color="${COLOR_BLUE:-}"
          ;;
      esac

      local vol_color="${COLOR_TEXT:-}"
      if [ "$vol" -gt 100 ]; then
        vol_color="${COLOR_PEACH:-}"
      fi

      echo "%{F$icon_color}$icon%{F-} %{F$vol_color}$vol%%{F-}"
    }

    get_audio_info

    while true; do
      if command -v pactl >/dev/null 2>&1; then
        pactl subscribe 2>/dev/null | grep --line-buffered -E "('change'|'remove'|'new') on (sink|server)" | while read -r _; do
          get_audio_info
        done
      fi
      sleep 2
      get_audio_info
    done
