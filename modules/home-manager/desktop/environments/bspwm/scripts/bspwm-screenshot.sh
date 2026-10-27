#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

dir="${SCREENSHOT_SAVE_PATH:-$HOME/Imagens/Capturas}"
    [ -d "$dir" ] || mkdir -p "$dir"
    timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
    file="$dir/Screenshot_$timestamp.png"

    notify_shot() {
      if [ -f "$1" ]; then
        # Copia imagem diretamente para a área de transferência
        xclip -selection clipboard -t image/png < "$1" 2>/dev/null || true

        # Dispara notificação Dunst com miniatura e ações interativas
        action=$(dunstify -a "Screenshot" \
          -i "$1" \
          -u normal \
          -t 5000 \
          -h string:x-dunst-stack-tag:screenshot \
          "Captura de Tela Realizada" \
          "Salvo em <i>Pictures/Screenshots</i> e copiado para a área de transferência." \
          --action="open,Visualizar" \
          --action="folder,Abrir Pasta" \
          --action="delete,Excluir" 2>/dev/null || echo "")

        case "$action" in
          open) xdg-open "$1" 2>/dev/null || feh "$1" & ;;
          folder) xdg-open "$dir" 2>/dev/null || ${FILE_MANAGER_CMD:-thunar} "$dir" & ;;
          delete) rm -f "$1" && dunstify -a "Screenshot" -u low -t 1500 "Captura excluída" ;;
        esac
      fi
    }

    get_focused_monitor_geo() {
      bspc query -T -m pointed 2>/dev/null | jq -r '.rectangle | "\(.width)x\(.height)+\(.x)+\(.y)"' 2>/dev/null
    }

    case "$1" in
      full|--now)
        # Captura apenas o monitor onde o cursor do mouse está (sem barras pretas multi-monitor)
        geo=$(get_focused_monitor_geo)
        if [ -n "$geo" ] && [ "$geo" != "null" ]; then
          maim -g "$geo" "$file" 2>/dev/null || maim "$file"
        else
          maim "$file"
        fi
        notify_shot "$file"
        ;;

      all|--all)
        # Captura todos os monitores combinados
        maim "$file"
        notify_shot "$file"
        ;;

      area|--sel|-s)
        # Seleção interativa retangular
        sleep 0.2
        # Desativa temporariamente o picom durante o recorte para garantir 100% que a tela fique limpa e sem nenhum blur
        was_picom=0
        if pgrep -x picom >/dev/null 2>&1; then
          was_picom=1
          pkill -x picom 2>/dev/null || true
          sleep 0.05
        fi

        maim -s -u "$file" 2>/dev/null
        ret=$?

        # Restaura o compositor imediatamente após o recorte (ou cancelamento com Esc)
        if [ "$was_picom" -eq 1 ]; then
          (picom -b >/dev/null 2>&1 || picom -b >/dev/null 2>&1 || true) &
        fi

        [ "$ret" -eq 0 ] && notify_shot "$file"
        ;;

      window|--win|-w)
        # Captura a janela atualmente focada
        sleep 0.2
        active_win=$(bspc query -N -n focused 2>/dev/null)
        if [ -n "$active_win" ]; then
          maim -i "$active_win" "$file" 2>/dev/null && notify_shot "$file"
        else
          $0 area
        fi
        ;;

      in3|--in3)
        # Temporizador de 3 segundos com contagem regressiva OSD
        for sec in 3 2 1; do
          dunstify -a "Screenshot" -u low -t 950 -h string:x-dunst-stack-tag:screenshot-timer "Captura em..." "$sec segundo(s)"
          sleep 1
        done
        dunstify -a "Screenshot" -u low -t 500 -h string:x-dunst-stack-tag:screenshot-timer "Capturando..." "Sorria! 📸"
        sleep 0.2
        geo=$(get_focused_monitor_geo)
        if [ -n "$geo" ] && [ "$geo" != "null" ]; then
          maim -g "$geo" "$file" 2>/dev/null || maim "$file"
        else
          maim "$file"
        fi
        notify_shot "$file"
        ;;

      in5|--in5)
        # Temporizador de 5 segundos com contagem regressiva OSD
        for sec in 5 4 3 2 1; do
          dunstify -a "Screenshot" -u low -t 950 -h string:x-dunst-stack-tag:screenshot-timer "Captura em..." "$sec segundo(s)"
          sleep 1
        done
        dunstify -a "Screenshot" -u low -t 500 -h string:x-dunst-stack-tag:screenshot-timer "Capturando..." "Sorria! 📸"
        sleep 0.2
        geo=$(get_focused_monitor_geo)
        if [ -n "$geo" ] && [ "$geo" != "null" ]; then
          maim -g "$geo" "$file" 2>/dev/null || maim "$file"
        else
          maim "$file"
        fi
        notify_shot "$file"
        ;;

      menu|--menu|*)
        OPT_FULL="󰹑  Monitor Atual           (Imediato)"
        OPT_AREA="󰆞  Recorte de Área         (Seleção com cursor)"
        OPT_WIN="󰖲  Janela Ativa            (Focada)"
        OPT_IN3="󱎫  Temporizador (3s)       (Contagem rápida)"
        OPT_IN5="󱎫  Temporizador (5s)       (Contagem regressiva)"
        OPT_ALL="󰍹  Todos os Monitores      (Canvas completo)"
        OPT_DIR="󰈊  Abrir Pasta de Capturas (~/Pictures/Screenshots)"

        CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s" \
          "$OPT_FULL" \
          "$OPT_AREA" \
          "$OPT_WIN" \
          "$OPT_IN3" \
          "$OPT_IN5" \
          "$OPT_ALL" \
          "$OPT_DIR" | rofi -dmenu -i -p " 󰹑 Screenshot " -theme-str 'window { width: 560px; height: 350px; } listview { columns: 1; lines: 7; }')

        case "$CHOICE" in
          *"Monitor Atual"*) $0 full ;;
          *"Recorte de Área"*) sleep 0.2 && $0 area ;;
          *"Janela Ativa"*) sleep 0.2 && $0 window ;;
          *"Temporizador (3s)"*) $0 in3 ;;
          *"Temporizador (5s)"*) $0 in5 ;;
          *"Todos os Monitores"*) $0 all ;;
          *"Abrir Pasta"*) xdg-open "$dir" 2>/dev/null || ${FILE_MANAGER_CMD:-thunar} "$dir" & ;;
        esac
        ;;
    esac
