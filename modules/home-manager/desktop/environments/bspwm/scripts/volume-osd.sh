#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

case "$1" in
  up)
    if command -v pactl >/dev/null 2>&1; then
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
    elif command -v pamixer >/dev/null 2>&1; then
      pamixer --allow-boost --set-limit 150 -i 2 2>/dev/null || true
    elif command -v wpctl >/dev/null 2>&1; then
      wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+ 2>/dev/null || true
    fi
    ;;
  down)
    if command -v pactl >/dev/null 2>&1; then
      pactl set-sink-volume @DEFAULT_SINK@ -2% 2>/dev/null || true
    elif command -v pamixer >/dev/null 2>&1; then
      pamixer -d 2 2>/dev/null || true
    elif command -v wpctl >/dev/null 2>&1; then
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- 2>/dev/null || true
    fi
    ;;
  mute)
    if command -v pactl >/dev/null 2>&1; then
      pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null || true
    elif command -v pamixer >/dev/null 2>&1; then
      pamixer -t 2>/dev/null || true
    elif command -v wpctl >/dev/null 2>&1; then
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || true
    fi
    ;;
esac

vol=""
is_muted="false"

if command -v pactl >/dev/null 2>&1; then
  raw_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null || true)
  if [[ "$raw_vol" =~ ([0-9]+)% ]]; then
    vol="${BASH_REMATCH[1]}"
  fi
  pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -qi "yes" && is_muted="true"
fi

if [ -z "$vol" ] && command -v wpctl >/dev/null 2>&1; then
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
  is_muted=$(pamixer --get-mute 2>/dev/null || echo "false")
fi

[ -z "$vol" ] && vol="0"

if [ "$is_muted" = "true" ]; then
  icon="audio-volume-muted"
  text="Volume: Mudo ($vol%)"
  [ "$vol" -eq 0 ] && text="Volume: Mudo"
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

if command -v dunstify >/dev/null 2>&1; then
  dunstify -a "OSD" \
    -u low \
    -i "$icon" \
    -h string:x-dunst-stack-tag:volume \
    -h int:value:"$bar_val" \
    -t 1500 \
    "$text"
fi
