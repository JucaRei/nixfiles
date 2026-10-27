#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if [ -f /proc/uptime ]; then
      seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
      hours=$((seconds / 3600))
      minutes=$(((seconds % 3600) / 60))
      if [ "$hours" -gt 0 ]; then
        echo "%{F${COLOR_LAVENDER:-}}󰔚%{F-} ${hours}h ${minutes}m"
      else
        echo "%{F${COLOR_LAVENDER:-}}󰔚%{F-} ${minutes}m"
      fi
    else
      echo "%{F${COLOR_LAVENDER:-}}󰔚%{F-} up"
    fi
