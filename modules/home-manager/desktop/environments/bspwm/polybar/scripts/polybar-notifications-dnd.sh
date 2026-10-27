#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if dunstctl is-paused >/dev/null 2>&1; then
      dunstctl set-paused toggle
    fi
