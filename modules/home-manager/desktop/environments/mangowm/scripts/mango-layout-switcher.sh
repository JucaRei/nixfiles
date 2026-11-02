#!/usr/bin/env bash
set -euo pipefail

if [ -z "${MANGO_INSTANCE_SIGNATURE:-}" ]; then
  export MANGO_INSTANCE_SIGNATURE
  MANGO_INSTANCE_SIGNATURE=$(find /run/user/"$(id -u)" -maxdepth 1 -name "mango-*.sock" 2>/dev/null | head -n1 || true)
fi

declare -A LAYOUT_NAMES=(
  [T]="Tile"
  [S]="Scroller"
  [G]="Grid"
  [M]="Monocle"
  [K]="Deck"
  [CT]="Center Tile"
  [RT]="Right Tile"
  [VS]="Vert Scroller"
  [VT]="Vert Tile"
  [VG]="Vert Grid"
  [VK]="Vert Deck"
  [DW]="Dwindle"
  [F]="Fair"
  [VF]="Vert Fair"
  [TG]="TGMix"
)

declare -A LAYOUT_ICONS=(
  [T]="󰕰"
  [S]="󰹑"
  [G]="󰝘"
  [M]="󰍹"
  [K]="󰓩"
  [CT]="󰕲"
  [RT]="󰕳"
  [VS]="󰹒"
  [VT]="󰕴"
  [VG]="󰝙"
  [VK]="󰓪"
  [DW]="󰕯"
  [F]="󰕮"
  [VF]="󰕬"
  [TG]="󰕱"
)

state=$(mmsg get all-monitors 2>/dev/null || true)
if [ -z "$state" ] || echo "$state" | grep -q '"error"'; then
  echo '{"text":"󰕰 Mango","tooltip":"MangoWM não detectado ou inativo"}'
  exit 0
fi

code=$(echo "$state" | jq -r '.monitors[] | select(.active) | .layout_symbol // empty' 2>/dev/null | head -n1 || true)
if [ -z "$code" ]; then
  code=$(echo "$state" | jq -r '.monitors[0].layout_symbol // empty' 2>/dev/null | head -n1 || true)
fi

if [ -z "$code" ] || [ -z "${LAYOUT_NAMES[$code]+x}" ]; then
  echo "{\"text\":\"󰕰 ${code:-Tile}\",\"tooltip\":\"Layout atual: ${code:-Desconhecido}\",\"class\":\"other\"}"
  exit 0
fi

name="${LAYOUT_NAMES[$code]}"
icon="${LAYOUT_ICONS[$code]:-󰕰}"

printf '{"text":"%s %s","tooltip":"Layout do MangoWM: %s (%s)\\nClique: Menu de Seleção | Dir: Alternar","class":"%s"}\n' "$icon" "$name" "$name" "$code" "$code"

