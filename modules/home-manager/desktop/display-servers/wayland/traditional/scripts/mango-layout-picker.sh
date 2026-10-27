#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2016,SC2028,SC2034,SC2046,SC2059,SC2076,SC2086,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
    fi

    options="󰹑 Scroller (S)\n󰕰 Tile (T)\n󰕲 Center Tile (CT)\n󰝘 Grid (G)\n󰍹 Monocle (M)\n󰓩 Deck (K)\n󰕳 Right Tile (RT)\n󰹒 Vertical Scroller (VS)\n󰕴 Vertical Tile (VT)\n󰝙 Vertical Grid (VG)\n󰓪 Vertical Deck (VK)\n󰕯 Dwindle (DW)\n󰕮 Fair (F)\n󰕬 Vertical Fair (VF)"

    dmenu_sock=$(ls /run/user/$(id -u)/noctalia-dmenu-*.sock 2>/dev/null | head -n1 || true)

    if [ -n "$dmenu_sock" ] && [ -S "$dmenu_sock" ] && command -v noctalia >/dev/null 2>&1; then
      chosen=$(printf "%b" "$options" | noctalia dmenu -p "Layout MangoWM")
    else
      chosen=$(printf "%b" "$options" | rofi -dmenu -i -p " 󱗼 Layout Mango " -theme-str '
        * {
          bg-col: ${c.bg};
          bg-col-light: ${c.bgAlt};
          border-col: ${c.accent};
          selected-col: ${c.surface};
          fg-col: ${c.fg};
          grey: ${c.fgMuted};
          font: "Inter 11";
        }
        window {
          width: 360px;
          height: 520px;
          border: 2px;
          border-color: ${c.accent};
          border-radius: 12px;
          background-color: ${c.bg};
        }
        mainbox {
          background-color: ${c.bg};
          padding: 12px;
        }
        inputbar {
          children: [prompt, entry];
          background-color: ${c.bgAlt};
          border-radius: 8px;
          padding: 6px 10px;
          margin: 0px 0px 8px 0px;
        }
        prompt {
          background-color: ${c.accent};
          padding: 4px 8px;
          text-color: ${c.bgDark};
          border-radius: 6px;
          margin: 0px 8px 0px 0px;
        }
        entry {
          padding: 4px;
          text-color: ${c.fg};
          background-color: transparent;
          placeholder-color: ${c.fgMuted};
        }
        listview {
          border: 0px;
          padding: 4px 0px 0px;
          margin: 0px;
          columns: 1;
          lines: 14;
          background-color: ${c.bg};
        }
        element {
          padding: 6px 10px;
          background-color: ${c.bg};
          text-color: ${c.fg};
          border-radius: 6px;
        }
        element selected {
          background-color: ${c.surface};
          text-color: ${c.accent};
        }
        element-text, element-icon {
          background-color: inherit;
          text-color: inherit;
        }
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
