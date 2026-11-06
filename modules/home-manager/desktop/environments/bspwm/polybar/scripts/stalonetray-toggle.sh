#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222
export LC_ALL=C

find_tray_wid() {
  local w
  w=$(xdotool search --class "(?i)stalonetray" 2>/dev/null | head -n1 || true)
  if [ -z "$w" ]; then
    w=$(xdotool search --name "(?i)stalonetray" 2>/dev/null | head -n1 || true)
  fi
  echo "$w"
}

if [ "${1:-}" = "restart" ]; then
  pkill -x stalonetray 2>/dev/null || true
  sleep 0.2
  stalonetray &
  exit 0
fi

if ! pgrep -x "stalonetray" >/dev/null 2>&1; then
  stalonetray &
  sleep 0.3
  wid=$(find_tray_wid)
  [ -n "$wid" ] && xdotool windowraise "$wid" 2>/dev/null || true
  exit 0
fi

wid=$(find_tray_wid)

if [ -z "$wid" ]; then
  pkill -x stalonetray 2>/dev/null || true
  sleep 0.2
  stalonetray &
  sleep 0.3
  wid=$(find_tray_wid)
  [ -n "$wid" ] && xdotool windowraise "$wid" 2>/dev/null || true
  exit 0
fi

if xdotool search --onlyvisible --class "(?i)stalonetray" 2>/dev/null | grep -q "^${wid}$"; then
  xdotool windowunmap "$wid" 2>/dev/null || true
else
  xdotool windowmap "$wid" 2>/dev/null || true
  xdotool windowraise "$wid" 2>/dev/null || true
fi
