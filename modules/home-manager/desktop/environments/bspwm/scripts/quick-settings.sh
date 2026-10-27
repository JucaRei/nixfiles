#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

show_manual() {
          KB_LIST="󰌌  ${MOD_NAME:-Super} + Space / ${MOD_NAME:-Super} + D     ➜  Lançador de Aplicativos (Rofi)
    󰌌  ${MOD_NAME:-Super} + Enter / ${MOD_NAME:-Super} + T     ➜  Abrir Terminal (${TERMINAL_NAME:-Terminal})
    󰌌  ${MOD_NAME:-Super} + B                     ➜  Navegador Web Padrão
    󰌌  ${MOD_NAME:-Super} + Shift + B             ➜  Menu Interativo de Bluetooth
    󰌌  ${MOD_NAME:-Super} + E / ${MOD_NAME:-Super} + Shift + E ➜  Gerenciador de Arquivos (${fmName})
    󰌌  ${MOD_NAME:-Super} + , / ${MOD_NAME:-Super} + C / Botão Dir. ➜ Painel Quick Settings / Preferências
    󰌌  ${MOD_NAME:-Super} + / ou ${MOD_NAME:-Super} + F1       ➜  Manual e Guia de Atalhos (Cheat-Sheet)
    󰌌  ${MOD_NAME:-Super} + W                     ➜  Alternador de Janelas Abertas
    󰌌  ${MOD_NAME:-Super} + U                     ➜  Terminal Flutuante Rápido (Scratchpad)
    󰌌  ${MOD_NAME:-Super} + Q / ${MOD_NAME:-Super} + Shift + Q ➜  Fechar / Encerrar Janela
    󰌌  ${MOD_NAME:-Super} + Shift + Escape        ➜  Forçar Fechamento de Janela Travada
    󰌌  ${MOD_NAME:-Super} + A                     ➜  Alternar Tela Cheia (Fullscreen)
    󰌌  ${MOD_NAME:-Super} + F / ${MOD_NAME:-Super} + S ➜  Alternar Janela Flutuante (Floating/Tiling)
    󰌌  ${MOD_NAME:-Super} + Shift + F / Shift + T ➜  Alternar Janela Pseudo-Tiled (Grade com Tamanho Natural)
    󰌌  ${MOD_NAME:-Super} + M                     ➜  Modo Monocle (Foco em Janela Única)
    󰌌  ${MOD_NAME:-Super} + Y / ${MOD_NAME:-Super} + Minus     ➜  Esconder / Minimizar Janela Ativa
    󰌌  ${MOD_NAME:-Super} + Shift + Y / Shift+-  ➜  Restaurar Última Janela Escondida
    󰌌  ${MOD_NAME:-Super} + Shift + M            ➜  Mostrar Desktop (Minimizar/Restaurar Todas)
    󰌌  ${MOD_NAME:-Super} + Tab / Shift + Tab       ➜  Alternar Foco Entre Janelas (Próxima/Anterior)
    󰌌  ${MOD_NAME:-Super} + \` (Grave) / Shift + \`   ➜  Alternar Foco Entre Janelas (Próxima/Anterior)
    󰌌  ${MOD_NAME:-Super} + Ctrl + Tab / Shift+Tab  ➜  Trocar Janela com Próxima / Anterior (Swap)
    󰌌  ${MOD_NAME:-Super} + Ctrl + Space           ➜  Ciclar Layouts (Tall, Wide, Grid, Even, Monocle...)
    󰌌  ${MOD_NAME:-Super} + Ctrl + L               ➜  Menu Interativo de Layouts (bsp-layout)
    󰌌  ${MOD_NAME:-Super} + {H,J,K,L} ou Setas    ➜  Navegar Foco Entre Janelas (Vim/Setas)
    󰌌  ${MOD_NAME:-Super} + Shift + {H,J,K,L}     ➜  Mover / Trocar Posição da Janela
    󰌌  ${MOD_NAME:-Super} + Ctrl + Setas          ➜  Redimensionar Tamanho da Janela
    󰌌  ${MOD_NAME:-Super} + Botão Esquerdo        ➜  Mover Janela Flutuante com o Mouse
    󰌌  ${MOD_NAME:-Super} + Botão Direito         ➜  Redimensionar Janela com o Mouse
    󰌌  ${MOD_NAME:-Super} + 1..9, 0               ➜  Ir para Área de Trabalho (Workspace) 1 a 10
    󰌌  ${MOD_NAME:-Super} + Shift + 1..9, 0       ➜  Enviar Janela para Workspace 1 a 10
    󰌌  ${MOD_NAME:-Super} + Ctrl + 1..9, 0        ➜  Enviar Janela sem Seguir (Segundo Plano)
    󰌌  Print / ${MOD_NAME:-Super} + Print         ➜  Captura Imediata / Menu ScreenShoTer
    󰌌  Shift + Print / ${MOD_NAME:-Super} + Shift + S ➜  Recorte de Área Interativo
    󰌌  Ctrl + Print                              ➜  Capturar Janela Ativa
    󰌌  ${MOD_NAME:-Super} + Shift + Print         ➜  Captura com Temporizador (5s)
    󰌌  ${MOD_NAME:-Super} + P                     ➜  Conta-gotas de Cor (Colorpicker)
    󰌌  ${MOD_NAME:-Super} + Shift + R             ➜  Recarregar BSPWM e Polybar
    󰌌  ${MOD_NAME:-Super} + Shift + L / ${MOD_NAME:-Super} + Ctrl + Q ➜ Bloquear Sessão do Usuário
    󰌌  Teclas de Volume / Brilho / Mídia ➜  Controle com Feedback Visual OSD"

          CHOICE=$(echo "$KB_LIST" | rofi -dmenu -i -p " 󰌌 Manual de Atalhos (Keybinds) " -theme-str 'window { width: 720px; height: 520px; } listview { columns: 1; lines: 12; }')

          case "$CHOICE" in
            *"Lançador de Aplicativos"*) rofi -show drun ;;
            *"Abrir Terminal"*) ${TERMINAL_CMD:-alacritty} & ;;
            *"Navegador Web Padrão"*) ${BROWSER_CMD:-firefox} ;;
            *"Menu Interativo de Bluetooth"*) rofi-bluetooth & ;;
            *"Gerenciador de Arquivos"*) ${FILE_MANAGER_CMD:-thunar} ~ & ;;
            *"Painel Quick Settings"*) show_control_center ;;
            *"Alternador de Janelas"*) rofi -show window ;;
            *"Alternar Foco Entre Janelas"*) bspc node -f next.local.!hidden.window || bspc node -f next.local.window ;;
            *"Menu Interativo de Layouts"*) rofi-bsp-layout & ;;
            *"Ciclar Layouts"*) bsp-layout-switch next & ;;
            *"Terminal Flutuante"*) bspwm-scratchpad ;;
            *"Fechar / Encerrar Janela"*) bspc node -c ;;
            *"Tela Cheia"*) bspc node -t '~fullscreen' ;;
            *"Janela Flutuante"*) bspc node -t '~floating' ;;
            *"Pseudo-Tiled"*|*"Pseudo-tiled"*) bspwm-toggle-pseudo-tile ;;
            *"Esconder / Minimizar Janela"*) bspc node -g hidden=on ;;
            *"Restaurar Última Janela"*) bspc node any.hidden.local -g hidden=off -f ;;
            *"Captura de Tela"*) bspwm-screenshot menu & ;;
            *"Recorte de Área"*) bspwm-screenshot area & ;;
            *"Conta-gotas"*) bspwm-colorpicker & ;;
            *"Recarregar BSPWM"*) bspc wm -r ;;
            *"Bloquear Sessão"*) bspwm-lock || loginctl lock-session ;;
          esac
        }

        show_control_center() {
          OPT_SHOT="󰹑  Captura de Tela & Recorte (ScreenShoTer)"
          OPT_COLOR="󰈊  Conta-gotas de Cor (Colorpicker)"
          OPT_BT="󰂯  Dispositivos Bluetooth (rofi-bluetooth)"
          OPT_LAYOUT="󰕰  Gerenciador de Layouts (rofi-bsp-layout)"
          OPT_PSEUDO="󱒆  Alternar Janela Pseudo-Tiled (Pseudo-Tiling)"
          OPT_RES="󰍹  Resolução da Tela (Display Resolution)"
          OPT_TOUCH="󰟸  Velocidade do Touchpad (Touchpad Speed)"
          OPT_SOUND="󰕾  Controle de Áudio & Volume (Pavucontrol)"
          OPT_NET="󰖩  Wi-Fi & Conexões (NetworkManager)"
          OPT_THEME="󰔎  Aparência, Ícones & Temas (LXAppearance)"
          OPT_WALL="󰸉  Papel de Parede (Wallpaper)"
          OPT_BROWSER="󰈹  Navegador Web (Firefox / Padrão)"
          OPT_FILES="󰉋  Gerenciador de Arquivos (${fmName})"
          OPT_TERM="󰞷  Abrir Terminal (${TERMINAL_NAME:-Terminal})"
          OPT_KEYS="󰌌  Manual & Guia de Atalhos (Keybinds)"
          OPT_RELOAD="󰑐  Recarregar BSPWM & Polybar"
          OPT_POWER="󰐥  Menu de Energia & Bloqueio de Sessão"

          CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s" \
            "$OPT_SHOT" \
            "$OPT_COLOR" \
            "$OPT_BT" \
            "$OPT_LAYOUT" \
            "$OPT_PSEUDO" \
            "$OPT_RES" \
            "$OPT_TOUCH" \
            "$OPT_SOUND" \
            "$OPT_NET" \
            "$OPT_THEME" \
            "$OPT_WALL" \
            "$OPT_BROWSER" \
            "$OPT_FILES" \
            "$OPT_TERM" \
            "$OPT_KEYS" \
            "$OPT_RELOAD" \
            "$OPT_POWER" | rofi -dmenu -i -p " 󱗼 Quick Settings " \
            -theme-str 'window {width: 620px; border-radius: 14px;} listview {columns: 1; lines: 17;}')

          case "$CHOICE" in
            "$OPT_SHOT") bspwm-screenshot menu & ;;
            "$OPT_COLOR") bspwm-colorpicker & ;;
            "$OPT_BT") rofi-bluetooth & ;;
            "$OPT_LAYOUT") rofi-bsp-layout & ;;
            "$OPT_PSEUDO") bspwm-toggle-pseudo-tile ;;
            "$OPT_RES")
              R_1080="1920x1080 (Full HD 1080p)"
              R_2K="2560x1440 (Quad HD 2K)"
              R_900="1600x900 (HD+)"
              R_768="1366x768 (HD)"
              R_CUSTOM="⚙ Painel Avançado de Telas (ARandR)"

              RES=$(printf "%s\n%s\n%s\n%s\n%s" "$R_1080" "$R_2K" "$R_900" "$R_768" "$R_CUSTOM" | rofi -dmenu -i -p " 󰍹 Selecionar Resolução " -theme-str 'window {width: 500px; border-radius: 14px;} listview {columns: 1; lines: 5;}')
              case "$RES" in
                "$R_1080") xrandr -s 1920x1080 ;;
                "$R_2K")   xrandr -s 2560x1440 ;;
                "$R_900")  xrandr -s 1600x900 ;;
                "$R_768")  xrandr -s 1366x768 ;;
                "$R_CUSTOM") arandr || xrandr ;;
              esac
              ;;
            "$OPT_TOUCH")
              T_DEF="󰟸  0.0  (Padrão do Sistema / Lento)"
              T_MOD="󰟸  0.3  (Moderado)"
              T_FAST="󰟸  0.5  (Rápido & Ágil - Recomendado)"
              T_VFAST="󰟸  0.7  (Muito Rápido)"
              T_MAX="󰟸  1.0  (Velocidade Máxima)"
              T_SEL=$(printf "%s\n%s\n%s\n%s\n%s" "$T_DEF" "$T_MOD" "$T_FAST" "$T_VFAST" "$T_MAX" | rofi -dmenu -i -p " 󰟸 Velocidade do Touchpad " -theme-str 'window {width: 540px; border-radius: 14px;} listview {columns: 1; lines: 5;}')
              case "$T_SEL" in
                *"0.0"*) touchpad-speed 0.0 ;;
                *"0.3"*) touchpad-speed 0.3 ;;
                *"0.5"*) touchpad-speed 0.5 ;;
                *"0.7"*) touchpad-speed 0.7 ;;
                *"1.0"*) touchpad-speed 1.0 ;;
              esac
              ;;
            "$OPT_SOUND") pavucontrol & ;;
            "$OPT_NET") nm-connection-editor & ;;
            "$OPT_THEME") lxappearance & ;;
            "$OPT_WALL")
              if command -v set-wallpaper >/dev/null 2>&1; then
                set-wallpaper --random &
              elif [ -x "nitrogen" ]; then
                nitrogen &
              else
                feh &
              fi
              ;;
            "$OPT_BROWSER")
              if [ -n "$BROWSER" ]; then "$BROWSER" & else xdg-open https:// 2>/dev/null || firefox & fi
              ;;
            "$OPT_FILES") ${FILE_MANAGER_CMD:-thunar} ~ & ;;
            "$OPT_TERM") ${TERMINAL_CMD:-alacritty} & ;;
            "$OPT_KEYS") show_manual ;;
            "$OPT_RELOAD")
              bspc wm -r
              dunstify -a "Sistema" -u low -i "view-refresh" -t 2000 "BSPWM e Polybar recarregados com sucesso!"
              ;;
            "$OPT_POWER")
              rofi -show power-menu -modi "power-menu:rofi-power-menu" || bspwm-lock || loginctl lock-session
              ;;
          esac
        }

        case "$1" in
          --manual) show_manual ;;
          *) show_control_center ;;
        esac
