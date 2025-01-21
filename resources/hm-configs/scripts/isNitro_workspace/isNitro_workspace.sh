#!/usr/bin/env bash

set +e          # Disable errexit
set +u          # Disable nounset
set +o pipefail # Disable pipefail

external=xrandr --query | grep '^HDMI-1-0 connected'
vm=xrandr --query | grep '^Virtual-1 connected'

if [[ $HOSTNAME == nitro && $external = *\ connected* ]]; then
  xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
  bspc monitor HDMI-1-0 -d I III V VII IX
  bspc monitor eDP-1 -d II IV VI VIII X
elif [[ $HOSTNAME == scrubber && $vm = *\ connected* ]]; then
  xrandr --output Virtual-1 --primary --mode 1920x1080
  bspc monitor -d I II III IV V VI VII VIII IX X
elif [[ $HOSTNAME == anubis && $external = *\ connected* ]]; then
  xrandr --output eDP-1 --primary --mode 1366x768 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
  bspc monitor HDMI-1 -d I III V VII IX
  bspc monitor eDP-1 -d II IV VI VIII X
else
  bspc monitor -d I II III IV V VI VII VIII IX X
fi
