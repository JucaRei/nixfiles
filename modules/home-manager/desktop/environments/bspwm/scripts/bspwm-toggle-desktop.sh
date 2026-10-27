#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

# Busca janelas visíveis (não ocultas) no desktop focado
    visible_nodes=$(bspc query -N -d focused -n .window.!hidden 2>/dev/null)

    if [ -n "$visible_nodes" ]; then
      # Oculta todas as janelas visíveis no workspace
      for node in $visible_nodes; do
        bspc node "$node" -g hidden=on
      done
    else
      # Se não há janelas visíveis, restaura as que estavam ocultas neste workspace
      hidden_nodes=$(bspc query -N -d focused -n .window.hidden 2>/dev/null)
      last_node=""
      for node in $hidden_nodes; do
        bspc node "$node" -g hidden=off
        last_node="$node"
      done
      # Restaura o foco para a última janela reexibida
      if [ -n "$last_node" ]; then
        bspc node "$last_node" -f 2>/dev/null || true
      fi
    fi
