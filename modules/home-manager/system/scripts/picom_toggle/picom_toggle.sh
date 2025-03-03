#!/usr/bin/env bash

if pgrep -x "picom" >/dev/null; then
  picom
  notify-send picom "Compositing disabled"
else
  picom -b --corner-radius 10
  notify-send picom "Compositing enabled"
fi
