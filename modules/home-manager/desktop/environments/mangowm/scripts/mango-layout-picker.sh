#!/usr/bin/env bash
set -euo pipefail

if [ -z "${MANGO_INSTANCE_SIGNATURE:-}" ]; then
  export MANGO_INSTANCE_SIGNATURE
  MANGO_INSTANCE_SIGNATURE=$(find /run/user/"$(id -u)" -maxdepth 1 -name "mango-*.sock" 2>/dev/null | head -n1 || true)
fi

options="󰹑 Scroller (S)\n󰕰 Tile (T)\n󰕲 Center Tile (CT)\n󰝘 Grid (G)\n󰍹 Monocle (M)\n󰓩 Deck (K)\n󰕳 Right Tile (RT)\n󰹒 Vertical Scroller (VS)\n󰕴 Vertical Tile (VT)\n󰝙 Vertical Grid (VG)\n󰓪 Vertical Deck (VK)\n󰕯 Dwindle (DW)\n󰕮 Fair (F)\n󰕬 Vertical Fair (VF)"
dmenu_sock=$(find /run/user/"$(id -u)" -maxdepth 1 -name "noctalia-dmenu-*.sock" 2>/dev/null | head -n1 || true)

if [ -n "$dmenu_sock" ] && [ -S "$dmenu_sock" ] && command -v noctalia >/dev/null 2>&1; then
  chosen=$(printf "%b" "$options" | noctalia dmenu -p "Layout MangoWM")
else
  chosen=$(printf "%b" "$options" | rofi -dmenu -i -p " 󱗼 Layout Mango " -theme-str '
    * { bg-col: @BG@; bg-col-light: @BG_ALT@; border-col: @ACCENT@; selected-col: @SURFACE@; fg-col: @FG@; grey: @FG_MUTED@; font: "Inter 11"; }
    window { width: 360px; height: 520px; border: 2px; border-color: @ACCENT@; border-radius: 12px; background-color: @BG@; }
    mainbox { background-color: @BG@; padding: 12px; }
    inputbar { children: [prompt, entry]; background-color: @BG_ALT@; border-radius: 8px; padding: 6px 10px; margin: 0px 0px 8px 0px; }
    prompt { background-color: @ACCENT@; padding: 4px 8px; text-color: @BG_DARK@; border-radius: 6px; margin: 0px 8px 0px 0px; }
    entry { padding: 4px; text-color: @FG@; background-color: transparent; placeholder-color: @FG_MUTED@; }
    listview { border: 0px; padding: 4px 0px 0px; margin: 0px; columns: 1; lines: 14; background-color: @BG@; }
    element { padding: 6px 10px; background-color: @BG@; text-color: @FG@; border-radius: 6px; }
    element selected { background-color: @SURFACE@; text-color: @ACCENT@; }
    element-text, element-icon { background-color: inherit; text-color: inherit; }
  ')
fi

case "$chosen" in
  *"Scroller (S)"*)           mmsg dispatch setlayout,scroller >/dev/null 2>&1 ;;
  *"Tile (T)"*)               mmsg dispatch setlayout,tile >/dev/null 2>&1 ;;
  *"Center Tile (CT)"*)       mmsg dispatch setlayout,center_tile >/dev/null 2>&1 ;;
  *"Grid (G)"*)               mmsg dispatch setlayout,grid >/dev/null 2>&1 ;;
  *"Monocle (M)"*)            mmsg dispatch setlayout,monocle >/dev/null 2>&1 ;;
  *"Deck (K)"*)               mmsg dispatch setlayout,deck >/dev/null 2>&1 ;;
  *"Right Tile (RT)"*)        mmsg dispatch setlayout,right_tile >/dev/null 2>&1 ;;
  *"Vertical Scroller (VS)"*) mmsg dispatch setlayout,vertical_scroller >/dev/null 2>&1 ;;
  *"Vertical Tile (VT)"*)     mmsg dispatch setlayout,vertical_tile >/dev/null 2>&1 ;;
  *"Vertical Grid (VG)"*)     mmsg dispatch setlayout,vertical_grid >/dev/null 2>&1 ;;
  *"Vertical Deck (VK)"*)     mmsg dispatch setlayout,vertical_deck >/dev/null 2>&1 ;;
  *"Dwindle (DW)"*)           mmsg dispatch setlayout,dwindle >/dev/null 2>&1 ;;
  *"Fair (F)"*)               mmsg dispatch setlayout,fair >/dev/null 2>&1 ;;
  *"Vertical Fair (VF)"*)     mmsg dispatch setlayout,vertical_fair >/dev/null 2>&1 ;;
esac
pkill -RTMIN+8 waybar 2>/dev/null || true

