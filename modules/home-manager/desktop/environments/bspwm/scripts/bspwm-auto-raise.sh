#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222


    prev_node=""

    # Normaliza janelas flutuantes não-focadas para 'below' e eleva a janela ativa na inicialização
    for wid in $(bspc query -N -n ".floating.window.!focused" 2>/dev/null); do
      bspc node "$wid" -l below 2>/dev/null || true
    done
    focused=$(bspc query -N -n focused 2>/dev/null || true)
    if [ -n "$focused" ]; then
      bspc node "$focused" -l above 2>/dev/null || true
      prev_node="$focused"
    fi

    # Monitora eventos de foco de janelas via IPC do bspwm
    bspc subscribe node_focus | while read -r line; do
      node_id="${line##* }"
      [ -z "$node_id" ] && continue

      # Rebaixa todas as janelas flutuantes não-focadas para 'below' para que
      # qualquer janela selecionada (seja tiled ou outra flutuante) fique 100% à frente
      for wid in $(bspc query -N -n ".floating.window.!focused" 2>/dev/null); do
        bspc node "$wid" -l below 2>/dev/null || true
      done

      # Se a janela anterior era tiled, restaura para 'normal'
      if [ -n "$prev_node" ] && [ "$prev_node" != "$node_id" ]; then
        if ! bspc query -N -n "$prev_node.floating" >/dev/null 2>&1; then
          bspc node "$prev_node" -l normal 2>/dev/null || true
        fi
      fi

      # A janela recém-selecionada é sempre promovida para 'above'
      bspc node "$node_id" -l above 2>/dev/null || true
      prev_node="$node_id"
    done
