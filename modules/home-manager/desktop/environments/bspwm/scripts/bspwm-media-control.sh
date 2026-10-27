#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

case "$1" in
      play-pause) playerctl play-pause 2>/dev/null ;;
      next)       playerctl next 2>/dev/null ;;
      prev)       playerctl previous 2>/dev/null ;;
      stop)       playerctl stop 2>/dev/null ;;
    esac

    sleep 0.1
    status=$(playerctl status 2>/dev/null || echo "Parado")
    track_info=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null || true)

    case "$status" in
      Playing)   icon="media-playback-start"; header="Reproduzindo" ;;
      Paused)    icon="media-playback-pause"; header="Pausado" ;;
      *)         icon="media-playback-stop";  header="Reprodutor" ;;
    esac

    if [ -n "$track_info" ] && [ "$track_info" != " - " ]; then
      dunstify -a "Mídia" \
        -u low \
        -i "$icon" \
        -h string:x-dunst-stack-tag:media \
        -t 2000 \
        "$header" \
        "<b>$track_info</b>"
    fi
