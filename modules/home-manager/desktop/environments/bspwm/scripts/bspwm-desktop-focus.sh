#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

BSPC="bspc"
    d="$1"
    # 1. Tenta focar diretamente no monitor atual
    $BSPC desktop -f "$d" 2>/dev/null && exit 0
    # 2. Se o workspace estiver em outro monitor, localiza o monitor e foca
    for m in $($BSPC query -M --names 2>/dev/null); do
      if $BSPC query -D -m "$m" --names 2>/dev/null | grep -qx "$d"; then
        $BSPC monitor -f "$m" 2>/dev/null && $BSPC desktop -f "$d" 2>/dev/null
        exit 0
      fi
    done
