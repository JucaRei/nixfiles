#!/usr/bin/env bash
# Justification: Legacy monolithic script preserved to maintain full upstream runtime compatibility.

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
  else
    local name
    name=$(bspc query -D -d "$d" --names 2>/dev/null || true)
    [ -n "$name" ] && d="$name"
  fi
  echo "$d"
}

get_layout() {
  local d
  d="$(get_desktop "$1")"
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

cancel_presel() {
  local d="$1"
  for n in $(bspc query -N -d "$d" 2>/dev/null); do
    bspc node "$n" -p cancel 2>/dev/null || true
  done
}

apply_tall() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=()
  while IFS= read -r node; do
    [ -n "$node" ] && nodes+=("$node")
  done < <(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null || true)
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && { cancel_presel "$d"; return 0; }

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$master" -p east 2>/dev/null || true
      bspc node "$node" -n "$master" 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$prev" -p south 2>/dev/null || true
      bspc node "$node" -n "$prev" 2>/dev/null || true
    fi
  done
  bspc node '@/2' -B 2>/dev/null || true
  bspc node '@/' -r 0.55 2>/dev/null || true
  cancel_presel "$d"
}

apply_rtall() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=()
  while IFS= read -r node; do
    [ -n "$node" ] && nodes+=("$node")
  done < <(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null || true)
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && { cancel_presel "$d"; return 0; }

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$master" -p west 2>/dev/null || true
      bspc node "$node" -n "$master" 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$prev" -p south 2>/dev/null || true
      bspc node "$node" -n "$prev" 2>/dev/null || true
    fi
  done
  bspc node '@/1' -B 2>/dev/null || true
  bspc node '@/' -r 0.45 2>/dev/null || true
  cancel_presel "$d"
}

apply_wide() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=()
  while IFS= read -r node; do
    [ -n "$node" ] && nodes+=("$node")
  done < <(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null || true)
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && { cancel_presel "$d"; return 0; }

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$master" -p south 2>/dev/null || true
      bspc node "$node" -n "$master" 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$prev" -p east 2>/dev/null || true
      bspc node "$node" -n "$prev" 2>/dev/null || true
    fi
  done
  bspc node '@/2' -B 2>/dev/null || true
  bspc node '@/' -r 0.55 2>/dev/null || true
  cancel_presel "$d"
}

apply_rwide() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=()
  while IFS= read -r node; do
    [ -n "$node" ] && nodes+=("$node")
  done < <(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null || true)
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && { cancel_presel "$d"; return 0; }

  local master="${nodes[0]}"
  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    if [ "$i" -eq 1 ]; then
      bspc node "$master" -p north 2>/dev/null || true
      bspc node "$node" -n "$master" 2>/dev/null || true
    else
      local prev="${nodes[$((i-1))]}"
      bspc node "$prev" -p east 2>/dev/null || true
      bspc node "$node" -n "$prev" 2>/dev/null || true
    fi
  done
  bspc node '@/1' -B 2>/dev/null || true
  bspc node '@/' -r 0.45 2>/dev/null || true
  cancel_presel "$d"
}

apply_columns() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=()
  while IFS= read -r node; do
    [ -n "$node" ] && nodes+=("$node")
  done < <(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null || true)
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && { cancel_presel "$d"; return 0; }

  for ((i=1; i<count; i++)); do
    local node="${nodes[$i]}"
    local prev="${nodes[$((i-1))]}"
    bspc node "$prev" -p east 2>/dev/null || true
    bspc node "$node" -n "$prev" 2>/dev/null || true
  done
  bspc node '@/' -E 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
  cancel_presel "$d"
}

apply_grid() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  local nodes=()
  while IFS= read -r node; do
    [ -n "$node" ] && nodes+=("$node")
  done < <(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null || true)
  local count=${#nodes[@]}
  [ "$count" -lt 2 ] && { cancel_presel "$d"; return 0; }

  if [ "$count" -eq 4 ]; then
    bspc node "${nodes[0]}" -p east 2>/dev/null || true
    bspc node "${nodes[1]}" -n "${nodes[0]}" 2>/dev/null || true
    bspc node "${nodes[0]}" -p south 2>/dev/null || true
    bspc node "${nodes[2]}" -n "${nodes[0]}" 2>/dev/null || true
    bspc node "${nodes[1]}" -p south 2>/dev/null || true
    bspc node "${nodes[3]}" -n "${nodes[1]}" 2>/dev/null || true
  elif [ "$count" -eq 3 ]; then
    bspc node "${nodes[0]}" -p east 2>/dev/null || true
    bspc node "${nodes[1]}" -n "${nodes[0]}" 2>/dev/null || true
    bspc node "${nodes[1]}" -p south 2>/dev/null || true
    bspc node "${nodes[2]}" -n "${nodes[1]}" 2>/dev/null || true
  fi
  bspc node '@/' -E 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
  cancel_presel "$d"
}

apply_even() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  bspc node '@/' -E 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
  cancel_presel "$d"
}

apply_monocle() {
  local d="$1"
  bspc desktop "$d" -l monocle 2>/dev/null || true
  cancel_presel "$d"
}

apply_tiled() {
  local d="$1"
  bspc desktop "$d" -l tiled 2>/dev/null || true
  bspc node '@/' -B 2>/dev/null || true
  bspc node '@/' -E 2>/dev/null || true
  cancel_presel "$d"
}

apply_layout() {
  local layout="$1"
  local d
  d="$(get_desktop "$2")"
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
  cancel_presel "$d"
}

set_layout() {
  local layout="$1"
  local d
  d="$(get_desktop "$2")"
  if [ "$layout" = "tiled" ]; then
    remove_layout "$d"
    return 0
  fi
  echo "$layout" > "$STATE_DIR/$d"
  apply_layout "$layout" "$d"
}

