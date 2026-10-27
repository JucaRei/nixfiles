#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

# Identifica a janela X11 sob as coordenadas atuais do cursor do mouse
    mouse_win="$(xdotool getmouselocation --shell 2>/dev/null | awk -F= '/WINDOW/{print $2}')"
    [ -z "$mouse_win" ] && exit 0

    root_win="$(xdotool getrootwindow 2>/dev/null)"

    # Se a janela sob o mouse for exatamente a Root Window (Desktop limpo)
    if [ -n "$root_win" ] && [ "$mouse_win" = "$root_win" ]; then
      exec quick-settings
    fi

    # Se for uma janela com _NET_WM_WINDOW_TYPE_DESKTOP (ex: xfdesktop ou desktop gerenciado)
    if xprop -id "$mouse_win" _NET_WM_WINDOW_TYPE 2>/dev/null | grep -q "_NET_WM_WINDOW_TYPE_DESKTOP"; then
      exec quick-settings
    fi
