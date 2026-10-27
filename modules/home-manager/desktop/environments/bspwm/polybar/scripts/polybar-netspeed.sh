#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

cache_file="/tmp/.polybar-netspeed-cache"

    iface=$(ip route 2>/dev/null | awk '/^default/ {print $5; exit}')
    if [ -z "$iface" ]; then
      iface=$(awk -F: '/^[a-zA-Z0-9]+:/ && !/lo/ {gsub(/ /, "", $1); print $1; exit}' /proc/net/dev 2>/dev/null)
    fi

    if [ -z "$iface" ]; then
      echo "%{F${COLOR_GREEN:-}}󰇚 0K%{F-}  %{F${COLOR_RED:-}}󰕒 0K%{F-}"
      exit 0
    fi

    read -r rx tx < <(awk -v dev="$iface:" '$1 == dev {print $2, $10}' /proc/net/dev 2>/dev/null)
    now=$(date +%s)

    if [ -f "$cache_file" ]; then
      read -r prev_time prev_rx prev_tx prev_iface < "$cache_file"
      if [ "$prev_iface" = "$iface" ] && [ -n "$prev_time" ] && [ "$now" -gt "$prev_time" ]; then
        dt=$((now - prev_time))
        rx_speed=$(( (rx - prev_rx) / dt ))
        tx_speed=$(( (tx - prev_tx) / dt ))
      else
        rx_speed=0
        tx_speed=0
      fi
    else
      rx_speed=0
      tx_speed=0
    fi

    echo "$now $rx $tx $iface" > "$cache_file"

    format_speed() {
      local bytes=$1
      if [ "$bytes" -ge 1048576 ]; then
        awk -v b="$bytes" 'BEGIN {printf "%.1fM", b/1048576}'
      elif [ "$bytes" -ge 1024 ]; then
        echo "$((bytes / 1024))K"
      else
        echo "0K"
      fi
    }

    down_str=$(format_speed "$rx_speed")
    up_str=$(format_speed "$tx_speed")

    echo "%{F${COLOR_GREEN:-}}󰇚 $down_str%{F-}  %{F${COLOR_RED:-}}󰕒 $up_str%{F-}"
