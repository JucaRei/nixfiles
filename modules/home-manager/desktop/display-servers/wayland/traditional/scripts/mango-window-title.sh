#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2016,SC2028,SC2034,SC2046,SC2059,SC2076,SC2086,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
    fi
    INFO=$(mmsg get focusing-client 2>/dev/null)
    if [ -z "$INFO" ] || [ "$INFO" = "null" ]; then
      echo '{"text": "", "tooltip": "", "class": "empty"}'
      exit 0
    fi
    TITLE=$(echo "$INFO" | jq -r '.title // empty' 2>/dev/null)
    APPID=$(echo "$INFO" | jq -r '.appid // empty' 2>/dev/null)
    if [ -z "$TITLE" ]; then
      echo '{"text": "", "tooltip": "", "class": "empty"}'
      exit 0
    fi
    ICON="󰣆"
    case "$APPID" in
      *alacritty*|*kitty*|*terminal*|*foot*|*wezterm*|*ghostty*|*st*) ICON="" ;;
      *firefox*|*librewolf*|*floorp*|*zen*|*tor*) ICON="󰈹" ;;
      *chrome*|*chromium*|*brave*|*edge*|*vivaldi*|*opera*) ICON="" ;;
      *code*|*codium*|*vscode*|*antigravity*|*cursor*) ICON="󰨞" ;;
      *zed*)      ICON="󱓷" ;;
      *nvim*|*neovim*|*vim*) ICON="" ;;
      *thunar*|*nautilus*|*nemo*|*pcmanfm*|*dolphin*|*yazi*) ICON="󰉋" ;;
      *discord*|*vesktop*) ICON="󰙯" ;;
      *spotify*)  ICON="󰓇" ;;
      *mpv*|*vlc*) ICON="󰎁" ;;
      *steam*)    ICON="󰓓" ;;
      *zathura*|*pdf*) ICON="󰈦" ;;
      *obsidian*) ICON="󱓧" ;;
    esac
    TRUNCATED=$(echo "$TITLE" | cut -c 1-38)
    [ "${#TITLE}" -gt 38 ] && TRUNCATED="$TRUNCATED..."
    ESCAPED_TEXT=$(echo "$ICON $TRUNCATED" | sed 's/"/\\"/g')
    ESCAPED_TOOLTIP=$(echo "$APPID: $TITLE" | sed 's/"/\\"/g')
    echo "{\"text\": \"$ESCAPED_TEXT\", \"tooltip\": \"$ESCAPED_TOOLTIP\", \"class\": \"$APPID\"}"
