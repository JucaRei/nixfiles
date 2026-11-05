#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

get_device_icon() {
      local icon_class="${1:-}"
      local class_hex="${2:-}"
      local uuids="${3:-}"
      local dev_name="${4:-}"
      local dev_name_lower
      dev_name_lower=$(echo "$dev_name" | tr '[:upper:]' '[:lower:]')

      # 1. Pelo atributo Icon do BlueZ
      case "$icon_class" in
        *audio-headphones*) echo "󰥰"; return ;;
        *audio-headset*)    echo "󰋋"; return ;;
        *audio-card*|*audio-speakers*) echo "󰓃"; return ;;
        *input-keyboard*)   echo "󰌌"; return ;;
        *input-mouse*)      echo "󰍽"; return ;;
        *input-gaming*)     echo "󰊴"; return ;;
        *phone*)            echo "󰏲"; return ;;
        *computer*)         echo "󰌢"; return ;;
        *wearable*|*watch*) echo "󰟾"; return ;;
      esac

      # 2. Pelo Device Class Hexadecimal (CoD)
      case "$class_hex" in
        *0x*540*|*0x*2540*) echo "󰌌"; return ;; # Teclado
        *0x*580*|*0x*2580*) echo "󰍽"; return ;; # Mouse
        *0x*504*|*0x*508*)  echo "󰊴"; return ;; # Gamepad / Controle
        *0x*404*|*0x*408*)  echo "󰋋"; return ;; # Headset / Handsfree
        *0x*418*)           echo "󰥰"; return ;; # Headphones / Fone
        *0x*414*|*0x*420*)  echo "󰓃"; return ;; # Caixa de som / Áudio veicular
      esac

      # 3. Pelo Nome do dispositivo (marcas e modelos populares)
      case "$dev_name_lower" in
        *mouse*|*trackball*|*"mx master"*|*mx-master*|*m590*|*m720*|*deathadder*|*g305*|*g502*|*g703*|*viper*)
          echo "󰍽"; return ;;
        *keyboard*|*teclado*|*"mx keys"*|*mx-keys*|*keychron*|*k380*|*k480*|*nuphy*|*anne*|*ducky*)
          echo "󰌌"; return ;;
        *headset*|*evolve*|*void*|*arctis*|*cloud*|*kraken*|*hs70*|*hs80*)
          echo "󰋋"; return ;;
        *headphone*|*fone*|*buds*|*airpod*|*freebud*|*soundcore*|*wh-*|*wf-*|*tune*|*live*|*earphone*|*earbuds*)
          echo "󰥰"; return ;;
        *speaker*|*caixa*|*soundbar*|*jbl*|*echo*|*boombox*|*flip*|*charge*|*xtreme*|*wonderboom*)
          echo "󰓃"; return ;;
        *gamepad*|*controller*|*xbox*|*dualshock*|*dualsense*|*joy-con*|*8bitdo*|*pro\ controller*)
          echo "󰊴"; return ;;
        *watch*|*miband*|*band*|*fitbit*|*garmin*)
          echo "󰟾"; return ;;
        *iphone*|*android*|*galaxy*|*pixel*|*celular*|*smartphone*|*xiaomi*|*redmi*)
          echo "󰏲"; return ;;
        *macbook*|*laptop*|*notebook*|*thinkpad*)
          echo "󰌢"; return ;;
      esac

      # 4. Pelas UUIDs anunciadas
      if echo "$uuids" | grep -qi "Headset\|Handsfree"; then
        echo "󰋋"; return
      elif echo "$uuids" | grep -qi "Audio Sink"; then
        echo "󰥰"; return
      elif echo "$uuids" | grep -qi "Human Interface Device"; then
        echo "󰍽"; return
      fi

      echo "󰂱"
    }

    notify_bt() {
      local urgency="$1"
      local icon="$2"
      local title="$3"
      local msg="$4"
      dunstify -a "Bluetooth" -u "$urgency" -i "$icon" -h string:x-dunst-stack-tag:bluetooth-osd -t 3000 "$title" "$msg"
    }

    bt_cmd() {
      printf "%s\nquit\n" "$*" | bluetoothctl 2>/dev/null | tr -d '\r' | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g'
    }

    power_on() {
      bt_cmd "show" | grep -i "Powered:" | grep -q "yes"
    }

    toggle_power() {
      local from_cli="${1:-}"
      if power_on; then
        # 1. Parar qualquer escaneamento em andamento
        pkill -f "bluetoothctl.*scan" >/dev/null 2>&1 || true
        bt_cmd "scan off" >/dev/null 2>&1 || true

        # 2. Desligar o controlador via pipe e direto
        local ctrl
        ctrl=$(bt_cmd "list" | head -n1 | awk '{print $2}')
        if [ -n "$ctrl" ]; then
          printf "select %s\npower off\nquit\n" "$ctrl" | bluetoothctl >/dev/null 2>&1 || true
        fi
        bt_cmd "power off" >/dev/null 2>&1 || true

        # 3. Aguardar confirmação do desligamento
        local i=0
        while power_on && [ "$i" -lt 15 ]; do
          sleep 0.1
          i=$((i + 1))
        done

        notify_bt "low" "bluetooth-disabled" "Bluetooth Desativado" "Controlador desligado."
        # Ao desligar, encerra a execução sem reabrir janela de diálogo
        exit 0
      else
        # 1. Desbloquear rfkill se necessário
        rfkill unblock bluetooth 2>/dev/null || /usr/sbin/rfkill unblock bluetooth 2>/dev/null || true

        # 2. Aguardar o controlador ser detectado pelo BlueZ (até 3s)
        local k=0
        local ctrl=""
        while [ "$k" -lt 15 ]; do
          ctrl=$(bt_cmd "list" | head -n1 | awk '{print $2}')
          [ -n "$ctrl" ] && break
          sleep 0.2
          k=$((k + 1))
        done

        # 3. Ligar controlador
        if [ -n "$ctrl" ]; then
          printf "select %s\npower on\nquit\n" "$ctrl" | bluetoothctl >/dev/null 2>&1 || true
        fi
        bt_cmd "power on" >/dev/null 2>&1 || true

        # 4. Aguardar o controlador efetivamente ligar
        local i=0
        while ! power_on && [ "$i" -lt 20 ]; do
          if [ $((i % 3)) -eq 0 ]; then
            if [ -n "$ctrl" ]; then
              printf "select %s\npower on\nquit\n" "$ctrl" | bluetoothctl >/dev/null 2>&1 || true
            else
              bt_cmd "power on" >/dev/null 2>&1 || true
            fi
          fi
          sleep 0.2
          i=$((i + 1))
        done

        if power_on; then
          notify_bt "normal" "bluetooth-active" "Bluetooth Ativado" "Controlador pronto para conexões."
          if [ "$from_cli" = "--no-menu" ]; then
            exit 0
          fi
          show_menu
        else
          notify_bt "critical" "bluetooth-disabled" "Falha ao Ativar" "Não foi possível ligar o Bluetooth. Verifique o serviço ou o Blueman."
          exit 1
        fi
      fi
    }

    scan_on() {
      pgrep -f "bluetoothctl.*scan" >/dev/null 2>&1 || bt_cmd "show" | grep -i "Discovering:" | grep -q "yes"
    }

    toggle_scan() {
      if scan_on; then
        pkill -f "bluetoothctl.*scan" >/dev/null 2>&1 || true
        bt_cmd "scan off" >/dev/null 2>&1 || true
        sleep 0.3
        notify_bt "low" "bluetooth-active" "Escaneamento Parado" "Busca por dispositivos interrompida."
      else
        notify_bt "normal" "bluetooth-active" "Buscando Dispositivos..." "Varredura ativa em segundo plano por 60s."
        pkill -f "bluetoothctl.*scan" >/dev/null 2>&1 || true
        (
          printf "scan on\n"
          sleep 60
          printf "scan off\nquit\n"
        ) | bluetoothctl >/dev/null 2>&1 &
        # Aguarda brevemente para que os primeiros beacons sejam capturados
        sleep 2.5
      fi
      show_menu
    }

    pairable_on() {
      bt_cmd "show" | grep -i "Pairable:" | grep -q "yes"
    }

    toggle_pairable() {
      if pairable_on; then
        bt_cmd "pairable off" >/dev/null 2>&1 || true
        notify_bt "low" "bluetooth-active" "Modo Pareável" "Desativado."
      else
        bt_cmd "pairable on" >/dev/null 2>&1 || true
        notify_bt "normal" "bluetooth-active" "Modo Pareável" "Ativado. Outros dispositivos podem parear."
      fi
      sleep 0.2
      show_menu
    }

    discoverable_on() {
      bt_cmd "show" | grep -i "Discoverable:" | grep -q "yes"
    }

    toggle_discoverable() {
      if discoverable_on; then
        bt_cmd "discoverable off" >/dev/null 2>&1 || true
        notify_bt "low" "bluetooth-active" "Visibilidade" "Oculto para novos aparelhos."
      else
        bt_cmd "discoverable on" >/dev/null 2>&1 || true
        notify_bt "normal" "bluetooth-active" "Visibilidade" "Visível para outros aparelhos."
      fi
      sleep 0.2
      show_menu
    }

    # Submenu de opções para o dispositivo selecionado
    device_menu() {
      local mac="$1"
      local name="$2"
      [ -z "$mac" ] && { show_menu; return; }

      local info
      info=$(bt_cmd "info $mac")

      local rname
      rname=$(echo "$info" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
      if [ -z "$rname" ]; then
        rname=$(echo "$info" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
      fi
      [ -n "$rname" ] && name="$rname"
      [ -z "$name" ] && name="Dispositivo Desconhecido"

      local is_connected="Não"
      local is_paired="Não"
      local is_trusted="Não"
      local is_blocked="Não"
      local battery=""

      echo "$info" | grep -q "Connected: yes" && is_connected="Sim"
      echo "$info" | grep -q "Paired: yes" && is_paired="Sim"
      echo "$info" | grep -q "Trusted: yes" && is_trusted="Sim"
      echo "$info" | grep -q "Blocked: yes" && is_blocked="Sim"

      local batt_val=""
      if [[ "$info" =~ [Bb]attery.*\(+([0-9]+)\)+ ]]; then
        batt_val="${BASH_REMATCH[1]}"
      elif [[ "$info" =~ [Bb]attery[^:]*:[[:space:]]*0x([0-9a-fA-F]+) ]]; then
        batt_val=$(( 16#${BASH_REMATCH[1]} ))
      elif [[ "$info" =~ [Bb]attery[^:]*:[[:space:]]*([0-9]+)%? ]]; then
        batt_val="${BASH_REMATCH[1]}"
      fi
      [ -n "$batt_val" ] && [ "$batt_val" -le 100 ] 2>/dev/null && battery=" | 󰁹 Bateria: $batt_val%"

      local OPT_CONN
      if [ "$is_connected" = "Sim" ]; then
        OPT_CONN="󰂲  Desconectar"
      else
        OPT_CONN="󰂱  Conectar"
      fi

      local OPT_PAIR
      if [ "$is_paired" = "Sim" ]; then
        OPT_PAIR="󰌆  Desparear Dispositivo"
      else
        OPT_PAIR="󰌆  Parear e Conectar"
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

      local dicon_class; dicon_class=$(echo "$info" | grep -i "Icon:" | awk '{print $2}')
      local dclass_hex; dclass_hex=$(echo "$info" | grep -i "Class:" | awk '{print $2}')
      local duuids; duuids=$(echo "$info" | grep -i "UUID:")
      local dev_icon; dev_icon=$(get_device_icon "$dicon_class" "$dclass_hex" "$duuids" "$name")

      local PROMPT_TEXT=" $dev_icon $name [$mac] (Conectado: $is_connected$battery) "

      local CHOICE
      CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s" \
        "$OPT_CONN" \
        "$OPT_PAIR" \
        "$OPT_TRUST" \
        "$OPT_BLOCK" \
        "$OPT_REMOVE" \
        "$OPT_BACK" | rofi -dmenu -i -p "$PROMPT_TEXT" \
        -theme-str 'window {width: 850px; border-radius: 14px;} listview {columns: 1; lines: 6;}' -no-custom)

      case "$CHOICE" in
        *"Desconectar"*)
          notify_bt "low" "bluetooth-active" "Desconectando..." "Desconectando $name..."
          bt_cmd "disconnect $mac" >/dev/null 2>&1 || true
          local i=0
          while bt_cmd "info $mac" | grep -q "Connected: yes" && [ "$i" -lt 15 ]; do
            sleep 0.1
            i=$((i + 1))
          done
          notify_bt "normal" "bluetooth-active" "Desconectado" "$name foi desconectado."
          show_menu
          ;;
        *"Conectar"*)
          notify_bt "normal" "bluetooth-active" "Conectando..." "Tentando conectar a $name..."
          bt_cmd "trust $mac" >/dev/null 2>&1 || true
          if [ "$is_paired" != "Sim" ]; then
            bt_cmd "pair $mac" >/dev/null 2>&1 || true
            sleep 0.4
          fi
          bt_cmd "connect $mac" >/dev/null 2>&1 || true
          local i=0
          while ! bt_cmd "info $mac" | grep -q "Connected: yes" && [ "$i" -lt 20 ]; do
            sleep 0.1
            i=$((i + 1))
          done
          if bt_cmd "info $mac" | grep -q "Connected: yes"; then
            notify_bt "normal" "bluetooth-active" "Conectado!" "$name conectado com sucesso."
          else
            notify_bt "critical" "bluetooth-disabled" "Erro de Conexão" "Falha ao conectar a $name. Se necessário, abra o Blueman."
          fi
          show_menu
          ;;
        *"Desparear"*)
          notify_bt "low" "bluetooth-active" "Despareando..." "Desconectando e despareando $name..."
          bt_cmd "disconnect $mac" >/dev/null 2>&1 || true
          sleep 0.2
          bt_cmd "untrust $mac" >/dev/null 2>&1 || true
          bt_cmd "remove $mac" >/dev/null 2>&1 || true
          sleep 0.4
          notify_bt "normal" "bluetooth-disabled" "Dispositivo Despareado" "$name foi despareado com sucesso."
          show_menu
          ;;
        *"Remover"*|*"Esquecer"*)
          notify_bt "low" "bluetooth-active" "Removendo..." "Desconectando e esquecendo $name..."
          bt_cmd "disconnect $mac" >/dev/null 2>&1 || true
          local i=0
          while bt_cmd "info $mac" | grep -q "Connected: yes" && [ "$i" -lt 15 ]; do
            sleep 0.1
            i=$((i + 1))
          done
          bt_cmd "untrust $mac" >/dev/null 2>&1 || true
          bt_cmd "remove $mac" >/dev/null 2>&1 || true
          sleep 0.5
          notify_bt "normal" "bluetooth-disabled" "Dispositivo Removido" "$name foi esquecido com sucesso."
          show_menu
          ;;
        *"Parear"*)
          notify_bt "normal" "bluetooth-active" "Pareando..." "Pareando com $name..."
          bt_cmd "pair $mac" >/dev/null 2>&1 || true
          bt_cmd "trust $mac" >/dev/null 2>&1 || true
          bt_cmd "connect $mac" >/dev/null 2>&1 || true
          sleep 0.5
          notify_bt "normal" "bluetooth-active" "Pareado!" "$name pareado com sucesso."
          show_menu
          ;;
        *"Remover Confiança"*)
          bt_cmd "untrust $mac" >/dev/null 2>&1 || true
          notify_bt "low" "bluetooth-active" "Não Confiável" "Confiança removida de $name."
          sleep 0.2
          device_menu "$mac" "$name"
          ;;
        *"Confiar"*)
          bt_cmd "trust $mac" >/dev/null 2>&1 || true
          notify_bt "normal" "bluetooth-active" "Confiável" "$name marcado como confiável."
          sleep 0.2
          device_menu "$mac" "$name"
          ;;
        *"Desbloquear"*)
          bt_cmd "unblock $mac" >/dev/null 2>&1 || true
          notify_bt "normal" "bluetooth-active" "Desbloqueado" "$name foi desbloqueado."
          sleep 0.2
          device_menu "$mac" "$name"
          ;;
        *"Bloquear"*)
          bt_cmd "disconnect $mac" >/dev/null 2>&1 || true
          sleep 0.2
          bt_cmd "block $mac" >/dev/null 2>&1 || true
          notify_bt "low" "bluetooth-disabled" "Bloqueado" "$name foi bloqueado."
          sleep 0.2
          device_menu "$mac" "$name"
          ;;
        *)
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
        CH=$(printf "%s\n%s" "$OFF_OPT" "$BM_OPT" | rofi -dmenu -i -p " 󰂲 Bluetooth Desligado " \
          -theme-str 'window {width: 600px; border-radius: 14px;} listview {columns: 1; lines: 2;}' -no-custom)
        case "$CH" in
          *"Ligar Bluetooth"*)
            toggle_power
            ;;
          *"Blueman"*)
            blueman-manager &
            ;;
        esac
        exit 0
      fi

      local is_scan_active=0
      scan_on && is_scan_active=1

      local SCAN_TEXT="󰑐  Escanear Novos Dispositivos (Scan: OFF)"
      local REFRESH_ITEM=""
      if [ "$is_scan_active" -eq 1 ]; then
        SCAN_TEXT="󰑐  Parar Escaneamento (Scan: ATIVO)"
        REFRESH_ITEM="󰑐  Atualizar Lista (Escaneamento Ativo)\n"
      fi

      local PAIR_TEXT="󰌆  Modo Pareável (Pairable: OFF)"
      pairable_on && PAIR_TEXT="󰌆  Modo Pareável (Pairable: ON)"

      local DISC_TEXT="󰈈  Visibilidade (Discoverable: OFF)"
      discoverable_on && DISC_TEXT="󰈈  Visibilidade (Discoverable: ON)"

      local HEADER_ITEMS="󰂲  Desligar Bluetooth\n$SCAN_TEXT\n$REFRESH_ITEM$PAIR_TEXT\n$DISC_TEXT\n󰂯  Abrir Blueman (Gerenciador Avançado)"

      local CONN_ITEMS=""
      local PAIRED_ITEMS=""
      local SCANNED_ITEMS=""
      local SEEN_MACS=()

      # 1. Obter dispositivos pareados e checar conexões
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        if [[ "$line" =~ Device[[:space:]]+(([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}) ]]; then
          local mac="${BASH_REMATCH[1]}"
          SEEN_MACS+=("$mac")

          local dinfo
          dinfo=$(bt_cmd "info $mac")

          local name
          name=$(echo "$dinfo" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          if [ -z "$name" ]; then
            name=$(echo "$dinfo" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          fi
          if [ -z "$name" ]; then
            name=$(echo "$line" | sed -E "s/.*${mac}[[:space:]]*//")
          fi
          [ -z "$name" ] && name="Dispositivo Desconhecido"

          local icon_class; icon_class=$(echo "$dinfo" | grep -i "Icon:" | awk '{print $2}')
          local class_hex; class_hex=$(echo "$dinfo" | grep -i "Class:" | awk '{print $2}')
          local uuids; uuids=$(echo "$dinfo" | grep -i "UUID:")
          local icon; icon=$(get_device_icon "$icon_class" "$class_hex" "$uuids" "$name")

          if echo "$dinfo" | grep -q "Connected: yes"; then
            local batt=""
            if [[ "$dinfo" =~ [Bb]attery.*\(+([0-9]+)\)+ ]]; then
              batt="${BASH_REMATCH[1]}"
            elif [[ "$dinfo" =~ [Bb]attery[^:]*:[[:space:]]*0x([0-9a-fA-F]+) ]]; then
              batt=$(( 16#${BASH_REMATCH[1]} ))
            elif [[ "$dinfo" =~ [Bb]attery[^:]*:[[:space:]]*([0-9]+)%? ]]; then
              batt="${BASH_REMATCH[1]}"
            fi
            if [ -n "$batt" ] && [ "$batt" -le 100 ] 2>/dev/null; then
              CONN_ITEMS+="$icon  $name  [$mac]  (󰂱 Conectado 󰁹 $batt%)\n"
            else
              CONN_ITEMS+="$icon  $name  [$mac]  (󰂱 Conectado)\n"
            fi
          else
            PAIRED_ITEMS+="$icon  $name  [$mac]  (Pareado)\n"
          fi
        fi
      done < <(bt_cmd "paired-devices")

      # 2. Obter todos os dispositivos conhecidos/descobertos pelo BlueZ (conectados não pareados e disponíveis)
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        if [[ "$line" =~ Device[[:space:]]+(([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}) ]]; then
          local mac="${BASH_REMATCH[1]}"

          local already_seen=0
          for seen in "${SEEN_MACS[@]}"; do
            if [ "$seen" = "$mac" ]; then
              already_seen=1
              break
            fi
          done
          [ "$already_seen" -eq 1 ] && continue
          SEEN_MACS+=("$mac")

          local dinfo
          dinfo=$(bt_cmd "info $mac")

          local name
          name=$(echo "$dinfo" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          if [ -z "$name" ]; then
            name=$(echo "$dinfo" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          fi
          if [ -z "$name" ]; then
            name=$(echo "$line" | sed -E "s/.*${mac}[[:space:]]*//")
          fi
          [ -z "$name" ] && name="Dispositivo Desconhecido"

          local icon_class; icon_class=$(echo "$dinfo" | grep -i "Icon:" | awk '{print $2}')
          local class_hex; class_hex=$(echo "$dinfo" | grep -i "Class:" | awk '{print $2}')
          local uuids; uuids=$(echo "$dinfo" | grep -i "UUID:")
          local icon; icon=$(get_device_icon "$icon_class" "$class_hex" "$uuids" "$name")

          if echo "$dinfo" | grep -q "Connected: yes"; then
            local batt=""
            if [[ "$dinfo" =~ [Bb]attery.*\(+([0-9]+)\)+ ]]; then
              batt="${BASH_REMATCH[1]}"
            elif [[ "$dinfo" =~ [Bb]attery[^:]*:[[:space:]]*0x([0-9a-fA-F]+) ]]; then
              batt=$(( 16#${BASH_REMATCH[1]} ))
            elif [[ "$dinfo" =~ [Bb]attery[^:]*:[[:space:]]*([0-9]+)%? ]]; then
              batt="${BASH_REMATCH[1]}"
            fi
            if [ -n "$batt" ] && [ "$batt" -le 100 ] 2>/dev/null; then
              CONN_ITEMS+="$icon  $name  [$mac]  (󰂱 Conectado 󰁹 $batt%)\n"
            else
              CONN_ITEMS+="$icon  $name  [$mac]  (󰂱 Conectado)\n"
            fi
          else
            [ "$icon" = "󰂱" ] && icon="󰑐"
            SCANNED_ITEMS+="$icon  $name  [$mac]  (Disponível)\n"
          fi
        fi
      done < <(bt_cmd "devices")

      local DEV_LIST=""
      [ -n "$CONN_ITEMS" ] && DEV_LIST+="$CONN_ITEMS"
      [ -n "$PAIRED_ITEMS" ] && DEV_LIST+="$PAIRED_ITEMS"
      [ -n "$SCANNED_ITEMS" ] && DEV_LIST+="$SCANNED_ITEMS"

      local MENU_CONTENT="$HEADER_ITEMS"
      if [ -n "$DEV_LIST" ]; then
        MENU_CONTENT+="\n------------------------------------\n$DEV_LIST"
      else
        if [ "$is_scan_active" -eq 1 ]; then
          MENU_CONTENT+="\n------------------------------------\n󰑐  Escaneando dispositivos ao redor... (Clique para Atualizar)"
        else
          MENU_CONTENT+="\n------------------------------------\n󰂲  Nenhum dispositivo encontrado (Clique em Escanear)"
        fi
      fi

      local SELECTED
      SELECTED=$(printf "%b" "$MENU_CONTENT" | rofi -dmenu -i -p " 󰂯 Bluetooth " \
        -theme-str 'window {width: 900px; border-radius: 14px;} listview {columns: 1; lines: 14;}' -no-custom)

      [ -z "$SELECTED" ] && exit 0

      case "$SELECTED" in
        *"Desligar Bluetooth"*)
          toggle_power
          ;;
        *"Atualizar Lista"*)
          show_menu
          ;;
        *"Escanear Novos Dispositivos"*|*"Parar Escaneamento"*)
          toggle_scan
          ;;
        *"Modo Pareável"*)
          toggle_pairable
          ;;
        *"Visibilidade"*)
          toggle_discoverable
          ;;
        *"Abrir Blueman"*)
          blueman-manager &
          ;;
        *"----------------"*)
          show_menu
          ;;
        *"Nenhum dispositivo"*|*"Escaneando dispositivos"*)
          if [ "$is_scan_active" -eq 1 ]; then
            show_menu
          else
            toggle_scan
          fi
          ;;
        *)
          if [[ "$SELECTED" =~ \[([0-9A-Fa-f:]{17})\] ]]; then
            local dev_mac="${BASH_REMATCH[1]}"
            local dev_name
            dev_name=$(echo "$SELECTED" | sed -E 's/^[󰂱󰂯󰑐󰓃󰋋󰥰󰌌󰍽󰏲󰌢 ]+//;s/  \[.*//')
            device_menu "$dev_mac" "$dev_name"
          fi
          ;;
      esac
    }

    case "${1:-}" in
      --toggle)
        toggle_power --no-menu
        ;;
      --scan)
        toggle_scan
        ;;
      *)
        show_menu
        ;;
    esac
