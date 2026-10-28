#!/usr/bin/env bash
set -e

# ==============================================================================
# bsp-layout - Gerenciador Dinâmico e Reativo de Layouts para BSPWM (estilo DWL e Niri)
# ==============================================================================

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/bsp-layout-${UID:-1000}"
mkdir -p "$STATE_DIR" 2>/dev/null || true

LAYOUT_LIST=("tall" "columns" "wide" "grid" "rtall" "even" "monocle" "tiled")

get_desktop() {
  local d="${1:-}"
  if [ -z "$d" ]; then
    d=$(bspc query -D -d focused --names 2>/dev/null || true)
    [ -z "$d" ] && d=$(bspc query -D -d focused 2>/dev/null || echo "focused")
  fi
  echo "$d"
}

get_layout() {
  local d="$(get_desktop "$1")"
  local f="$STATE_DIR/$d"
  if [ -f "$f" ]; then
    cat "$f" 2>/dev/null || echo "tiled"
  else
    local native
    native=$(bspc query -T -d "$d" 2>/dev/null | jq -r '.layout // "tiled"' 2>/dev/null || echo "tiled")
    [ -z "$native" ] || [ "$native" = "null" ] && native="tiled"
    echo "$native"
  fi
}

apply_tall() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=($(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null))
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && return 0

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$node" -n "$master" -p east 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$node" -n "$prev" -p south 2>/dev/null || true
    fi
  done
  bspc node '@/2' -B 2>/dev/null || true
  bspc node '@/' -r 0.55 2>/dev/null || true
}

apply_rtall() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=($(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null))
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && return 0

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$node" -n "$master" -p west 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$node" -n "$prev" -p south 2>/dev/null || true
    fi
  done
  bspc node '@/1' -B 2>/dev/null || true
  bspc node '@/' -r 0.45 2>/dev/null || true
}

apply_wide() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=($(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null))
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && return 0

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$node" -n "$master" -p south 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$node" -n "$prev" -p east 2>/dev/null || true
    fi
  done
  bspc node '@/2' -B 2>/dev/null || true
  bspc node '@/' -r 0.55 2>/dev/null || true
}

apply_rwide() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=($(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null))
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && return 0

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$node" -n "$master" -p north 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$node" -n "$prev" -p east 2>/dev/null || true
    fi
  done
  bspc node '@/1' -B 2>/dev/null || true
  bspc node '@/' -r 0.45 2>/dev/null || true
}

apply_columns() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=($(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null))
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && return 0

  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    local prev="${nodes[$((i-1))]}"
    bspc node "$node" -n "$prev" -p east 2>/dev/null || true
  done
  bspc node '@/' -E 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
}

apply_grid() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=($(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null))
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && return 0

  if [ "$count" -eq 4 ]; then
    bspc node "${nodes[1]}" -n "${nodes[0]}" -p east 2>/dev/null || true
    bspc node "${nodes[2]}" -n "${nodes[0]}" -p south 2>/dev/null || true
    bspc node "${nodes[3]}" -n "${nodes[1]}" -p south 2>/dev/null || true
  fi
  bspc node '@/' -E 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
}

apply_even() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  bspc node '@/' -E 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
}

apply_monocle() {
  local d="$1"
  bspc desktop "$d" -l monocle 2>/dev/null || true
}

apply_tiled() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
  bspc node '@/' -E 2>/dev/null || true
}

apply_layout() {
  local layout="$1"
  local d="$(get_desktop "$2")"
  case "$layout" in
    tall) apply_tall "$d" ;;
    rtall) apply_rtall "$d" ;;
    wide|bstack) apply_wide "$d" ;;
    rwide) apply_rwide "$d" ;;
    columns|niri) apply_columns "$d" ;;
    grid) apply_grid "$d" ;;
    even) apply_even "$d" ;;
    monocle) apply_monocle "$d" ;;
    tiled|*) apply_tiled "$d" ;;
  esac
}

set_layout() {
  local layout="$1"
  local d="$(get_desktop "$2")"
  if [ "$layout" = "tiled" ]; then
    remove_layout "$d"
    return 0
  fi
  echo "$layout" > "$STATE_DIR/$d"
  apply_layout "$layout" "$d"
}

next_layout() {
  local d="$(get_desktop "$1")"
  local curr
  curr=$(get_layout "$d")
  curr=$(echo "$curr" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
  local next="${LAYOUT_LIST[0]}"
  for ((i=0; i<${#LAYOUT_LIST[@]}; i++)); do
    if [ "${LAYOUT_LIST[$i]}" = "$curr" ]; then
      local next_idx=$(( (i + 1) % ${#LAYOUT_LIST[@]} ))
      next="${LAYOUT_LIST[$next_idx]}"
      break
    fi
  done
  set_layout "$next" "$d"
  echo "$next"
}

prev_layout() {
  local d="$(get_desktop "$1")"
  local curr
  curr=$(get_layout "$d")
  curr=$(echo "$curr" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
  local prev="${LAYOUT_LIST[-1]}"
  for ((i=0; i<${#LAYOUT_LIST[@]}; i++)); do
    if [ "${LAYOUT_LIST[$i]}" = "$curr" ]; then
      local prev_idx=$(( (i - 1 + ${#LAYOUT_LIST[@]}) % ${#LAYOUT_LIST[@]} ))
      prev="${LAYOUT_LIST[$prev_idx]}"
      break
    fi
  done
  set_layout "$prev" "$d"
  echo "$prev"
}

remove_layout() {
  local d="$(get_desktop "$1")"
  rm -f "$STATE_DIR/$d" 2>/dev/null || true
  apply_tiled "$d"
}

apply_zoom() {
  local d="$(get_desktop "$1")"
  local nodes=($(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null))
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && return 0

  local focused
  focused=$(bspc query -N -n focused 2>/dev/null || true)
  local master="${nodes[0]}"

  if [ "$focused" = "$master" ]; then
    bspc node "$master" -s "${nodes[1]}" 2>/dev/null || true
  else
    bspc node "$focused" -s "$master" 2>/dev/null || true
  fi

  local l
  l=$(get_layout "$d")
  [ "$l" != "tiled" ] && apply_layout "$l" "$d"
}

watch_layouts() {
  pkill -f "bsp-layout.*watch" 2>/dev/null || true
  exit 0
}

CMD="${1:-get}"
shift 2>/dev/null || true

case "$CMD" in
  get)
    get_layout "$@"
    ;;
  set)
    if [ -z "$1" ]; then
      echo "Uso: bsp-layout set <layout> [desktop]" >&2
      exit 1
    fi
    set_layout "$@"
    ;;
  once)
    if [ -z "$1" ]; then
      echo "Uso: bsp-layout once <layout> [desktop]" >&2
      exit 1
    fi
    apply_layout "$@"
    ;;
  next|cycle)
    next_layout "$@"
    ;;
  prev|previous)
    prev_layout "$@"
    ;;
  remove|reset)
    remove_layout "$@"
    ;;
  zoom)
    apply_zoom "$@"
    ;;
  watch|watcher|daemon)
    watch_layouts
    ;;
  layouts)
    printf "%s\n" "${LAYOUT_LIST[@]}"
    ;;
  help|-h|--help)
    echo "bsp-layout - Gerenciador dinâmico de layouts para BSPWM (estilo DWL e Niri)"
    echo "Comandos: get, set <layout>, once <layout>, next, prev, cycle, zoom, watch, remove, layouts"
    ;;
  tall|rtall|wide|rwide|columns|niri|grid|even|monocle|tiled)
    set_layout "$CMD" "$@"
    ;;
  *)
    get_layout "$@"
    ;;
esac
