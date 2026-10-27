#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if ! pgrep -x "stalonetray" >/dev/null 2>&1; then
      stalonetray &
      sleep 0.2
      wid=$(xdotool search --class Stalonetray 2>/dev/null | head -n1 || xdotool search --class stalonetray 2>/dev/null | head -n1)
      [ -n "$wid" ] && xdotool windowraise "$wid"
    else
      wid=$(xdotool search --class Stalonetray 2>/dev/null | head -n1 || xdotool search --class stalonetray 2>/dev/null | head -n1)
      if [ -n "$wid" ]; then
        if xdotool search --onlyvisible --class Stalonetray 2>/dev/null | grep -q "^$wid$" || xdotool search --onlyvisible --class stalonetray 2>/dev/null | grep -q "^$wid$"; then
          xdotool windowunmap "$wid"
        else
          xdotool windowmap "$wid"
          xdotool windowraise "$wid"
        fi
      else
        pkill -x stalonetray || true
        stalonetray &
      fi
    fi
