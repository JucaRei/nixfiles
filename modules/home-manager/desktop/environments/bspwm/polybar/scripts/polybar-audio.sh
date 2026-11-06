#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222
export LC_ALL=C

get_audio_info() {
  local vol=""
  local is_muted="false"
  local default_sink=""

  if command -v pactl >/dev/null 2>&1; then
    default_sink=$(pactl get-default-sink 2>/dev/null || true)
    if [ -z "$default_sink" ]; then
      default_sink=$(pactl info 2>/dev/null | awk -F': ' '/Default Sink:/{print $2}' || true)
    fi
    [ -z "$default_sink" ] && default_sink="@DEFAULT_SINK@"

    local raw_vol
    raw_vol=$(pactl get-sink-volume "$default_sink" 2>/dev/null || true)
    if [[ "$raw_vol" =~ ([0-9]+)% ]]; then
      vol="${BASH_REMATCH[1]}"
    fi

    local raw_mute
    raw_mute=$(pactl get-sink-mute "$default_sink" 2>/dev/null || true)
    if [[ "$raw_mute" =~ [Yy]es|[Ss]im ]]; then
      is_muted="true"
    fi

    # Fallback direto caso o sink nominal não responda
    if [ -z "$vol" ]; then
      raw_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null || true)
      if [[ "$raw_vol" =~ ([0-9]+)% ]]; then
        vol="${BASH_REMATCH[1]}"
      fi
      raw_mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null || true)
      if [[ "$raw_mute" =~ [Yy]es|[Ss]im ]]; then
        is_muted="true"
      fi
    fi
  fi

  if [ -z "$vol" ] && command -v wpctl >/dev/null 2>&1; then
    local wp_out
    wp_out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
    if [[ "$wp_out" =~ [Vv]olume:[[:space:]]*([0-9]+(\.[0-9]+)?) ]]; then
      vol=$(awk -v v="${BASH_REMATCH[1]}" 'BEGIN { printf "%d", (v * 100 + 0.5) }')
    fi
    if [[ "$wp_out" =~ \[MUTED\] ]]; then
      is_muted="true"
    fi
  fi

  if [ -z "$vol" ] && command -v pamixer >/dev/null 2>&1; then
    vol=$(pamixer --get-volume 2>/dev/null || echo "0")
    local p_mute
    p_mute=$(pamixer --get-mute 2>/dev/null || echo "false")
    if [ "$p_mute" = "true" ]; then
      is_muted="true"
    fi
  fi

  [ -z "$vol" ] && vol="0"

  local dev_type="speaker"
  if [ "$default_sink" = "@DEFAULT_SINK@" ] && command -v pactl >/dev/null 2>&1; then
    default_sink=$(pactl get-default-sink 2>/dev/null || true)
  fi

  if [ -n "$default_sink" ] && [ "$default_sink" != "@DEFAULT_SINK@" ] && command -v pactl >/dev/null 2>&1; then
    local sink_info
    sink_info=$(pactl list sinks 2>/dev/null | awk -v sink="$default_sink" '
      $1 == "Sink" { in_sink=0 }
      $1 == "Name:" && $2 == sink { in_sink=1 }
      in_sink { print }
    ' 2>/dev/null || true)
    [ -z "$sink_info" ] && sink_info=$(pactl list sinks 2>/dev/null || true)

    local active_port=""
    local form_factor=""
    local bus=""
    local desc=""

    while IFS='=' read -r key val || [ -n "$key" ]; do
      case "$key" in
        *device.form_factor*) form_factor="${val//[\" ]/}" ;;
        *device.bus*) bus="${val//[\" ]/}" ;;
      esac
    done <<< "$sink_info"

    while IFS=':' read -r key val || [ -n "$key" ]; do
      case "$key" in
        *Active\ Port*) active_port="${val// /}" ;;
        *Description*) desc="${val# }" ;;
      esac
    done <<< "$sink_info"

    active_port="${active_port,,}"
    form_factor="${form_factor,,}"
    bus="${bus,,}"
    local desc_lower="${desc,,}"

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

  if [ "$is_muted" = "true" ]; then
    echo "%{F${COLOR_RED:-}}󰝟%{F-} %{F${COLOR_SUBTEXT0:-}}$vol%%{F-}"
    return 0
  fi

  if [ "$vol" -eq 0 ] 2>/dev/null; then
    echo "%{F${COLOR_SUBTEXT0:-}}󰕿%{F-} %{F${COLOR_TEXT:-}}0%%{F-}"
    return 0
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
      if [ "$vol" -lt 30 ] 2>/dev/null; then
        icon="󰕿"
      elif [ "$vol" -lt 70 ] 2>/dev/null; then
        icon="󰖀"
      else
        icon="󰕾"
      fi
      icon_color="${COLOR_BLUE:-}"
      ;;
  esac

  local vol_color="${COLOR_TEXT:-}"
  if [ "$vol" -gt 100 ] 2>/dev/null; then
    vol_color="${COLOR_PEACH:-}"
  fi

  echo "%{F$icon_color}$icon%{F-} %{F$vol_color}$vol%%{F-}"
  return 0
}

# 1. Primeira renderização imediata para a Polybar
get_audio_info || true

# 2. Polling periódico de segurança em background a cada 2s
# (garante consistência contínua mesmo se eventos do daemon forem perdidos ou alterados externamente)
(
  while true; do
    sleep 2
    get_audio_info || true
  done
) &
POLL_PID=$!
trap 'kill "$POLL_PID" 2>/dev/null || true' EXIT INT TERM

# 3. Escuta em tempo real através do pactl subscribe
if command -v pactl >/dev/null 2>&1; then
  while true; do
    stdbuf -oL pactl subscribe 2>/dev/null | while IFS= read -r line; do
      case "$line" in
        *sink*|*server*|*card*|*destino*|*servidor*|*placa*)
          get_audio_info || true
          ;;
      esac
    done || true
    sleep 1
  done
else
  while true; do
    sleep 2
    get_audio_info || true
  done
fi
