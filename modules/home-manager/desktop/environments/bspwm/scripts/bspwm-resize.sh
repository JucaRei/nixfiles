#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

# ==============================================================================
# bspwm-resize: Redimensionamento Bidirecional Inteligente de Janelas
# Permite tanto AUMENTAR quanto DIMINUIR janelas tiled e floating com precisão.
# ==============================================================================

step="${2:-20}"
dir="${1:-right}"

case "$dir" in
  left|west|h)
    # Empurra a divisão para a esquerda:
    # Se a janela for o nó à esquerda, encolhe a borda direita.
    # Se for o nó à direita, expande a borda esquerda para a esquerda.
    bspc node -z right -"$step" 0 2>/dev/null || bspc node -z left -"$step" 0 2>/dev/null || true
    ;;
  right|east|l)
    # Empurra a divisão para a direita:
    # Se a janela for o nó à esquerda, expande a borda direita para a direita.
    # Se for o nó à direita, encolhe a borda esquerda para a direita.
    bspc node -z right +"$step" 0 2>/dev/null || bspc node -z left +"$step" 0 2>/dev/null || true
    ;;
  up|north|k)
    # Empurra a divisão para cima:
    # Se a janela estiver no topo, encolhe a borda inferior para cima.
    # Se estiver na base, expande a borda superior para cima.
    bspc node -z bottom 0 -"$step" 2>/dev/null || bspc node -z top 0 -"$step" 2>/dev/null || true
    ;;
  down|south|j)
    # Empurra a divisão para baixo:
    # Se a janela estiver no topo, expande a borda inferior para baixo.
    # Se estiver na base, encolhe a borda superior para baixo.
    bspc node -z bottom 0 +"$step" 2>/dev/null || bspc node -z top 0 +"$step" 2>/dev/null || true
    ;;
esac
