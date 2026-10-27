#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

BSPC="bspc"
    d="$1"
    follow="$2"

    # Verifica se há janela focada
    cur_node=$($BSPC query -N -n focused 2>/dev/null)
    [ -z "$cur_node" ] && exit 0

    # Verifica se o desktop de destino existe
    if ! $BSPC query -D -d "$d" --names >/dev/null 2>&1; then
      exit 1
    fi

    # Envia a janela para o workspace de destino
    $BSPC node "$cur_node" -d "$d"

    if [ "$follow" = "true" ]; then
      # Localiza o monitor onde o desktop de destino está e foca o monitor, o desktop e a janela
      for m in $($BSPC query -M --names 2>/dev/null); do
        if $BSPC query -D -m "$m" --names 2>/dev/null | grep -qx "$d"; then
          $BSPC monitor -f "$m" 2>/dev/null
          break
        fi
      done
      $BSPC desktop -f "$d" 2>/dev/null
      $BSPC node "$cur_node" -f 2>/dev/null
    fi
