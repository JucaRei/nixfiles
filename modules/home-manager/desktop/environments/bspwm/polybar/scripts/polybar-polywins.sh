#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

monitor="${MONITOR:-}"

    get_desktop() {
      if [ -n "$monitor" ]; then
        bspc query -D -m "$monitor" -d focused 2>/dev/null || bspc query -D -d focused 2>/dev/null
      else
        bspc query -D -d focused 2>/dev/null
      fi
    }

    generate_output() {
      desktop=$(get_desktop)
      [ -z "$desktop" ] && echo "" && return

      all_nodes=$(bspc query -N -d "$desktop" -n .window 2>/dev/null)
      if [ -z "$all_nodes" ]; then
        echo "%{F${COLOR_SURFACE2:-}}󰣆 Área de Trabalho%{F-}"
        return
      fi

      focused_node=$(bspc query -N -d "$desktop" -n .window.focused 2>/dev/null)
      hidden_nodes=$(bspc query -N -d "$desktop" -n .window.hidden 2>/dev/null)

      output=""
      first=true
      count=0

      for wid in $all_nodes; do
        if [ "$count" -ge 6 ]; then
          output="$output %{F${COLOR_SURFACE1:-}}·%{F-} %{F${COLOR_SUBTEXT0:-}}+...%{F-}"
          break
        fi

        wm_class=$(xprop -id "$wid" WM_CLASS 2>/dev/null | awk -F'"' '{print $4}')
        [ -z "$wm_class" ] && wm_class=$(xprop -id "$wid" WM_CLASS 2>/dev/null | awk -F'"' '{print $2}')
        [ -z "$wm_class" ] && wm_class="Janela"

        case "$wm_class" in
          Polybar|polybar|Conky|conky|Dunst|dunst) continue ;;
        esac

        class_lower="${wm_class,,}"
        case "$class_lower" in
          # Terminais
          *alacritty*|*kitty*|*terminal*|*foot*|*wezterm*|*ghostty*|*st*|*urxvt*|*xterm*) icon="" ;;

          # Navegadores Web
          *firefox*|*librewolf*|*floorp*|*zen*|*waterfox*|*tor*)                         icon="󰈹" ;;
          *chrome*|*chromium*|*brave*|*edge*|*vivaldi*|*opera*)                          icon="" ;;

          # Editores de Código e IDEs
          *codium*|*vscode*|*antigravity*|*cursor*|*code*)                                icon="󰨞" ;;
          *zed*)                                                                         icon="󱓷" ;;
          *nvim*|*neovim*|*vim*)                                                         icon="" ;;
          *emacs*)                                                                       icon="" ;;
          *sublime*)                                                                     icon="" ;;

          # Gerenciadores de Arquivos
          *thunar*|*nemo*|*pcmanfm*|*nautilus*|*dolphin*|*ranger*|*yazi*|*nnn*|*lf*)      icon="󰉋" ;;

          # Documentos, Leitores de PDF e Notas
          *zathura*|*evince*|*okular*|*pdf*)                                             icon="󰈦" ;;
          *obsidian*|*notion*|*logseq*)                                                  icon="󱓧" ;;
          *libreoffice*|*soffice*)                                                       icon="󰈙" ;;

          # Comunicação e Mensagens
          *discord*|*vesktop*|*webcord*|*legcord*)                                       icon="󰙯" ;;
          *telegram*|*tg*)                                                               icon="" ;;
          *slack*)                                                                       icon="󰒱" ;;
          *whatsapp*)                                                                    icon="󰖣" ;;
          *signal*)                                                                      icon="󰭹" ;;
          *element*)                                                                     icon="󰚀" ;;
          *thunderbird*|*betterbird*|*mail*)                                             icon="󰇮" ;;

          # Música e Áudio
          *spotify*)                                                                     icon="󰓇" ;;
          *audacity*)                                                                    icon="󱑽" ;;
          *cava*)                                                                        icon="󰝚" ;;
          *ncmpcpp*)                                                                     icon="󰎆" ;;

          # Vídeo e Transmissão
          *mpv*|*vlc*|*celluloid*|*clapper*)                                             icon="󰎁" ;;
          *obs-studio*|*obs*)                                                            icon="󰑋" ;;

          # Imagem, Gráficos e Design
          *gimp*)                                                                        icon="" ;;
          *inkscape*)                                                                    icon="󰫐" ;;
          *blender*)                                                                     icon="󰂫" ;;
          *viewnior*|*feh*|*nsxiv*|*sxiv*|*imv*)                                         icon="󰋩" ;;

          # Jogos e Emuladores
          *steam*|*lutris*|*heroic*)                                                     icon="󰓓" ;;
          *retroarch*)                                                                   icon="󰊴" ;;
          *minecraft*|*prism*)                                                           icon="󰍳" ;;

          # Utilitários, Sistema e Configuração
          *pavucontrol*|*pulsemixer*|*alsamixer*)                                        icon="󰕾" ;;
          *lxappearance*|*nwg-look*|*kvantum*)                                           icon="󰔎" ;;
          *btop*|*htop*|*bottom*)                                                        icon="󰄧" ;;
          *scrcpy*)                                                                      icon="󰄡" ;;
          *virtualbox*|*virt-manager*|*qemu*)                                            icon="󰢹" ;;
          *rofi*|*dmenu*)                                                                icon="󰍉" ;;
          *nitrogen*)                                                                    icon="󰸉" ;;

          # Ícone genérico de janela padrão
          *)                                                                             icon="󰣆" ;;
        esac

        display_name=$(echo "$wm_class" | cut -c1-12)

        is_focused=false
        [ "$wid" = "$focused_node" ] && is_focused=true

        is_hidden=false
        if echo "$hidden_nodes" | grep -qw "$wid" 2>/dev/null; then
          is_hidden=true
        fi

        if [ "$is_focused" = true ]; then
          act_left="bspc node $wid -g hidden=on"
        elif [ "$is_hidden" = true ]; then
          act_left="bspc node $wid -g hidden=off -f"
        else
          act_left="bspc node $wid -f"
        fi
        act_mid="bspc node $wid -c"
        act_right="bspc node $wid -t ~floating"

        if [ "$is_hidden" = true ]; then
          item="%{A1:$act_left:}%{A2:$act_mid:}%{A3:$act_right:}%{F${COLOR_PEACH:-}}󰖯 %{F${COLOR_SURFACE2:-}}$icon $display_name%{F-}%{A}%{A}%{A}"
        elif [ "$is_focused" = true ]; then
          item="%{A1:$act_left:}%{A2:$act_mid:}%{A3:$act_right:}%{F${COLOR_BLUE:-}}$icon %{F${COLOR_TEXT:-}}$display_name%{F-}%{A}%{A}%{A}"
        else
          item="%{A1:$act_left:}%{A2:$act_mid:}%{A3:$act_right:}%{F${COLOR_SUBTEXT0:-}}$icon $display_name%{F-}%{A}%{A}%{A}"
        fi

        if [ "$first" = true ]; then
          output="$item"
          first=false
        else
          output="$output %{F${COLOR_SURFACE1:-}}·%{F-} $item"
        fi
        count=$((count + 1))
      done

      echo "$output"
    }

    generate_output

    bspc subscribe node_focus node_add node_remove node_flag node_state desktop_focus 2>/dev/null | while read -r _; do
      generate_output
    done
