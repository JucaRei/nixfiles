#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if ! command -v playerctl >/dev/null 2>&1; then
      exit 0
    fi

    status=$(playerctl status 2>/dev/null || echo "")
    [ -z "$status" ] && exit 0

    title=$(playerctl metadata title 2>/dev/null || echo "")
    artist=$(playerctl metadata artist 2>/dev/null || echo "")

    if [ -n "$artist" ] && [ -n "$title" ]; then
      track="$artist - $title"
    elif [ -n "$title" ]; then
      track="$title"
    else
      track="Mídia"
    fi

    display_track=$(echo "$track" | cut -c1-35)
    [ "${#track}" -gt 35 ] && display_track="${display_track}..."

    btn_prev="%{A1:polybar-media-control prev:}%{F${COLOR_BLUE:-}}󰒮%{F-}%{A}"
    btn_next="%{A1:polybar-media-control next:}%{F${COLOR_BLUE:-}}󰒭%{F-}%{A}"
    btn_stop="%{A1:polybar-media-control stop:}%{F${COLOR_RED:-}}󰓛%{F-}%{A}"

    if [ "$status" = "Playing" ]; then
      btn_play_pause="%{A1:polybar-media-control play-pause:}%{F${COLOR_GREEN:-}}󰏤%{F-}%{A}"
      track_label="%{A1:polybar-media-control play-pause:}%{F${COLOR_MAUVE:-}}󰎈%{F-} %{F${COLOR_TEXT:-}}$display_track%{F-}%{A}"
      echo "$btn_prev  $btn_play_pause  $btn_next  $btn_stop  %{F${COLOR_SURFACE1:-}}│%{F-}  $track_label"
    elif [ "$status" = "Paused" ]; then
      btn_play_pause="%{A1:polybar-media-control play-pause:}%{F${COLOR_PEACH:-}}󰐊%{F-}%{A}"
      track_label="%{A1:polybar-media-control play-pause:}%{F${COLOR_SURFACE2:-}}󰎊 $display_track%{F-}%{A}"
      echo "$btn_prev  $btn_play_pause  $btn_next  $btn_stop  %{F${COLOR_SURFACE1:-}}│%{F-}  $track_label"
    else
      echo ""
    fi
