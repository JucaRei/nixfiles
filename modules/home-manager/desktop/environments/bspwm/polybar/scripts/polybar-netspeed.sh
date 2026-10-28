#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

cache_file="${XDG_RUNTIME_DIR:-/tmp}/.polybar-netspeed-${UID:-1000}.cache"

# 1. Detectar interface de rede ativa (rota padrão em /proc/net/route, depois ip route, depois sysfs operstate)
iface=""
if [ -r /proc/net/route ]; then
  iface=$(awk '$2 == "00000000" {print $1; exit}' /proc/net/route 2>/dev/null || true)
fi

if [ -z "$iface" ] && command -v ip >/dev/null 2>&1; then
  iface=$(ip route 2>/dev/null | awk '/^default/ {print $5; exit}' || true)
fi

if [ -z "$iface" ]; then
  for dev_path in /sys/class/net/*; do
    [ -d "$dev_path" ] || continue
    dev=$(basename "$dev_path")
    [ "$dev" = "lo" ] && continue
    if [ -f "$dev_path/operstate" ] && grep -qi "up" "$dev_path/operstate" 2>/dev/null; then
      iface="$dev"
      break
    fi
  done
fi

if [ -z "$iface" ]; then
  iface=$(awk -F: '/^[a-zA-Z0-9]+:/ && !/lo/ {gsub(/ /, "", $1); print $1; exit}' /proc/net/dev 2>/dev/null || true)
fi

if [ -z "$iface" ]; then
  echo "%{F${COLOR_GREEN:-}}󰇚 0K%{F-}  %{F${COLOR_RED:-}}󰕒 0K%{F-}"
  exit 0
fi

# 2. Ler estatísticas de RX e TX (sysfs primeiro, fallback /proc/net/dev)
rx=""
tx=""
if [ -f "/sys/class/net/$iface/statistics/rx_bytes" ]; then
  rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || true)
  tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || true)
fi

if [ -z "$rx" ] || [ -z "$tx" ]; then
  read -r rx tx < <(awk -F: -v dev="$iface" '$1 ~ dev {split($2, a, " "); print a[1], a[9]}' /proc/net/dev 2>/dev/null || true)
fi

rx=${rx:-0}
tx=${tx:-0}
now=$(date +%s)

rx_speed=0
tx_speed=0

if [ -f "$cache_file" ]; then
  prev_line=$(cat "$cache_file" 2>/dev/null || true)
  prev_time=$(echo "$prev_line" | awk '{print $1}')
  prev_rx=$(echo "$prev_line" | awk '{print $2}')
  prev_tx=$(echo "$prev_line" | awk '{print $3}')
  prev_iface=$(echo "$prev_line" | awk '{print $4}')

  if [ "$prev_iface" = "$iface" ] && [ -n "$prev_time" ] && [ "$now" -gt "$prev_time" ] 2>/dev/null; then
    dt=$((now - prev_time))
    if [ "$dt" -gt 0 ] && [ "$rx" -ge "$prev_rx" ] 2>/dev/null && [ "$tx" -ge "$prev_tx" ] 2>/dev/null; then
      rx_speed=$(( (rx - prev_rx) / dt ))
      tx_speed=$(( (tx - prev_tx) / dt ))
    fi
  fi
fi

echo "$now $rx $tx $iface" > "$cache_file" 2>/dev/null || true

format_speed() {
  local bytes="${1:-0}"
  if [ "$bytes" -ge 1048576 ] 2>/dev/null; then
    awk -v b="$bytes" 'BEGIN {printf "%.1fM", b/1048576}'
  elif [ "$bytes" -ge 1024 ] 2>/dev/null; then
    echo "$((bytes / 1024))K"
  else
    echo "0K"
  fi
}

down_str=$(format_speed "$rx_speed")
up_str=$(format_speed "$tx_speed")

echo "%{F${COLOR_GREEN:-}}󰇚 $down_str%{F-}  %{F${COLOR_RED:-}}󰕒 $up_str%{F-}"
