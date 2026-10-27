#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

action="$1" # "next" or "prev"
    wid="$(xdotool getactivewindow 2>/dev/null)"
    [ -z "$wid" ] && exit 0
    wclass="$(xprop -id "$wid" WM_CLASS 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    case "$wclass" in
      *firefox*|*librewolf*|*floorp*|*chrome*|*chromium*|*brave*|*opera*|*vivaldi*|*edge*|*zen*|*code*|*antigravity*|*alacritty*)
        if [ "$action" = "next" ]; then
          xdotool key --clearmodifiers ctrl+Page_Down
        else
          xdotool key --clearmodifiers ctrl+Page_Up
        fi
        ;;
    esac
