#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

SCRATCHPAD_NAME="bspwm-scratch"
    MAX_WIDTH_PERCENT=75
    HEIGHT_PERCENT=48

    # 1. Obter geometria do monitor atualmente focado
    mon_geo=$(bspc query -T -m focused | jq -r '.rectangle | "\(.width) \(.height) \(.x) \(.y)"')
    SCREEN_WIDTH=$(echo "$mon_geo" | awk '{print $1}')
    SCREEN_HEIGHT=$(echo "$mon_geo" | awk '{print $2}')
    MONITOR_X=$(echo "$mon_geo" | awk '{print $3}')
    MONITOR_Y=$(echo "$mon_geo" | awk '{print $4}')

    # 2. Calcular dimensões e posicionamento (respeitando espaçamento da Polybar)
    WIDTH=$((SCREEN_WIDTH * MAX_WIDTH_PERCENT / 100))
    HEIGHT=$((SCREEN_HEIGHT * HEIGHT_PERCENT / 100))
    X_POS=$((MONITOR_X + (SCREEN_WIDTH - WIDTH) / 2))
    Y_POS=$((MONITOR_Y + 44))

    # 3. Localizar janela existente do scratchpad
    get_scratchpad_id() {
      for node in $(bspc query -N -n ".floating.window" 2>/dev/null); do
        if xprop -id "$node" WM_CLASS 2>/dev/null | grep -q "$SCRATCHPAD_NAME"; then
          echo "$node"
          return 0
        fi
      done
    }

    WINDOW_ID=$(get_scratchpad_id)

    if [ -n "$WINDOW_ID" ]; then
      CURRENT_STATE=$(bspc query -T -n "$WINDOW_ID" | jq -r '.hidden')

      if [ "$CURRENT_STATE" = "false" ]; then
        # Se visível: oculta
        bspc node "$WINDOW_ID" -g hidden
      else
        # Se oculto: move para o monitor focado, reposiciona, redimensiona e foca
        bspc node "$WINDOW_ID" -m focused
        xdo move -x "$X_POS" -y "$Y_POS" "$WINDOW_ID"
        xdo resize -w "$WIDTH" -h "$HEIGHT" "$WINDOW_ID"
        bspc node "$WINDOW_ID" -g hidden=off -f
      fi
    else
      # Se não existe, cria a regra temporária one-shot no BSPWM
      bspc rule -a "$SCRATCHPAD_NAME" \
        state=floating \
        sticky=on \
        rectangle="${WIDTH}x${HEIGHT}+${X_POS}+${Y_POS}" \
        --one-shot

      # Inicia o terminal dedicado com a classe bspwm-scratch em $HOME
      ${SCRATCHPAD_LAUNCH_CMD:-alacritty}

      # Aguarda a criação e ajusta posição/tamanho se necessário
      for i in 1 2 3 4 5; do
        sleep 0.1
        WINDOW_ID=$(get_scratchpad_id)
        if [ -n "$WINDOW_ID" ]; then
          xdo move -x "$X_POS" -y "$Y_POS" "$WINDOW_ID" 2>/dev/null || true
          xdo resize -w "$WIDTH" -h "$HEIGHT" "$WINDOW_ID" 2>/dev/null || true
          break
        fi
      done
    fi
