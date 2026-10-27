#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if ! dunstctl is-paused >/dev/null 2>&1; then
      if [ -n "$DISPLAY" ] && ! pgrep -x dunst >/dev/null 2>&1; then
        pkill -f notification-daemon 2>/dev/null || true
        pkill -f xfce4-notifyd 2>/dev/null || true
        pkill -f mate-notification-daemon 2>/dev/null || true
        pkill -f mako 2>/dev/null || true
        if command -v systemctl >/dev/null 2>&1; then
          systemctl --user import-environment DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS 2>/dev/null || true
          systemctl --user reset-failed dunst 2>/dev/null || true
          systemctl --user start dunst 2>/dev/null || true
        fi
        sleep 0.1
        if ! dunstctl is-paused >/dev/null 2>&1; then
          nohup dunst >/dev/null 2>&1 &
          sleep 0.2
        fi
      fi
    fi

    if ! dunstctl is-paused >/dev/null 2>&1; then
      echo "%{F${COLOR_MUTED:-}}󰂚%{F-}"
      exit 0
    fi

    is_paused=$(dunstctl is-paused 2>/dev/null || echo "false")
    if [ "$is_paused" = "true" ]; then
      echo "%{F${COLOR_RED:-}}󰂛%{F-} %{F${COLOR_MUTED:-}}DND%{F-}"
      exit 0
    fi

    count_history=$(dunstctl count history 2>/dev/null || echo "0")
    count_waiting=$(dunstctl count waiting 2>/dev/null || echo "0")
    count_displayed=$(dunstctl count displayed 2>/dev/null || echo "0")
    total=$(( count_history + count_waiting + count_displayed ))

    if [ "$total" -gt 0 ]; then
      echo "%{F${COLOR_YELLOW:-}}󱅫%{F-} %{F${COLOR_TEXT:-}}$total%{F-}"
    else
      echo "%{F${COLOR_SUBTEXT0:-}}󰂚%{F-}"
    fi
