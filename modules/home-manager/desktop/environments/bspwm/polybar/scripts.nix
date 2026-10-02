{
  pkgs,
  colors,
  lib ? pkgs.lib,
  ...
}:
{
  # --- Taskbar Interativa de Janelas (Polywins para BSPWM) ---
  polywinsScript = pkgs.writeShellScript "polybar-polywins" ''
    export PATH="${lib.makeBinPath [ pkgs.bspwm pkgs.xprop pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.gawk ]}:$PATH"

    monitor="''${MONITOR:-}"

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
        echo "%{F${colors.surface2}}󰣆 Área de Trabalho%{F-}"
        return
      fi

      focused_node=$(bspc query -N -d "$desktop" -n .window.focused 2>/dev/null)
      hidden_nodes=$(bspc query -N -d "$desktop" -n .window.hidden 2>/dev/null)

      output=""
      first=true
      count=0

      for wid in $all_nodes; do
        if [ "$count" -ge 6 ]; then
          output="$output %{F${colors.surface1}}·%{F-} %{F${colors.subtext0}}+...%{F-}"
          break
        fi

        wm_class=$(xprop -id "$wid" WM_CLASS 2>/dev/null | awk -F'"' '{print $4}')
        [ -z "$wm_class" ] && wm_class=$(xprop -id "$wid" WM_CLASS 2>/dev/null | awk -F'"' '{print $2}')
        [ -z "$wm_class" ] && wm_class="Janela"

        case "$wm_class" in
          Polybar|polybar|Conky|conky|Dunst|dunst) continue ;;
        esac

        class_lower=$(echo "$wm_class" | tr '[:upper:]' '[:lower:]')
        case "$class_lower" in
          *alacritty*|*kitty*|*terminal*)  icon="" ;;
          *firefox*)                        icon="󰈹" ;;
          *chrome*|*chromium*)              icon="" ;;
          *code*|*codium*)                  icon="󰨞" ;;
          *thunar*|*nemo*|*pcmanfm*|*nautilus*) icon="󰉋" ;;
          *discord*|*vesktop*)              icon="󰙯" ;;
          *spotify*)                        icon="󰓇" ;;
          *mpv*|*vlc*)                      icon="󰎁" ;;
          *scrcpy*)                         icon="󰄡" ;;
          *pavucontrol*)                    icon="󰕾" ;;
          *lxappearance*)                   icon="󰔎" ;;
          *gimp*)                           icon="" ;;
          *steam*)                          icon="󰓓" ;;
          *)                                icon="󰣆" ;;
        esac

        display_name=$(echo "$wm_class" | cut -c1-12)

        is_focused=false
        [ "$wid" = "$focused_node" ] && is_focused=true

        is_hidden=false
        if echo "$hidden_nodes" | grep -qw "$wid" 2>/dev/null; then
          is_hidden=true
        fi

        if [ "$is_focused" = true ]; then
          act_left="${pkgs.bspwm}/bin/bspc node $wid -g hidden=on"
        elif [ "$is_hidden" = true ]; then
          act_left="${pkgs.bspwm}/bin/bspc node $wid -g hidden=off -f"
        else
          act_left="${pkgs.bspwm}/bin/bspc node $wid -f"
        fi
        act_mid="${pkgs.bspwm}/bin/bspc node $wid -c"
        act_right="${pkgs.bspwm}/bin/bspc node $wid -t ~floating"

        if [ "$is_hidden" = true ]; then
          item="%{A1:$act_left:}%{A2:$act_mid:}%{A3:$act_right:}%{F${colors.peach}}󰖯 %{F${colors.surface2}}$icon $display_name%{F-}%{A}%{A}%{A}"
        elif [ "$is_focused" = true ]; then
          item="%{A1:$act_left:}%{A2:$act_mid:}%{A3:$act_right:}%{F${colors.blue}}$icon %{F${colors.text}}$display_name%{F-}%{A}%{A}%{A}"
        else
          item="%{A1:$act_left:}%{A2:$act_mid:}%{A3:$act_right:}%{F${colors.subtext0}}$icon $display_name%{F-}%{A}%{A}%{A}"
        fi

        if [ "$first" = true ]; then
          output="$item"
          first=false
        else
          output="$output %{F${colors.surface1}}·%{F-} $item"
        fi
        count=$((count + 1))
      done

      echo "$output"
    }

    generate_output

    bspc subscribe node_focus node_add node_remove node_flag node_state desktop_focus 2>/dev/null | while read -r _; do
      generate_output
    done
  '';
  # --- Script de Controle de Mídia (Playerctl) ---
  mediaScript = pkgs.writeShellScript "polybar-media" ''
    export PATH="${pkgs.playerctl}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"
    if ! command -v playerctl >/dev/null 2>&1; then
      exit 0
    fi
    status=$(playerctl status 2>/dev/null)
    if [ "$status" = "Playing" ]; then
      artist=$(playerctl metadata artist 2>/dev/null)
      title=$(playerctl metadata title 2>/dev/null)
      track="$artist - $title"
      [ -z "$artist" ] && track="$title"
      track=$(echo "$track" | cut -c1-35)
      echo "%{F${colors.mauve}}󰎈%{F-} %{F${colors.lavender}}$track%{F-}"
    elif [ "$status" = "Paused" ]; then
      artist=$(playerctl metadata artist 2>/dev/null)
      title=$(playerctl metadata title 2>/dev/null)
      track="$artist - $title"
      [ -z "$artist" ] && track="$title"
      track=$(echo "$track" | cut -c1-30)
      echo "%{F${colors.surface2}}󰏤 $track%{F-}"
    else
      echo ""
    fi
  '';

  # --- Script de Status do Bluetooth com Detecção de Bateria e Conexão ---
  bluetoothScript = pkgs.writeShellScript "polybar-bluetooth" ''
    export PATH="${pkgs.bluez}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"
    if ! command -v bluetoothctl >/dev/null 2>&1; then
      echo "%{F${colors.surface2}}󰂲%{F-}"
      exit 0
    fi

    power=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
    if [ "$power" = "yes" ]; then
      connected_dev=$(bluetoothctl info 2>/dev/null | grep "Name:" | cut -d: -f2 | sed 's/^ *//' | cut -c1-12)
      if [ -n "$connected_dev" ]; then
        batt=$(bluetoothctl info 2>/dev/null | grep -i "Battery Percentage" | awk -F'[(%]' '{print $2}' | tr -d ' ')
        [ -z "$batt" ] && batt=$(bluetoothctl info 2>/dev/null | grep -i "Battery Percentage" | awk '{print $NF}' | tr -d '%')
        if [ -n "$batt" ]; then
          echo "%{F${colors.blue}}󰂱%{F-} $connected_dev %{F${colors.green}}󰁹%{F-}$batt%"
        else
          echo "%{F${colors.blue}}󰂱%{F-} $connected_dev"
        fi
      else
        echo "%{F${colors.sapphire}}󰂯%{F-}"
      fi
    else
      echo "%{F${colors.surface2}}󰂲%{F-}"
    fi
  '';

  # --- Menu Interativo de Bluetooth Avançado (Rofi - Inspirado no gh0stzk/dotfiles e nickclyde) ---
  rofiBluetoothMenu = pkgs.writeShellScript "rofi-bluetooth" ''
    export PATH="${pkgs.bluez}/bin:${pkgs.blueman}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.util-linux}/bin:${pkgs.procps}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    notify_bt() {
      local urgency="$1"
      local icon="$2"
      local title="$3"
      local msg="$4"
      ${pkgs.dunst}/bin/dunstify -a "Bluetooth" -u "$urgency" -i "$icon" -h string:x-dunst-stack-tag:bluetooth-osd -t 2500 "$title" "$msg"
    }

    power_on() {
      bluetoothctl show 2>/dev/null | grep -q "Powered: yes"
    }

    toggle_power() {
      if power_on; then
        bluetoothctl power off >/dev/null 2>&1
        notify_bt "low" "bluetooth-disabled" "Bluetooth Desativado" "Controlador desligado."
      else
        if command -v rfkill >/dev/null 2>&1 && rfkill list bluetooth 2>/dev/null | grep -q 'blocked: yes'; then
          rfkill unblock bluetooth 2>/dev/null && sleep 0.5
        fi
        bluetoothctl power on >/dev/null 2>&1
        notify_bt "normal" "bluetooth-active" "Bluetooth Ativado" "Controlador pronto para conexões."
      fi
      show_menu
    }

    scan_on() {
      bluetoothctl show 2>/dev/null | grep -q "Discovering: yes"
    }

    toggle_scan() {
      if scan_on; then
        pkill -f "bluetoothctl.*scan on" >/dev/null 2>&1 || true
        bluetoothctl scan off >/dev/null 2>&1 || true
        notify_bt "low" "bluetooth-active" "Escaneamento Parado" "Busca por dispositivos interrompida."
        show_menu
      else
        notify_bt "normal" "bluetooth-active" "Buscando Dispositivos..." "Varredura ativa em segundo plano (25s)."
        bluetoothctl --timeout 25 scan on >/dev/null 2>&1 &
        sleep 0.8
        show_menu
      fi
    }

    pairable_on() {
      bluetoothctl show 2>/dev/null | grep -q "Pairable: yes"
    }

    toggle_pairable() {
      if pairable_on; then
        bluetoothctl pairable off >/dev/null 2>&1
        notify_bt "low" "bluetooth-active" "Modo Pareável" "Desativado."
      else
        bluetoothctl pairable on >/dev/null 2>&1
        notify_bt "normal" "bluetooth-active" "Modo Pareável" "Ativado. Outros dispositivos podem parear."
      fi
      show_menu
    }

    discoverable_on() {
      bluetoothctl show 2>/dev/null | grep -q "Discoverable: yes"
    }

    toggle_discoverable() {
      if discoverable_on; then
        bluetoothctl discoverable off >/dev/null 2>&1
        notify_bt "low" "bluetooth-active" "Visibilidade" "Oculto para novos aparelhos."
      else
        bluetoothctl discoverable on >/dev/null 2>&1
        notify_bt "normal" "bluetooth-active" "Visibilidade" "Visível para outros aparelhos."
      fi
      show_menu
    }

    # Submenu de opções para o dispositivo selecionado
    device_menu() {
      local mac="$1"
      local name="$2"
      local info
      info=$(bluetoothctl info "$mac" 2>/dev/null)

      local is_connected="Não"
      local is_paired="Não"
      local is_trusted="Não"
      local is_blocked="Não"
      local battery=""

      echo "$info" | grep -q "Connected: yes" && is_connected="Sim"
      echo "$info" | grep -q "Paired: yes" && is_paired="Sim"
      echo "$info" | grep -q "Trusted: yes" && is_trusted="Sim"
      echo "$info" | grep -q "Blocked: yes" && is_blocked="Sim"

      local batt_val
      batt_val=$(echo "$info" | grep -i "Battery Percentage" | awk -F'[(%]' '{print $2}' | tr -d ' ')
      [ -z "$batt_val" ] && batt_val=$(echo "$info" | grep -i "Battery Percentage" | awk '{print $NF}' | tr -d '%')
      [ -n "$batt_val" ] && battery=" | 󰁹 Bateria: $batt_val%"

      local OPT_CONN
      if [ "$is_connected" = "Sim" ]; then
        OPT_CONN="󰂲  Desconectar"
      else
        OPT_CONN="󰂱  Conectar"
      fi

      local OPT_PAIR
      if [ "$is_paired" = "Sim" ]; then
        OPT_PAIR="󰌆  Desparear"
      else
        OPT_PAIR="󰌆  Parear"
      fi

      local OPT_TRUST
      if [ "$is_trusted" = "Sim" ]; then
        OPT_TRUST="󰤩  Remover Confiança (Untrust)"
      else
        OPT_TRUST="󰤨  Confiar no Dispositivo (Trust)"
      fi

      local OPT_BLOCK
      if [ "$is_blocked" = "Sim" ]; then
        OPT_BLOCK="󰂯  Desbloquear Dispositivo"
      else
        OPT_BLOCK="󰂲  Bloquear Dispositivo"
      fi

      local OPT_REMOVE="󰆴  Remover / Esquecer Dispositivo"
      local OPT_BACK="󰌍  Voltar ao Menu Principal"

      local PROMPT_TEXT=" $name [$mac] (Conectado: $is_connected$battery) "

      local CHOICE
      CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s" \
        "$OPT_CONN" \
        "$OPT_PAIR" \
        "$OPT_TRUST" \
        "$OPT_BLOCK" \
        "$OPT_REMOVE" \
        "$OPT_BACK" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "$PROMPT_TEXT" \
        -theme-str 'window {width: 540px; border-radius: 12px;} listview {lines: 6;}' -no-custom)

      case "$CHOICE" in
        *"Conectar")
          notify_bt "normal" "bluetooth-active" "Conectando..." "Tentando conectar a $name..."
          bluetoothctl trust "$mac" >/dev/null 2>&1 || true
          if bluetoothctl connect "$mac" >/dev/null 2>&1; then
            notify_bt "normal" "bluetooth-active" "Conectado!" "$name conectado com sucesso."
          else
            notify_bt "critical" "bluetooth-disabled" "Erro de Conexão" "Falha ao conectar a $name. Se necessário, abra o Blueman."
          fi
          device_menu "$mac" "$name"
          ;;
        *"Desconectar")
          notify_bt "low" "bluetooth-active" "Desconectando..." "Desconectando $name..."
          bluetoothctl disconnect "$mac" >/dev/null 2>&1
          notify_bt "normal" "bluetooth-active" "Desconectado" "$name foi desconectado."
          device_menu "$mac" "$name"
          ;;
        *"Parear")
          notify_bt "normal" "bluetooth-active" "Pareando..." "Pareando com $name..."
          if bluetoothctl pair "$mac" >/dev/null 2>&1; then
            bluetoothctl trust "$mac" >/dev/null 2>&1 || true
            notify_bt "normal" "bluetooth-active" "Pareado!" "$name pareado com sucesso."
          else
            notify_bt "critical" "bluetooth-disabled" "Falha no Pareamento" "Não foi possível parear com $name."
          fi
          device_menu "$mac" "$name"
          ;;
        *"Desparear")
          bluetoothctl untrust "$mac" >/dev/null 2>&1 || true
          bluetoothctl remove "$mac" >/dev/null 2>&1 || true
          notify_bt "low" "bluetooth-disabled" "Despareado" "$name despareado e removido."
          show_menu
          ;;
        *"Confiar"*)
          bluetoothctl trust "$mac" >/dev/null 2>&1
          notify_bt "normal" "bluetooth-active" "Confiável" "$name marcado como confiável."
          device_menu "$mac" "$name"
          ;;
        *"Remover Confiança"*)
          bluetoothctl untrust "$mac" >/dev/null 2>&1
          notify_bt "low" "bluetooth-active" "Não Confiável" "Confiança removida de $name."
          device_menu "$mac" "$name"
          ;;
        *"Bloquear"*)
          bluetoothctl block "$mac" >/dev/null 2>&1
          notify_bt "low" "bluetooth-disabled" "Bloqueado" "$name foi bloqueado."
          device_menu "$mac" "$name"
          ;;
        *"Desbloquear"*)
          bluetoothctl unblock "$mac" >/dev/null 2>&1
          notify_bt "normal" "bluetooth-active" "Desbloqueado" "$name foi desbloqueado."
          device_menu "$mac" "$name"
          ;;
        *"Remover"*)
          bluetoothctl remove "$mac" >/dev/null 2>&1
          notify_bt "normal" "bluetooth-disabled" "Dispositivo Removido" "$name foi removido."
          show_menu
          ;;
        *"Voltar"*)
          show_menu
          ;;
      esac
    }

    # Menu Principal
    show_menu() {
      if ! power_on; then
        local OFF_OPT="󰂯  Ligar Bluetooth"
        local BM_OPT="󰂯  Abrir Blueman (Gerenciador Avançado)"
        local CH
        CH=$(printf "%s\n%s" "$OFF_OPT" "$BM_OPT" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰂲 Bluetooth Desligado " \
          -theme-str 'window {width: 420px; border-radius: 12px;} listview {lines: 2;}' -no-custom)
        case "$CH" in
          *"Ligar Bluetooth"*)
            toggle_power
            ;;
          *"Blueman"*)
            if command -v blueman-manager >/dev/null 2>&1; then
              blueman-manager &
            else
              ${pkgs.blueman}/bin/blueman-manager &
            fi
            ;;
        esac
        exit 0
      fi

      local SCAN_TEXT="󰑐  Escanear Dispositivos (Scan: OFF)"
      scan_on && SCAN_TEXT="󰑐  Parar Escaneamento (Scan: ATIVO)"

      local PAIR_TEXT="󰌆  Modo Pareável (Pairable: OFF)"
      pairable_on && PAIR_TEXT="󰌆  Modo Pareável (Pairable: ON)"

      local DISC_TEXT="󰈈  Visibilidade (Discoverable: OFF)"
      discoverable_on && DISC_TEXT="󰈈  Visibilidade (Discoverable: ON)"

      local HEADER_ITEMS="󰂲  Desligar Bluetooth\n$SCAN_TEXT\n$PAIR_TEXT\n$DISC_TEXT\n󰂯  Abrir Blueman (Gerenciador Avançado)"

      local DEV_LIST=""
      while IFS= read -r line; do
        if [ -n "$line" ]; then
          local mac
          mac=$(echo "$line" | awk '{print $2}')
          local name
          name=$(echo "$line" | cut -d' ' -f3-)
          [ -z "$name" ] && name="Dispositivo Desconhecido"

          local dinfo
          dinfo=$(bluetoothctl info "$mac" 2>/dev/null)

          local icon="󰂯"
          local icon_class
          icon_class=$(echo "$dinfo" | grep -i "Icon:" | awk '{print $2}')

          case "$icon_class" in
            *audio-card*|*audio-speakers*) icon="󰓃" ;;
            *audio-headset*) icon="󰋋" ;;
            *audio-headphones*) icon="󰥰" ;;
            *input-keyboard*) icon="󰌌" ;;
            *input-mouse*|*input-gaming*) icon="󰍽" ;;
            *phone*) icon="󰏲" ;;
            *computer*) icon="󰌢" ;;
          esac

          local status_tag=""
          if echo "$dinfo" | grep -q "Connected: yes"; then
            local batt
            batt=$(echo "$dinfo" | grep -i "Battery Percentage" | awk -F'[(%]' '{print $2}' | tr -d ' ')
            [ -z "$batt" ] && batt=$(echo "$dinfo" | grep -i "Battery Percentage" | awk '{print $NF}' | tr -d '%')
            if [ -n "$batt" ]; then
              status_tag="  (󰂱 Conectado 󰁹 $batt%)"
            else
              status_tag="  (󰂱 Conectado)"
            fi
            icon="󰂱"
          elif echo "$dinfo" | grep -q "Paired: yes"; then
            status_tag="  (Pareado)"
          else
            status_tag="  (Disponível)"
            icon="󰑐"
          fi

          DEV_LIST+="$icon  $name  [$mac]$status_tag\n"
        fi
      done < <(bluetoothctl devices 2>/dev/null)

      local MENU_CONTENT="$HEADER_ITEMS"
      if [ -n "$DEV_LIST" ]; then
        MENU_CONTENT+="\n------------------------------------\n$DEV_LIST"
      else
        MENU_CONTENT+="\n------------------------------------\n󰂲  Nenhum dispositivo encontrado (ative o Escaneamento)"
      fi

      local SELECTED
      SELECTED=$(printf "%b" "$MENU_CONTENT" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰂯 Bluetooth " \
        -theme-str 'window {width: 560px; border-radius: 12px;} listview {lines: 12;}' -no-custom)

      [ -z "$SELECTED" ] && exit 0

      case "$SELECTED" in
        *"Desligar Bluetooth"*)
          toggle_power
          ;;
        *"Escanear Dispositivos"*|*"Parar Escaneamento"*)
          toggle_scan
          ;;
        *"Modo Pareável"*)
          toggle_pairable
          ;;
        *"Visibilidade"*)
          toggle_discoverable
          ;;
        *"Abrir Blueman"*)
          if command -v blueman-manager >/dev/null 2>&1; then
            blueman-manager &
          else
            ${pkgs.blueman}/bin/blueman-manager &
          fi
          ;;
        *"----------------"*)
          show_menu
          ;;
        *"Nenhum dispositivo encontrado"*)
          toggle_scan
          ;;
        *)
          if [[ "$SELECTED" =~ \[([0-9A-Fa-f:]{17})\] ]]; then
            local dev_mac="''${BASH_REMATCH[1]}"
            local dev_name
            dev_name=$(echo "$SELECTED" | sed -E 's/^[󰂱󰂯󰑐󰓃󰋋󰥰󰌌󰍽󰏲󰌢 ]+//;s/  \[.*//')
            device_menu "$dev_mac" "$dev_name"
          fi
          ;;
      esac
    }

    show_menu
  '';

  # --- Script de Status de Rede (Cabo / Wi-Fi Dinâmico) ---
  networkScript = pkgs.writeShellScript "polybar-network" ''
    export PATH="${pkgs.networkmanager}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.coreutils}/bin:$PATH"

    # 1. Verifica se há conexão cabeada (Ethernet) ativa
    eth_conn=$(nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | grep "^ethernet:connected:" | head -n1)
    if [ -n "$eth_conn" ]; then
      con_name=$(echo "$eth_conn" | cut -d: -f3 | cut -c1-14)
      [ -z "$con_name" ] && con_name="Ethernet"
      echo "%{F${colors.teal}}󰈀%{F-} $con_name"
      # echo "%{F${colors.teal}}󰈀%{F-} $con_name" # sem corte de caracteres
      exit 0
    fi

    # 2. Verifica se há conexão sem fio (Wi-Fi) ativa
    wifi_conn=$(nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | grep "^wifi:connected:" | head -n1)
    if [ -n "$wifi_conn" ]; then
      wifi_info=$(nmcli -t -f IN-USE,SSID,SIGNAL device wifi 2>/dev/null | grep '^\*' | head -n1)
      ssid=$(echo "$wifi_info" | cut -d: -f2 | cut -c1-14)
      signal=$(echo "$wifi_info" | cut -d: -f3)
      if [ -z "$ssid" ]; then
        ssid=$(echo "$wifi_conn" | cut -d: -f3 | cut -c1-14)
      fi
      [ -z "$ssid" ] && ssid="Wi-Fi"

      if [ -n "$signal" ] && [ "$signal" -ge 80 ]; then
        icon="󰤨"
      elif [ -n "$signal" ] && [ "$signal" -ge 60 ]; then
        icon="󰤥"
      elif [ -n "$signal" ] && [ "$signal" -ge 40 ]; then
        icon="󰤢"
      elif [ -n "$signal" ] && [ "$signal" -ge 20 ]; then
        icon="󰤟"
      else
        icon="󰤯"
      fi

      echo "%{F${colors.teal}}$icon%{F-} $ssid"
      exit 0
    fi

    # 3. Verifica se o rádio Wi-Fi está desativado
    wifi_radio=$(nmcli radio wifi 2>/dev/null)
    if [ "$wifi_radio" = "disabled" ]; then
      echo "%{F${colors.surface2}}󰤮%{F-} %{F${colors.surface2}}Desativado%{F-}"
      exit 0
    fi

    # 4. Desconectado / Offline
    echo "%{F${colors.red}}󰤮%{F-} %{F${colors.subtext0}}Offline%{F-}"
  '';

  # --- Menu Interativo de Wi-Fi (Rofi) ---
  rofiWifiMenu = pkgs.writeShellScript "rofi-wifi-menu" ''
    export PATH="${pkgs.networkmanager}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.gnugrep}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 -t 1500 "Escaneando redes Wi-Fi..."

    wifi_list=$(nmcli --fields "SECURITY,SSID,BARS" device wifi list --rescan yes 2>/dev/null | sed 1d | sed -E "s/  +/ /g" | sed -E "s/^ *//" | grep -v "^--" | awk -F' ' '{
      sec=$1;
      bars=$NF;
      $1="";
      $NF="";
      ssid=$0;
      gsub(/^ +| +$/, "", ssid);
      if (ssid != "") {
        icon = (sec ~ /WPA|WEP/) ? "󰌾" : "󰤨";
        printf "%s  %-25s [%s]\n", icon, ssid, bars;
      }
    }' | sort -u)

    if [ -z "$wifi_list" ]; then
      dunstify -a "Wi-Fi" -u normal -i "network-wireless-offline" -r 9994 "Nenhuma rede Wi-Fi encontrada"
      exit 0
    fi

    chosen_line=$(echo -e "$wifi_list\n󰑐  Escanear novamente\n󰤮  Desconectar Wi-Fi" | rofi \
      -dmenu \
      -i \
      -p "Redes Wi-Fi" \
      -theme-str 'window {width: 380px; border-radius: 12px;} listview {lines: 10;}' \
      -no-custom)

    if [ -z "$chosen_line" ]; then
      exit 0
    fi

    if [[ "$chosen_line" =~ "Desconectar" ]]; then
      nmcli device disconnect wlan0 2>/dev/null || nmcli device disconnect wlp3s0 2>/dev/null || nmcli radio wifi off
      dunstify -a "Wi-Fi" -u low -i "network-wireless-offline" -r 9994 "Wi-Fi desconectado"
      exit 0
    fi

    if [[ "$chosen_line" =~ "Escanear" ]]; then
      exec "$0"
    fi

    chosen_ssid=$(echo "$chosen_line" | awk -F'  ' '{print $2}' | sed 's/ \[.*//' | sed 's/^ *//;s/ *$//')

    if [ -n "$chosen_ssid" ]; then
      saved_conn=$(nmcli -g NAME connection show | grep -Fx "$chosen_ssid" || true)
      if [ -n "$saved_conn" ]; then
        dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 "Conectando a \"$chosen_ssid\"..."
        if nmcli connection up "$chosen_ssid"; then
          dunstify -a "Wi-Fi" -u normal -i "network-wireless" -r 9994 "Conectado a \"$chosen_ssid\"!"
        else
          dunstify -a "Wi-Fi" -u critical -i "network-wireless-offline" -r 9994 "Falha ao conectar a \"$chosen_ssid\""
        fi
      else
        if [[ "$chosen_line" =~ "󰌾" ]]; then
          wifi_pass=$(rofi -dmenu -password -p "Senha para $chosen_ssid" -theme-str 'window {width: 320px; border-radius: 12px;}')
          if [ -n "$wifi_pass" ]; then
            dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 "Conectando a \"$chosen_ssid\"..."
            if nmcli device wifi connect "$chosen_ssid" password "$wifi_pass"; then
              dunstify -a "Wi-Fi" -u normal -i "network-wireless" -r 9994 "Conectado a \"$chosen_ssid\"!"
            else
              dunstify -a "Wi-Fi" -u critical -i "network-wireless-offline" -r 9994 "Senha incorreta ou erro de conexão"
            fi
          fi
        else
          dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 "Conectando a \"$chosen_ssid\"..."
          nmcli device wifi connect "$chosen_ssid"
        fi
      fi
    fi
  '';

  # --- Menu de Desligamento com Rofi ---
  rofiPowerMenu = pkgs.writeShellScript "rofi-powermenu" ''
    export PATH="${pkgs.rofi}/bin:${pkgs.systemd}/bin:${pkgs.bspwm}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    chosen=$(printf "󰐥  Desligar\n󰜉  Reiniciar\n󰤄  Suspender\n󰒲  Hibernar\n󰈆  Sair (logout)\n󰌾  Bloquear" \
      | rofi \
          -dmenu \
          -i \
          -p "Power Menu" \
          -theme-str 'window {width: 280px; border-radius: 12px;} listview {lines: 6;}' \
          -no-custom)

    case "$chosen" in
      *"Desligar"*)    systemctl poweroff || loginctl poweroff ;;
      *"Reiniciar"*)   systemctl reboot || loginctl reboot ;;
      *"Suspender"*)   systemctl suspend || loginctl suspend ;;
      *"Hibernar"*)    systemctl hibernate || loginctl hibernate ;;
      *"Sair"*)       bspc quit ;;
      *"Bloquear"*)    loginctl lock-session ;;
    esac
  '';

  # --- Script de Monitoramento de Janelas Minimizadas na Polybar ---
  minimizedScript = pkgs.writeShellScript "polybar-minimized" ''
    export PATH="${pkgs.bspwm}/bin:${pkgs.uutils-coreutils-noprefix}/bin:${pkgs.gnugrep}/bin:$PATH"
    hidden_nodes=$(bspc query -N -d focused -n .window.hidden 2>/dev/null)
    count=$(echo "$hidden_nodes" | grep -v '^$' | wc -l)

    if [ "$count" -gt 0 ]; then
      echo "%{F${colors.peach}}󰖯 $count%{F-}"
    else
      echo ""
    fi
  '';

  # --- Menu Rofi para Restaurar Janelas Minimizadas ---
  restoreMenuScript = pkgs.writeShellScript "rofi-restore-minimized" ''
    export PATH="${pkgs.bspwm}/bin:${pkgs.xdotool}/bin:${pkgs.rofi}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"
    hidden_nodes=$(bspc query -N -d focused -n .window.hidden 2>/dev/null)
    if [ -z "$hidden_nodes" ]; then
      exit 0
    fi

    entries=""
    for node in $hidden_nodes; do
      title=$(xdotool getwindowname "$node" 2>/dev/null || echo "Janela $node")
      entries="$entries$node: 󰖯 $title\n"
    done

    chosen=$(printf "$entries" | rofi -dmenu -i -p " 󰖯 Restaurar Janela " -theme-str 'window { width: 480px; border-radius: 14px; }')
    if [ -n "$chosen" ]; then
      selected_node=$(echo "$chosen" | cut -d: -f1)
      bspc node "$selected_node" -g hidden=off -f
    fi
  '';

  # --- Script Dinâmico de Temperatura da CPU (Universal) ---
  temperatureScript = pkgs.writeShellScript "polybar-temperature" ''
    export PATH="${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    temp_file=""
    # 1. Tentar encontrar sensor de CPU em hwmon (coretemp, k10temp, zenpower, applesmc)
    for f in /sys/class/hwmon/hwmon*/name; do
      if [ -f "$f" ]; then
        name=$(cat "$f" 2>/dev/null)
        case "$name" in
          coretemp*|k10temp*|zenpower*|applesmc*|cpu*|it87*|nct6775*)
            dir=$(dirname "$f")
            for t in "$dir"/temp1_input "$dir"/temp2_input "$dir"/temp*_input; do
              if [ -r "$t" ]; then
                temp_file="$t"
                break 2
              fi
            done
            ;;
        esac
      fi
    done

    # 2. Fallback: procurar qualquer hwmon ou thermal_zone com leitura válida
    if [ -z "$temp_file" ]; then
      for t in /sys/class/hwmon/hwmon*/temp1_input /sys/class/thermal/thermal_zone*/temp; do
        if [ -r "$t" ]; then
          val=$(cat "$t" 2>/dev/null)
          if [ -n "$val" ] && [ "$val" -gt 0 ] 2>/dev/null; then
            temp_file="$t"
            break
          fi
        fi
      done
    fi

    if [ -n "$temp_file" ]; then
      raw=$(cat "$temp_file" 2>/dev/null)
      if [ -n "$raw" ] && [ "$raw" -gt 0 ] 2>/dev/null; then
        if [ "$raw" -ge 1000 ]; then
          deg=$((raw / 1000))
        else
          deg=$raw
        fi

        if [ "$deg" -ge 80 ]; then
          icon=""
          color="${colors.red}"
        elif [ "$deg" -ge 65 ]; then
          icon=""
          color="${colors.peach}"
        else
          icon=""
          color="${colors.teal}"
        fi

        echo "%{F$color}$icon%{F-} ''${deg}°C"
        exit 0
      fi
    fi

    echo "%{F${colors.subtext0}} --°C%{F-}"
  '';

  # --- Menu Interativo de Layout do Teclado (Rofi - Genérico) ---
  rofiKeyboardMenu = pkgs.writeShellScript "rofi-keyboard" ''
    export PATH="${pkgs.xkb-switch}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.gnused}/bin:${pkgs.coreutils}/bin:$PATH"

    current=$(xkb-switch -p 2>/dev/null || true)
    layouts=$(xkb-switch -l 2>/dev/null || true)

    if [ -z "$layouts" ]; then
      dunstify -a "Teclado" -u low -i "input-keyboard" -r 9992 "Nenhum layout adicional configurado"
      exit 0
    fi

    menu=""
    while IFS= read -r l; do
      [ -z "$l" ] && continue
      if [ "$l" = "$current" ]; then
        menu+="󰄬  $l\n"
      else
        menu+="    $l\n"
      fi
    done <<< "$layouts"

    chosen=$(echo -e "$menu" | rofi \
      -dmenu \
      -i \
      -p "Layout" \
      -theme-str 'window {width: 320px; border-radius: 12px;} listview {lines: 4;}' \
      -no-custom)

    if [ -n "$chosen" ]; then
      selected_layout=$(echo "$chosen" | sed 's/^[ 󰄬]*//')
      if [ -n "$selected_layout" ]; then
        xkb-switch -s "$selected_layout"
        dunstify -a "Teclado" -u low -i "input-keyboard" -r 9992 -t 1500 "Layout: $selected_layout"
      fi
    fi
  '';

  # --- Script de Controle do Redshift (Temperatura de Cor / Filtro Noturno) ---
  redshiftScript = pkgs.writeShellScript "polybar-redshift" ''
    export PATH="${lib.makeBinPath [ pkgs.redshift pkgs.dunst pkgs.coreutils pkgs.gnugrep pkgs.procps ]}:$PATH"

    STATE_FILE="/tmp/polybar_redshift_state"
    TEMP_FILE="/tmp/polybar_redshift_temp"

    DEFAULT_TEMP=4500
    DAY_TEMP=6500

    get_temp() {
      if [ -f "$TEMP_FILE" ]; then
        cat "$TEMP_FILE" 2>/dev/null || echo "$DEFAULT_TEMP"
      else
        echo "$DEFAULT_TEMP"
      fi
    }

    set_temp() {
      temp="$1"
      echo "$temp" > "$TEMP_FILE"
      echo "on" > "$STATE_FILE"
      redshift -P -O "$temp" 2>/dev/null
      dunstify -a "Redshift" -u low -i "weather-clear-night" -r 9991 -t 1500 "Filtro Noturno: ''${temp}K"
    }

    toggle() {
      state=$(cat "$STATE_FILE" 2>/dev/null || echo "off")
      if [ "$state" = "on" ]; then
        echo "off" > "$STATE_FILE"
        redshift -x 2>/dev/null
        dunstify -a "Redshift" -u low -i "weather-clear" -r 9991 -t 1500 "Filtro Noturno: Desativado (6500K)"
      else
        temp=$(get_temp)
        set_temp "$temp"
      fi
    }

    increase() {
      temp=$(get_temp)
      temp=$((temp + 500))
      [ "$temp" -gt 6500 ] && temp=6500
      set_temp "$temp"
    }

    decrease() {
      temp=$(get_temp)
      temp=$((temp - 500))
      [ "$temp" -lt 2500 ] && temp=2500
      set_temp "$temp"
    }

    case "$1" in
      toggle)
        toggle
        ;;
      increase)
        increase
        ;;
      decrease)
        decrease
        ;;
      reset)
        echo "off" > "$STATE_FILE"
        echo "$DEFAULT_TEMP" > "$TEMP_FILE"
        redshift -x 2>/dev/null
        dunstify -a "Redshift" -u low -i "weather-clear" -r 9991 -t 1500 "Filtro Noturno: Resetado (6500K)"
        ;;
      status|*)
        state=$(cat "$STATE_FILE" 2>/dev/null || echo "off")
        if [ "$state" = "on" ]; then
          temp=$(get_temp)
          echo "%{F${colors.peach}}󰛩%{F-} ''${temp}K"
        else
          echo "%{F${colors.surface2}}󰛨%{F-} Off"
        fi
        ;;
    esac
  '';
}
