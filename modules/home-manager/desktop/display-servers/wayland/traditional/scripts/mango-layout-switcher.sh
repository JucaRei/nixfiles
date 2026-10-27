#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2016,SC2028,SC2034,SC2046,SC2059,SC2076,SC2086,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
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
      code=$(echo "$state" | jq -r '.monitors[0].layout_symbol // empty' 2>/dev/null || true)
    fi

    if [ -z "$code" ] || [ -z "${LAYOUT_NAMES[$code]+x}" ]; then
      echo "{\"text\":\"󰕰 ${code:-Tile}\",\"tooltip\":\"Layout atual: ${code:-Desconhecido}\",\"class\":\"other\"}"
      exit 0
    fi

    name="${LAYOUT_NAMES[$code]}"
    icon="${LAYOUT_ICONS[$code]:-󰕰}"

    echo "{\"text\":\"$icon $name\",\"tooltip\":\"Layout do MangoWM: $name ($code)\nClique: Menu de Seleção | Dir: Alternar\",\"class\":\"$code\"}"
