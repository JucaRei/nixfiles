#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

color=$(xcolor -s 2>/dev/null || true)
    [ -z "$color" ] && exit 0

    echo -n "$color" | xclip -selection clipboard

    dunstify -a "Colorpicker" \
      -u low \
      -i "color-picker" \
      -h string:x-dunst-stack-tag:colorpicker \
      -t 3500 \
      "Cor Capturada" \
      "Código: <b>$color</b> copiado para a área de transferência!"
