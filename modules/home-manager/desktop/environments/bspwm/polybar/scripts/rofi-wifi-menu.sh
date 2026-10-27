#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

notify_wifi() {
      local urgency="$1"
      local icon="$2"
      local title="$3"
      local msg="$4"
      dunstify -a "Rede" -u "$urgency" -i "$icon" -h string:x-dunst-stack-tag:network-osd -t 3500 "$title" "$msg"
    }

    get_wifi_device() {
      nmcli -t -f DEVICE,TYPE device 2>/dev/null | grep ':wifi$' | head -n1 | cut -d: -f1
    }

    get_wired_device() {
      local dev
      dev=$(nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | grep ':ethernet:connected$' | head -n1 | cut -d: -f1)
      if [ -z "$dev" ]; then
        dev=$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | grep ':ethernet$' | head -n1 | cut -d: -f1)
      fi
      echo "$dev"
    }

    wifi_radio_on() {
      [ "$(nmcli radio wifi 2>/dev/null)" = "enabled" ]
    }

    get_bars() {
      local sig="${1:-0}"
      if [ "$sig" -ge 75 ]; then
        echo "▂▄▆█"
      elif [ "$sig" -ge 50 ]; then
        echo "▂▄▆_"
      elif [ "$sig" -ge 25 ]; then
        echo "▂▄__"
      else
        echo "▂___"
      fi
    }

    toggle_wifi_radio() {
      if wifi_radio_on; then
        notify_wifi "low" "network-wireless-offline" "Wi-Fi Desativado" "O rádio Wi-Fi foi desligado."
        nmcli radio wifi off 2>/dev/null || true
        exit 0
      else
        notify_wifi "normal" "network-wireless" "Wi-Fi Ativado" "Ligando rádio Wi-Fi e buscando redes..."
        nmcli radio wifi on 2>/dev/null || true

        # Aguardar interface Wi-Fi ser inicializada pelo driver
        local wdev=""
        local i=0
        while [ "$i" -lt 15 ]; do
          wdev=$(get_wifi_device)
          if [ -n "$wdev" ]; then
            local wstate
            wstate=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | grep "^$wdev:" | head -n1 | cut -d: -f2)
            if [ "$wstate" = "disconnected" ] || [ "$wstate" = "connected" ]; then
              break
            fi
          fi
          sleep 0.2
          i=$((i + 1))
        done

        # Executar scan inicial
        nmcli device wifi rescan ${wdev:+ifname "$wdev"} 2>/dev/null || true
        sleep 2
        show_main_menu
      fi
    }

    show_wired_details() {
      local dev="$1"
      local state="$2"
      local conn="$3"
      local ip="$4"

      local details=()
      details+=("󰈀  Interface:         $dev")
      details+=("󰌘  Status:            $([ "$state" = "connected" ] && echo "Conectada (Ativa)" || echo "Desconectada")")
      details+=("󱦂  Perfil Ativo:      ${conn:-Nenhum}")

      if [ -n "$ip" ]; then
        details+=("󱦂  Endereço IP:       $ip")
      fi

      local gw_info dns_info mac_info speed_info
      gw_info=$(nmcli -t -f IP4.GATEWAY dev show "$dev" 2>/dev/null | head -n1 | cut -d: -f2-)
      dns_info=$(nmcli -t -f IP4.DNS dev show "$dev" 2>/dev/null | tr '\n' ' ' | sed 's/IP4.DNS:[[:space:]]*//g')
      mac_info=$(nmcli -t -f GENERAL.HWADDR dev show "$dev" 2>/dev/null | head -n1 | cut -d: -f2-)
      speed_info=$(nmcli -t -f WIRED-PROPERTIES.SPEED dev show "$dev" 2>/dev/null | head -n1 | cut -d: -f2-)

      [ -n "$gw_info" ] && details+=("󰒍  Gateway:           $gw_info")
      [ -n "$dns_info" ] && details+=("󰀂  Servidores DNS:    $dns_info")
      [ -n "$mac_info" ] && details+=("󰈀  Endereço MAC:      $mac_info")
      [ -n "$speed_info" ] && details+=("󰓅  Velocidade Link:   ${speed_info} Mb/s")
      details+=("󰌍  Voltar")

      printf "%s\n" "${details[@]}" | rofi \
        -dmenu \
        -i \
        -p "Detalhes: $dev" \
        -theme-str 'window {width: 650px; border-radius: 14px;} listview {columns: 1; lines: 9;}' \
        -no-custom >/dev/null 2>&1 || true
    }

    forget_wired_profile() {
      local puuid="$1"
      local pname="$2"

      local confirm
      confirm=$(printf "󰀦  Sim, excluir perfil\n󰌍  Cancelar" | rofi \
        -dmenu \
        -i \
        -p "Excluir perfil cabeado \"$pname\"?" \
        -theme-str 'window {width: 540px; border-radius: 14px;} listview {columns: 1; lines: 2;}' \
        -no-custom)

      if [[ "$confirm" =~ "Sim" ]]; then
        if nmcli connection delete uuid "$puuid" 2>/dev/null || nmcli connection delete id "$pname" 2>/dev/null; then
          notify_wifi "normal" "network-wired" "Perfil Excluído" "O perfil cabeado \"$pname\" foi removido com sucesso."
        else
          notify_wifi "critical" "network-wired-disconnected" "Erro" "Não foi possível excluir o perfil \"$pname\"."
        fi
      fi
    }

    wired_profile_menu() {
      local puuid="$1"
      local pname="$2"
      local pdev="$3"

      local actions=(
        "󰈂  Desconectar esta Conexão"
        "󰑐  Reconectar / Renovar IP"
        "󰋼  Ver Detalhes da Conexão"
      )
      if [ "$puuid" != "auto" ]; then
        actions+=("󰀦  Esquecer / Excluir Perfil ($pname)")
      fi
      actions+=("󰌍  Voltar")

      local act
      act=$(printf "%s\n" "${actions[@]}" | rofi \
        -dmenu \
        -i \
        -p "Perfil Ativo: $pname" \
        -theme-str 'window {width: 580px; border-radius: 14px;} listview {columns: 1; lines: 5;}' \
        -no-custom)

      [ -z "$act" ] && { wired_menu; return; }

      case "$act" in
        *"Desconectar"*)
          notify_wifi "low" "network-wired-disconnected" "Rede Cabeada" "Desconectando perfil \"$pname\"..."
          nmcli device disconnect "$pdev" 2>/dev/null || true
          sleep 0.5
          notify_wifi "normal" "network-wired-disconnected" "Desconectado" "Perfil \"$pname\" desconectado."
          wired_menu
          ;;
        *"Reconectar"*)
          notify_wifi "low" "network-wired" "Rede Cabeada" "Reconectando \"$pname\"..."
          nmcli connection up uuid "$puuid" 2>/dev/null || nmcli connection up id "$pname" 2>/dev/null || true
          sleep 1.2
          local new_ip
          new_ip=$(nmcli -t -f IP4.ADDRESS dev show "$pdev" 2>/dev/null | head -n1 | cut -d: -f2)
          notify_wifi "normal" "network-wired" "Reconectado" "Conexão restabelecida!${new_ip:+ IP: $new_ip}"
          wired_menu
          ;;
        *"Detalhes"*)
          local pip pstate
          pstate="Ativa"
          pip=$(nmcli -t -f IP4.ADDRESS dev show "$pdev" 2>/dev/null | head -n1 | cut -d: -f2)
          show_wired_details "$pdev" "$pstate" "$pname" "$pip"
          wired_profile_menu "$puuid" "$pname" "$pdev"
          ;;
        *"Esquecer"*)
          forget_wired_profile "$puuid" "$pname"
          wired_menu
          ;;
        *)
          wired_menu
          ;;
      esac
    }

    wired_menu() {
      local eth_dev
      eth_dev=$(get_wired_device)
      if [ -z "$eth_dev" ]; then
        notify_wifi "critical" "network-wired-disconnected" "Rede Cabeada" "Nenhuma interface Ethernet detectada."
        show_main_menu
        return
      fi

      # Recarregar conexões caso tenham sido criadas recentemente em editores ou terminal
      nmcli connection reload 2>/dev/null || true

      local eth_state
      eth_state=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | grep "^$eth_dev:" | head -n1 | cut -d: -f2)
      local eth_conn
      eth_conn=$(nmcli -t -f DEVICE,CONNECTION device 2>/dev/null | grep "^$eth_dev:" | head -n1 | cut -d: -f2)
      local eth_ip
      eth_ip=$(nmcli -t -f IP4.ADDRESS dev show "$eth_dev" 2>/dev/null | head -n1 | cut -d: -f2)

      local raw_conns
      raw_conns=$(nmcli -t -f TYPE,UUID,DEVICE,NAME connection show 2>/dev/null | grep '^802-3-ethernet:' | cut -d: -f2-)

      local conn_items=()
      local conn_uuids=()
      local conn_names=()
      local conn_states=()

      if [ -n "$raw_conns" ]; then
        while IFS=: read -r cuuid cdev cname; do
          cname=$(echo "$cname" | sed 's/\\:/:/g')
          [ -z "$cuuid" ] || [ -z "$cname" ] && continue

          # Pular se estiver explicitamente vinculado a outro dispositivo que não seja eth_dev
          if [ -n "$cdev" ] && [ "$cdev" != "--" ] && [ "$cdev" != "$eth_dev" ]; then
            continue
          fi

          local is_active=false
          if [ "$eth_state" = "connected" ] && [ "$cname" = "$eth_conn" ]; then
            is_active=true
          fi

          conn_uuids+=("$cuuid")
          conn_names+=("$cname")
          conn_states+=("$is_active")

          local prefix="󰈀  ○"
          local status_tag="[Disponível]"
          if [ "$is_active" = true ]; then
            prefix="󰈁  ●"
            status_tag="[Ativa${eth_ip:+ - $eth_ip}]"
          fi

          local line
          line=$(printf "%s  %-30s  %s" "$prefix" "$cname" "$status_tag")
          conn_items+=("$line")
        done <<< "$raw_conns"
      fi

      if [ "${#conn_items[@]}" -eq 0 ]; then
        local def_line
        if [ "$eth_state" = "connected" ]; then
          def_line=$(printf "󰈁  ●  %-30s  [Ativa%s]" "Conexão Automática ($eth_dev)" "${eth_ip:+ - $eth_ip}")
        else
          def_line=$(printf "󰈀  ○  %-30s  [Disponível - Conectar DHCP]" "Conexão Padrão ($eth_dev)")
        fi
        conn_items+=("$def_line")
        conn_uuids+=("auto")
        conn_names+=("Conexão Automática ($eth_dev)")
        conn_states+=("$([ "$eth_state" = "connected" ] && echo true || echo false)")
      fi

      local options=()
      options+=("󰌍  Voltar ao Menu Principal")

      if [ "$eth_state" = "connected" ]; then
        options+=("󰈂  Desconectar Cabo da Interface $eth_dev")
        options+=("󰑐  Reconectar / Renovar IP ($eth_conn)")
      fi

      options+=("────────────────────────────────────────────────────────────────────────")
      for item in "${conn_items[@]}"; do
        options+=("$item")
      done
      options+=("────────────────────────────────────────────────────────────────────────")
      options+=("󰋼  Detalhes da Interface ($eth_dev)")
      options+=("󰒓  Criar / Configurar Conexões (nm-connection-editor)")

      local chosen_wired
      chosen_wired=$(printf "%s\n" "${options[@]}" | rofi \
        -dmenu \
        -i \
        -p "Rede Cabeada ($eth_dev)" \
        -theme-str 'window {width: 720px; border-radius: 14px;} listview {columns: 1; lines: 10;}' \
        -no-custom)

      [ -z "$chosen_wired" ] && { show_main_menu; return; }

      case "$chosen_wired" in
        *"Voltar ao Menu Principal"*)
          show_main_menu
          return
          ;;
        *"Desconectar Cabo"*)
          notify_wifi "low" "network-wired-disconnected" "Rede Cabeada" "Desconectando interface $eth_dev..."
          nmcli device disconnect "$eth_dev" 2>/dev/null || true
          sleep 0.5
          notify_wifi "normal" "network-wired-disconnected" "Rede Cabeada Desconectada" "Interface $eth_dev desconectada."
          wired_menu
          return
          ;;
        *"Reconectar"*)
          notify_wifi "low" "network-wired" "Rede Cabeada" "Reconectando interface $eth_dev..."
          nmcli connection up id "$eth_conn" 2>/dev/null || nmcli device connect "$eth_dev" 2>/dev/null || true
          sleep 1.2
          local new_ip
          new_ip=$(nmcli -t -f IP4.ADDRESS dev show "$eth_dev" 2>/dev/null | head -n1 | cut -d: -f2)
          notify_wifi "normal" "network-wired" "Rede Cabeada Reconectada" "Interface $eth_dev conectada com sucesso!${new_ip:+ IP: $new_ip}"
          wired_menu
          return
          ;;
        *"Detalhes da Interface"*)
          show_wired_details "$eth_dev" "$eth_state" "$eth_conn" "$eth_ip"
          wired_menu
          return
          ;;
        *"Criar / Configurar"*)
          if command -v nm-connection-editor >/dev/null 2>&1; then
            nm-connection-editor &
          elif [ -x "nm-connection-editor" ]; then
            nm-connection-editor &
          fi
          exit 0
          ;;
        *"────"*)
          wired_menu
          return
          ;;
        *)
          local sel_idx=-1
          local i=0
          while [ "$i" -lt "${#conn_items[@]}" ]; do
            if [ "${conn_items[$i]}" = "$chosen_wired" ]; then
              sel_idx=$i
              break
            fi
            i=$((i + 1))
          done

          if [ "$sel_idx" -ge 0 ]; then
            local target_uuid="${conn_uuids[$sel_idx]}"
            local target_name="${conn_names[$sel_idx]}"
            local target_active="${conn_states[$sel_idx]}"

            if [ "$target_active" = true ]; then
              wired_profile_menu "$target_uuid" "$target_name" "$eth_dev"
            else
              notify_wifi "low" "network-wired" "Conectando..." "Iniciando conexão \"$target_name\" em $eth_dev..."
              local conn_ok=false
              if [ "$target_uuid" = "auto" ]; then
                nmcli device connect "$eth_dev" 2>/dev/null && conn_ok=true
              else
                (nmcli connection up uuid "$target_uuid" 2>/dev/null || nmcli connection up id "$target_name" 2>/dev/null) && conn_ok=true
              fi

              if [ "$conn_ok" = true ]; then
                sleep 1.2
                local new_ip
                new_ip=$(nmcli -t -f IP4.ADDRESS dev show "$eth_dev" 2>/dev/null | head -n1 | cut -d: -f2)
                notify_wifi "normal" "network-wired" "Rede Cabeada Conectada" "Perfil \"$target_name\" ativado com sucesso!${new_ip:+ IP: $new_ip}"
              else
                notify_wifi "critical" "network-wired-disconnected" "Falha na Conexão" "Não foi possível ativar o perfil \"$target_name\"."
              fi
              wired_menu
            fi
          else
            wired_menu
          fi
          return
          ;;
      esac
    }

    toggle_wired() {
      local eth_dev
      eth_dev=$(get_wired_device)
      if [ -z "$eth_dev" ]; then
        notify_wifi "critical" "network-wired-disconnected" "Rede Cabeada" "Nenhuma interface Ethernet detectada."
        show_main_menu
        return
      fi

      local eth_state
      eth_state=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | grep "^$eth_dev:" | head -n1 | cut -d: -f2)

      if [ "$eth_state" = "connected" ]; then
        notify_wifi "low" "network-wired-disconnected" "Rede Cabeada" "Desconectando interface $eth_dev..."
        nmcli device disconnect "$eth_dev" 2>/dev/null || true
        sleep 0.5
        notify_wifi "normal" "network-wired-disconnected" "Rede Cabeada Desconectada" "Interface $eth_dev desconectada."
        show_main_menu
      else
        wired_menu
      fi
    }

    connect_to_network() {
      local ssid="$1"
      local security="$2"
      local is_saved="$3"
      local wifi_dev
      wifi_dev=$(get_wifi_device)

      if [ "$is_saved" = true ]; then
        notify_wifi "low" "network-wireless" "Conectando..." "Conectando à rede salva \"$ssid\"..."
        if nmcli connection up id "$ssid" 2>/dev/null || nmcli connection up "$ssid" 2>/dev/null; then
          notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso a \"$ssid\"!"
        else
          notify_wifi "critical" "network-wireless-offline" "Falha na Conexão" "Não foi possível conectar a \"$ssid\". Tente esquecer e redigitar a senha."
        fi
      else
        if [ "$security" != "none" ]; then
          local wifi_pass
          wifi_pass=$(rofi -dmenu -password -p "Senha para $ssid" -theme-str 'window {width: 600px; border-radius: 14px;}')
          [ -z "$wifi_pass" ] && return

          notify_wifi "low" "network-wireless" "Autenticando..." "Conectando a \"$ssid\"..."
          if nmcli device wifi connect "$ssid" password "$wifi_pass" ${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
            notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso a \"$ssid\"!"
          else
            notify_wifi "critical" "network-wireless-offline" "Falha na Senha" "Senha incorreta ou erro ao conectar a \"$ssid\"."
          fi
        else
          notify_wifi "low" "network-wireless" "Conectando..." "Conectando à rede aberta \"$ssid\"..."
          if nmcli device wifi connect "$ssid" ${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
            notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso a \"$ssid\"!"
          else
            notify_wifi "critical" "network-wireless-offline" "Falha ao Conectar" "Não foi possível conectar à rede \"$ssid\"."
          fi
        fi
      fi
    }

    forget_network() {
      local ssid="$1"
      local confirm
      confirm=$(printf "󰀦  Sim, esquecer rede\n󰌍  Cancelar" | rofi \
        -dmenu \
        -i \
        -p "Esquecer perfil da rede \"$ssid\"?" \
        -theme-str 'window {width: 520px; border-radius: 14px;} listview {columns: 1; lines: 2;}' \
        -no-custom)

      if [[ "$confirm" =~ "Sim" ]]; then
        local deleted=false
        if nmcli connection delete id "$ssid" 2>/dev/null || nmcli connection delete "$ssid" 2>/dev/null; then
          deleted=true
        fi
        local uuid
        uuid=$(nmcli -t -f UUID,TYPE,NAME connection show 2>/dev/null | grep ":802-11-wireless:$ssid$" | head -n1 | cut -d: -f1)
        if [ -n "$uuid" ]; then
          nmcli connection delete uuid "$uuid" 2>/dev/null && deleted=true
        fi

        if [ "$deleted" = true ]; then
          notify_wifi "normal" "network-wireless" "Rede Esquecida" "O perfil e as credenciais da rede \"$ssid\" foram removidos."
        else
          notify_wifi "critical" "network-wireless-offline" "Erro" "Não foi possível excluir o perfil da rede \"$ssid\"."
        fi
      fi
    }

    connect_hidden_network() {
      local hidden_ssid
      hidden_ssid=$(rofi -dmenu -p "Nome da Rede Oculta (SSID)" -theme-str 'window {width: 580px; border-radius: 14px;}')
      [ -z "$hidden_ssid" ] && { show_main_menu; return; }

      local sec_choice
      sec_choice=$(printf "󰌾  WPA/WPA2/WPA3 Personal (Senha)\n󰤨  Aberta (Sem Senha)" | rofi \
        -dmenu \
        -i \
        -p "Segurança de $hidden_ssid" \
        -theme-str 'window {width: 520px; border-radius: 14px;} listview {columns: 1; lines: 2;}' \
        -no-custom)

      local wifi_dev
      wifi_dev=$(get_wifi_device)

      if [[ "$sec_choice" =~ "WPA" ]]; then
        local hidden_pass
        hidden_pass=$(rofi -dmenu -password -p "Senha para $hidden_ssid" -theme-str 'window {width: 580px; border-radius: 14px;}')
        [ -z "$hidden_pass" ] && { show_main_menu; return; }

        notify_wifi "low" "network-wireless" "Conectando..." "Conectando à rede oculta \"$hidden_ssid\"..."
        if nmcli device wifi connect "$hidden_ssid" password "$hidden_pass" hidden yes ${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
          notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso à rede oculta \"$hidden_ssid\"!"
        else
          notify_wifi "critical" "network-wireless-offline" "Falha" "Não foi possível conectar à rede oculta."
        fi
      else
        notify_wifi "low" "network-wireless" "Conectando..." "Conectando à rede oculta \"$hidden_ssid\"..."
        if nmcli device wifi connect "$hidden_ssid" hidden yes ${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
          notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso à rede oculta \"$hidden_ssid\"!"
        else
          notify_wifi "critical" "network-wireless-offline" "Falha" "Não foi possível conectar à rede oculta."
        fi
      fi
      show_main_menu
    }

    saved_networks_menu() {
      local saved_list
      saved_list=$(nmcli -t -f TYPE,NAME connection show 2>/dev/null | grep '^802-11-wireless:' | cut -d: -f2- | sed 's/\\:/:/g' | sort -u)

      if [ -z "$saved_list" ]; then
        notify_wifi "low" "network-wireless" "Redes Salvas" "Nenhum perfil Wi-Fi salvo encontrado."
        show_main_menu
        return
      fi

      local options=("󰌍  Voltar ao Menu Principal")
      while IFS= read -r sname; do
        [ -n "$sname" ] && options+=("󰤨  $sname")
      done <<< "$saved_list"

      local chosen_saved
      chosen_saved=$(printf "%s\n" "${options[@]}" | rofi \
        -dmenu \
        -i \
        -p "Gerenciar Redes Salvas" \
        -theme-str 'window {width: 650px; border-radius: 14px;} listview {columns: 1; lines: 10;}' \
        -no-custom)

      [ -z "$chosen_saved" ] && { show_main_menu; return; }

      if [[ "$chosen_saved" =~ "Voltar" ]]; then
        show_main_menu
        return
      fi

      local target_ssid
      target_ssid=$(echo "$chosen_saved" | sed 's/^󰤨  //; s/^ *//; s/ *$//')
      if [ -n "$target_ssid" ]; then
        local act
        act=$(printf "󰤨  Conectar Agora\n󰀦  Esquecer / Excluir Rede Salva\n󰌍  Voltar" | rofi \
          -dmenu \
          -i \
          -p "Perfil Salvo: $target_ssid" \
          -theme-str 'window {width: 550px; border-radius: 14px;} listview {columns: 1; lines: 3;}' \
          -no-custom)

        case "$act" in
          *"Conectar Agora"*)
            notify_wifi "low" "network-wireless" "Conectando..." "Conectando a \"$target_ssid\"..."
            if nmcli connection up id "$target_ssid" 2>/dev/null || nmcli connection up "$target_ssid" 2>/dev/null; then
              notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso a \"$target_ssid\"!"
            else
              notify_wifi "critical" "network-wireless-offline" "Falha" "Não foi possível conectar. Rede pode estar fora de alcance."
            fi
            show_main_menu
            ;;
          *"Esquecer"*)
            forget_network "$target_ssid"
            saved_networks_menu
            ;;
          *)
            saved_networks_menu
            ;;
        esac
      fi
    }

    show_network_details() {
      local ssid="$1"
      local is_connected="$2"
      local wifi_dev
      wifi_dev=$(get_wifi_device)

      local details=()
      details+=("󰤨  SSID:              $ssid")
      details+=("󰌘  Status:            $([ "$is_connected" = true ] && echo "Conectada (Ativa)" || echo "Ao alcance")")

      if [ "$is_connected" = true ] && [ -n "$wifi_dev" ]; then
        local ip_info gw_info dns_info
        ip_info=$(nmcli -t -f IP4.ADDRESS dev show "$wifi_dev" 2>/dev/null | head -n1 | cut -d: -f2-)
        gw_info=$(nmcli -t -f IP4.GATEWAY dev show "$wifi_dev" 2>/dev/null | head -n1 | cut -d: -f2-)
        dns_info=$(nmcli -t -f IP4.DNS dev show "$wifi_dev" 2>/dev/null | tr '\n' ' ' | sed 's/IP4.DNS:[[:space:]]*//g')
        [ -n "$ip_info" ] && details+=("󱦂  Endereço IP:       $ip_info")
        [ -n "$gw_info" ] && details+=("󰒍  Gateway:           $gw_info")
        [ -n "$dns_info" ] && details+=("󰀂  Servidores DNS:    $dns_info")
      fi

      local ap_info
      ap_info=$(nmcli -t -f SSID,SIGNAL,SECURITY,CHAN,FREQ,BSSID dev wifi list --rescan no 2>/dev/null | grep -F "$ssid:" | head -n1)
      if [ -n "$ap_info" ]; then
        local ap_signal ap_sec ap_chan ap_freq ap_bssid
        ap_signal=$(echo "$ap_info" | awk -F: '{print $2}')
        ap_sec=$(echo "$ap_info" | awk -F: '{print $3}')
        ap_chan=$(echo "$ap_info" | awk -F: '{print $4}')
        ap_freq=$(echo "$ap_info" | awk -F: '{print $5}')
        ap_bssid=$(echo "$ap_info" | cut -d: -f6-)

        [ -n "$ap_signal" ] && details+=("󰤨  Sinal:             ${ap_signal}% ($(get_bars "$ap_signal"))")
        [ -n "$ap_sec" ] && details+=("󰌾  Segurança:         $ap_sec")
        [ -n "$ap_chan" ] && details+=("󰀝  Canal / Freq:      Canal $ap_chan (${ap_freq})")
        [ -n "$ap_bssid" ] && details+=("󰈀  BSSID (MAC AP):    $ap_bssid")
      fi

      [ -n "$wifi_dev" ] && details+=("󰞌  Interface:         $wifi_dev")
      details+=("󰌍  Voltar")

      printf "%s\n" "${details[@]}" | rofi \
        -dmenu \
        -i \
        -p "Detalhes: $ssid" \
        -theme-str 'window {width: 650px; border-radius: 14px;} listview {columns: 1; lines: 11;}' \
        -no-custom >/dev/null 2>&1 || true
    }

    network_menu() {
      local ssid="$1"
      [ -z "$ssid" ] && { show_main_menu; return; }

      local wifi_dev
      wifi_dev=$(get_wifi_device)
      local active_ssid
      active_ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | head -n1 | cut -d: -f2)

      local is_connected=false
      [ "$active_ssid" = "$ssid" ] && is_connected=true

      local is_saved=false
      nmcli -t -f TYPE,NAME connection show 2>/dev/null | grep '^802-11-wireless:' | cut -d: -f2- | sed 's/\\:/:/g' | grep -Fxq "$ssid" && is_saved=true

      local options=()
      if [ "$is_connected" = true ]; then
        options+=("󰤮  Desconectar da Rede (\"$ssid\")")
        options+=("󰑐  Reconectar / Renovar IP")
      else
        options+=("󰤨  Conectar a esta Rede (\"$ssid\")")
      fi

      if [ "$is_saved" = true ]; then
        options+=("󰀦  Esquecer Rede (Excluir perfil salvo e senha)")
      fi

      options+=("󰋼  Detalhes da Rede e Conexão")
      options+=("󰌍  Voltar ao Menu Principal")

      local sub_prompt="Wi-Fi: $ssid"
      [ "$is_connected" = true ] && sub_prompt="[Conectada] Wi-Fi: $ssid"

      local chosen_sub
      chosen_sub=$(printf "%s\n" "${options[@]}" | rofi \
        -dmenu \
        -i \
        -p "$sub_prompt" \
        -theme-str 'window {width: 680px; border-radius: 14px;} listview {columns: 1; lines: 6;}' \
        -no-custom)

      [ -z "$chosen_sub" ] && { show_main_menu; return; }

      case "$chosen_sub" in
        *"Desconectar da Rede"*)
          notify_wifi "low" "network-wireless-offline" "Wi-Fi" "Desconectando de \"$ssid\"..."
          nmcli device disconnect "$wifi_dev" 2>/dev/null || nmcli connection down id "$ssid" 2>/dev/null || true
          sleep 0.5
          notify_wifi "normal" "network-wireless-offline" "Wi-Fi Desconectado" "Você foi desconectado da rede \"$ssid\"."
          show_main_menu
          ;;
        *"Reconectar"*)
          notify_wifi "low" "network-wireless" "Wi-Fi" "Reconectando a \"$ssid\"..."
          nmcli connection up id "$ssid" 2>/dev/null || nmcli device wifi connect "$ssid" 2>/dev/null || true
          sleep 1
          notify_wifi "normal" "network-wireless" "Wi-Fi Reconectado" "Conexão com \"$ssid\" restabelecida."
          show_main_menu
          ;;
        *"Conectar a esta Rede"*)
          local sec_type="WPA"
          local ap_match
          ap_match=$(nmcli -t -f SSID,SECURITY dev wifi list --rescan no 2>/dev/null | grep -F "$ssid:" | head -n1)
          if [[ "$ap_match" =~ :--$ ]]; then
            sec_type="none"
          fi
          connect_to_network "$ssid" "$sec_type" "$is_saved"
          show_main_menu
          ;;
        *"Esquecer Rede"*)
          forget_network "$ssid"
          show_main_menu
          ;;
        *"Detalhes da Rede"*)
          show_network_details "$ssid" "$is_connected"
          network_menu "$ssid"
          ;;
        *"Voltar"*)
          show_main_menu
          ;;
      esac
    }

    show_main_menu() {
      local wifi_dev
      wifi_dev=$(get_wifi_device)
      local is_wifi_on=false
      wifi_radio_on && is_wifi_on=true

      local active_wifi_ssid=""
      local active_wifi_ip=""
      if [ "$is_wifi_on" = true ] && [ -n "$wifi_dev" ]; then
        active_wifi_ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | head -n1 | cut -d: -f2)
        active_wifi_ip=$(nmcli -t -f IP4.ADDRESS dev show "$wifi_dev" 2>/dev/null | head -n1 | cut -d: -f2)
      fi

      local eth_dev
      eth_dev=$(get_wired_device)
      local eth_state="unavailable"
      local eth_conn=""
      local eth_ip=""
      if [ -n "$eth_dev" ]; then
        eth_state=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | grep "^$eth_dev:" | head -n1 | cut -d: -f2)
        eth_conn=$(nmcli -t -f DEVICE,CONNECTION device 2>/dev/null | grep "^$eth_dev:" | head -n1 | cut -d: -f2)
        eth_ip=$(nmcli -t -f IP4.ADDRESS dev show "$eth_dev" 2>/dev/null | head -n1 | cut -d: -f2)
      fi

      local top_options=()

      # Controle da Rede Cabeada (Wired)
      if [ -n "$eth_dev" ]; then
        if [ "$eth_state" = "connected" ]; then
          top_options+=("󰈁  Rede Cabeada: ${eth_conn:-Conectada}        [Cabo: $eth_dev - Ativa${eth_ip:+ ($eth_ip)} | Selecionar/Alternar]")
          top_options+=("󰈂  Desconectar Rede Cabeada        [Desconectar interface $eth_dev]")
        else
          top_options+=("󰈀  Conectar Rede Cabeada           [Cabo: $eth_dev Desconectado - Escolher Conexão para Iniciar]")
        fi
      fi

      # Controle do Rádio Wi-Fi
      if [ "$is_wifi_on" = true ]; then
        top_options+=("󰤮  Desativar Rádio Wi-Fi           [Wi-Fi Ligado${active_wifi_ssid:+ - $active_wifi_ssid}]")
      else
        top_options+=("󰤨  Ativar Rádio Wi-Fi              [Wi-Fi Desligado]")
      fi

      if [ "$is_wifi_on" = true ]; then
        top_options+=("󰑐  Escanear Redes Novamente        [Atualizar lista ao alcance]")
        top_options+=("󱛂  Conectar a Rede Oculta          [Digitar SSID e Senha manual]")
        top_options+=("󰁯  Gerenciar Redes Salvas          [Ver perfis e esquecer redes]")
        top_options+=("󰒓  Abrir Editor de Conexões        [Interface gráfica completa]")
      fi

      local wifi_entries=()
      if [ "$is_wifi_on" = true ]; then
        local saved_names
        saved_names=$(nmcli -t -f TYPE,NAME connection show 2>/dev/null | grep '^802-11-wireless:' | cut -d: -f2- | sed 's/\\:/:/g')

        # Buscar lista de redes (usando rescan no inicialmente para agilidade, se vazio faz rescan yes)
        local raw_list
        raw_list=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no 2>/dev/null)
        if [ -z "$raw_list" ]; then
          raw_list=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan yes 2>/dev/null)
        fi

        local seen_ssids="|"
        while IFS=: read -r in_use signal security ssid; do
          # Desescapar eventuais dois-pontos escapados pelo nmcli
          ssid=$(echo "$ssid" | sed 's/\\:/:/g')
          [ -z "$ssid" ] && continue

          if [[ "$seen_ssids" == *"|$ssid|"* ]]; then
            continue
          fi
          seen_ssids="$seen_ssids$ssid|"

          local prefix="󰤨"
          local status_tag="[Disponível]"

          if [ "$in_use" = "*" ]; then
            status_tag="[Conectada]"
            prefix="󰤨"
          elif echo "$saved_names" | grep -Fxq "$ssid"; then
            status_tag="[Salva]"
            prefix="󰤨"
          elif [[ "$security" =~ WPA|WEP|802.1X ]]; then
            status_tag="[Protegida]"
            prefix="󰌾"
          else
            status_tag="[Aberta]"
            prefix="󰤨"
          fi

          local bars
          bars=$(get_bars "$signal")

          local line
          line=$(printf "%s  %-32s  %-14s  [%s] %3s%%" "$prefix" "$ssid" "$status_tag" "$bars" "$signal")
          wifi_entries+=("$line")
        done <<< "$raw_list"
      fi

      local menu_content=""
      for opt in "${top_options[@]}"; do
        menu_content="${menu_content}${opt}\n"
      done

      if [ "${#wifi_entries[@]}" -gt 0 ]; then
        menu_content="${menu_content}────────────────────────────────────────────────────────────────────────\n"
        for w in "${wifi_entries[@]}"; do
          menu_content="${menu_content}${w}\n"
        done
      elif [ "$is_wifi_on" = true ]; then
        menu_content="${menu_content}────────────────────────────────────────────────────────────────────────\n"
        menu_content="${menu_content}󰤮  Nenhuma rede Wi-Fi encontrada ao alcance\n"
      fi

      local prompt_title="Redes & Wi-Fi"
      if [ -n "$active_wifi_ssid" ]; then
        prompt_title="Wi-Fi: $active_wifi_ssid"
      elif [ "$eth_state" = "connected" ]; then
        prompt_title="Cabo: $eth_dev"
      fi

      local chosen
      chosen=$(printf "%b" "$menu_content" | rofi \
        -dmenu \
        -i \
        -p "$prompt_title" \
        -theme-str 'window {width: 820px; border-radius: 14px;} listview {columns: 1; lines: 15;}' \
        -no-custom)

      [ -z "$chosen" ] && exit 0

      case "$chosen" in
        *"Rede Cabeada:"*)
          wired_menu
          ;;
        *"Desconectar Rede Cabeada"*)
          toggle_wired
          ;;
        *"Conectar Rede Cabeada"*)
          wired_menu
          ;;
        *"Desativar Rádio Wi-Fi"*)
          toggle_wifi_radio
          ;;
        *"Ativar Rádio Wi-Fi"*)
          toggle_wifi_radio
          ;;
        *"Escanear Redes Novamente"*)
          local wdev
          wdev=$(get_wifi_device)
          notify_wifi "low" "network-wireless" "Escaneando..." "Buscando redes Wi-Fi disponíveis..."
          nmcli device wifi rescan ${wdev:+ifname "$wdev"} 2>/dev/null || true
          sleep 2.5
          show_main_menu
          ;;
        *"Conectar a Rede Oculta"*)
          connect_hidden_network
          ;;
        *"Gerenciar Redes Salvas"*)
          saved_networks_menu
          ;;
        *"Abrir Editor de Conexões"*)
          if command -v nm-connection-editor >/dev/null 2>&1; then
            nm-connection-editor &
          elif [ -x "nm-connection-editor" ]; then
            nm-connection-editor &
          fi
          exit 0
          ;;
        *"────"*)
          show_main_menu
          ;;
        *"Nenhuma rede Wi-Fi"*)
          show_main_menu
          ;;
        *)
          local sel_ssid
          sel_ssid=$(echo "$chosen" | sed -E 's/^[󰌾󰤨 ]+//; s/  +\[(Conectada|Salva|Protegida|Aberta|Disponível)\].*//; s/ +$//')
          if [ -n "$sel_ssid" ]; then
            network_menu "$sel_ssid"
          else
            show_main_menu
          fi
          ;;
      esac
    }

    show_main_menu