next_layout() {
  local d
  d="$(get_desktop "$1")"
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
  local d
  d="$(get_desktop "$1")"
  local curr
  curr=$(get_layout "$d")
  curr=$(echo "$curr" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
  local prev="${LAYOUT_LIST[$(( ${#LAYOUT_LIST[@]} - 1 ))]}"
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
  local d
  d="$(get_desktop "$1")"
  rm -f "$STATE_DIR/$d" 2>/dev/null || true
  apply_tiled "$d"
}

apply_zoom() {
  local d
  d="$(get_desktop "$1")"
  local nodes=()
  while IFS= read -r node; do
    [ -n "$node" ] && nodes+=("$node")
  done < <(bspc query -N -d "$d" -n .window.!floating.!hidden 2>/dev/null || true)
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

reload_layouts() {
  local lock_file="$STATE_DIR/.lock"
  touch "$lock_file"
  for sf in "$STATE_DIR"/*; do
    [ -f "$sf" ] || continue
    local d_name
    d_name=$(basename "$sf")
    [ "$d_name" = "watcher.pid" ] && continue
    [ "$d_name" = ".lock" ] && continue
    local saved_layout
    saved_layout=$(cat "$sf" 2>/dev/null || true)
    if [ -n "$saved_layout" ] && [ "$saved_layout" != "tiled" ] && [ "$saved_layout" != "-" ]; then
      apply_layout "$saved_layout" "$d_name"
    fi
  done
  rm -f "$lock_file" 2>/dev/null || true
}

watch_layouts() {
  local pid_file="$STATE_DIR/watcher.pid"
  local lock_file="$STATE_DIR/.lock"

  # Limpar locks anteriores
  rm -f "$lock_file" 2>/dev/null || true

  # Prevenir múltiplas instâncias concorrentes do daemon
  if [ -f "$pid_file" ]; then
    local old_pid
    old_pid=$(cat "$pid_file" 2>/dev/null || true)
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
      if [ "$old_pid" != "$$" ]; then
        kill "$old_pid" 2>/dev/null || true
        sleep 0.1
      fi
    fi
  fi
  echo "$$" > "$pid_file"

  cleanup() {
    pkill -P "$$" 2>/dev/null || true
    rm -f "$pid_file" "$lock_file" 2>/dev/null || true
    exit 0
  }
  trap cleanup INT TERM EXIT HUP

  # Loop de resiliência: aguardar até que o BSPWM esteja respondendo ao IPC
  while true; do
    while ! bspc query -M >/dev/null 2>&1; do
      sleep 0.5
    done

    # Reaplicar layouts salvos para todos os desktops após o BSPWM estar ativo
    reload_layouts

    # Escutar eventos via IPC do bspwm (categoria 'node'):
    # - node_manage: nova janela aberta
    # - node_unmanage: janela fechada
    # - node_transfer: janela movida entre desktops
    # - node_state: janela alternada (floating, fullscreen)
    bspc subscribe node | while read -r event _arg1 arg2 _arg3 rest; do
      [ -f "$lock_file" ] && continue

      local target_desktop=""

      case "$event" in
        node_manage|node_unmanage)
          target_desktop="$arg2"
          ;;
        node_transfer)
          local src_d="$arg2"
          local dst_d
          dst_d=$(echo "$rest" | awk '{print $2}')

          [ "$src_d" = "$dst_d" ] && continue

          local src_name
          src_name=$(bspc query -D -d "$src_d" --names 2>/dev/null || echo "$src_d")
          local src_layout
          src_layout=$(get_layout "$src_name")
          if [ -n "$src_layout" ] && [ "$src_layout" != "tiled" ] && [ "$src_layout" != "-" ]; then
            touch "$lock_file"
            apply_layout "$src_layout" "$src_name"
            rm -f "$lock_file" 2>/dev/null || true
          fi

          target_desktop="$dst_d"
          ;;
        node_state)
          local st
          st=$(echo "$rest" | awk '{print $1}')
          if [ "$st" = "floating" ] || [ "$st" = "fullscreen" ]; then
            target_desktop="$arg2"
          else
            continue
          fi
          ;;
        *)
          continue
          ;;
      esac

      [ -z "$target_desktop" ] && continue

      local d_name
      d_name=$(bspc query -D -d "$target_desktop" --names 2>/dev/null || echo "$target_desktop")
      local cur_layout
      cur_layout=$(get_layout "$d_name")

      [ -z "$cur_layout" ] || [ "$cur_layout" = "tiled" ] || [ "$cur_layout" = "-" ] && continue

      touch "$lock_file"
      sleep 0.04
      apply_layout "$cur_layout" "$d_name"
      rm -f "$lock_file" 2>/dev/null || true
    done

    # Se o pipe do bspc fechar (ex: bspwm reiniciando), aguardar antes de reconectar
    sleep 1
  done
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
  reload|restart)
    reload_layouts "$@"
    ;;
  stop|kill)
    pkill -f "bsp-layout.*watch" 2>/dev/null || true
    rm -f "$STATE_DIR/watcher.pid" "$STATE_DIR/.lock" 2>/dev/null || true
    ;;
  layouts)
    printf "%s\n" "${LAYOUT_LIST[@]}"
    ;;
  help|-h|--help)
    echo "bsp-layout - Gerenciador dinâmico de layouts para BSPWM (estilo DWL e Niri)"
    echo "Comandos: get, set <layout>, once <layout>, next, prev, cycle, zoom, watch, reload, stop, remove, layouts"
    ;;
  tall|rtall|wide|rwide|columns|niri|grid|even|monocle|tiled)
    set_layout "$CMD" "$@"
    ;;
  *)
    get_layout "$@"
    ;;
esac
