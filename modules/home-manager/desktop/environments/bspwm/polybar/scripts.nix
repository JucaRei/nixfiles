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
          *alacritty*|*kitty*|*terminal*)  icon="" ;;
          *firefox*)                        icon="󰈹" ;;
          *chrome*|*chromium*)              icon="" ;;
          *code*|*codium*)                  icon="󰨞" ;;
          *thunar*|*nemo*|*pcmanfm*)        icon="󰉋" ;;
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
      track=$(echo "$track" | cut -c1-28)
      # Formatação dinâmica em cápsula: só renderiza quando há música ativa
      echo "%{F${colors.surface0}}%{T5}%{T-}%{F-}%{B${colors.surface0}}%{F${colors.lavender}}󰎈 $track%{F-}%{B-}%{F${colors.surface0}}%{T5}%{T-}%{F-}"
      # Versão de texto simples (legado):
      # echo "󰎈 $artist - $title" | cut -c1-32
    elif [ "$status" = "Paused" ]; then
      artist=$(playerctl metadata artist 2>/dev/null)
      title=$(playerctl metadata title 2>/dev/null)
      track="$artist - $title"
      [ -z "$artist" ] && track="$title"
      track=$(echo "$track" | cut -c1-24)
      echo "%{F${colors.surface0}}%{T5}%{T-}%{F-}%{B${colors.surface0}}%{F${colors.surface2}}󰏤 $track%{F-}%{B-}%{F${colors.surface0}}%{T5}%{T-}%{F-}"
      # echo "󰏤 Pausado"
    else
      echo ""
    fi
  '';

  # --- Script de Status do Bluetooth ---
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
        echo "%{F${colors.blue}}󰂱%{F-} $connected_dev"
        # echo "󰂱 $connected_dev" | cut -c1-15
      else
        echo "%{F${colors.sapphire}}󰂯%{F-}"
        # echo "󰂯"
      fi
    else
      echo "%{F${colors.surface2}}󰂲%{F-}"
      # echo "󰂲"
    fi
  '';

  # --- Menu Interativo de Bluetooth (Rofi) ---
  rofiBluetoothMenu = pkgs.writeShellScript "rofi-bluetooth" ''
    export PATH="${pkgs.bluez}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    power=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
    if [ "$power" != "yes" ]; then
      chosen=$(echo -e "󰂯  Ativar Bluetooth" | rofi \
        -dmenu \
        -i \
        -p "Bluetooth Desativado" \
        -theme-str 'window {width: 320px; border-radius: 12px;} listview {lines: 1;}' \
        -no-custom)
      if [[ "$chosen" =~ "Ativar" ]]; then
        bluetoothctl power on
        bluetoothctl pairable on
        dunstify -a "Bluetooth" -u low -i "bluetooth-active" -r 9995 -t 1500 "Bluetooth ativado"
        exec "$0"
      fi
      exit 0
    fi

    bluetoothctl pairable on 2>/dev/null || true

    # Se chamado com argumento "--scan", faz uma busca ativa de 5 segundos
    if [ "$1" = "--scan" ]; then
      dunstify -a "Bluetooth" -u normal -i "bluetooth-active" -r 9995 "Escaneando dispositivos Bluetooth (5s)..."
      bluetoothctl --timeout 5 scan on 2>/dev/null || true
      dunstify -a "Bluetooth" -u low -i "bluetooth-active" -r 9995 -t 1500 "Busca finalizada!"
    fi

    # Monta a lista formatada de dispositivos
    dev_list=""
    while IFS= read -r line; do
      if [ -n "$line" ]; then
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        [ -z "$name" ] && name="Dispositivo sem nome"

        info=$(bluetoothctl info "$mac" 2>/dev/null)
        if echo "$info" | grep -q "Connected: yes"; then
          dev_list+="󰂱  $name  [$mac]  (Conectado)\n"
        elif echo "$info" | grep -q "Paired: yes"; then
          dev_list+="󰂯  $name  [$mac]  (Pareado)\n"
        else
          dev_list+="󰑐  $name  [$mac]  (Disponível)\n"
        fi
      fi
    done < <(bluetoothctl devices 2>/dev/null)

    header="󰂲  Desativar Bluetooth\n󰑐  Escanear novos dispositivos"
    if [ -n "$dev_list" ]; then
      menu_items="$header\n$dev_list"
    else
      menu_items="$header\n󰂲  Nenhum dispositivo encontrado (clique em Escanear)"
    fi

    chosen=$(echo -e "$menu_items" | rofi \
      -dmenu \
      -i \
      -p "Bluetooth" \
      -theme-str 'window {width: 460px; border-radius: 12px;} listview {lines: 10;}' \
      -no-custom)

    if [ -z "$chosen" ]; then
      exit 0
    fi

    if [[ "$chosen" =~ "Desativar" ]]; then
      bluetoothctl power off
      dunstify -a "Bluetooth" -u low -i "bluetooth-disabled" -r 9995 -t 1500 "Bluetooth desativado"
    elif [[ "$chosen" =~ "Escanear" ]]; then
      exec "$0" --scan
    elif [[ "$chosen" =~ \[([0-9A-Fa-f:]{17})\] ]]; then
      mac="''${BASH_REMATCH[1]}"
      name=$(echo "$chosen" | sed -E 's/^[󰂱󰂯󰑐 ]+//;s/  \[.*//')

      if [[ "$chosen" =~ "\(Conectado\)" ]]; then
        # Desconectar
        dunstify -a "Bluetooth" -u low -i "bluetooth-active" -r 9995 "Desconectando $name..."
        bluetoothctl disconnect "$mac"
        dunstify -a "Bluetooth" -u normal -i "bluetooth-active" -r 9995 "$name desconectado"
      else
        # Parear, Confiar e Conectar
        dunstify -a "Bluetooth" -u normal -i "bluetooth-active" -r 9995 "Pareando e conectando a $name..."
        bluetoothctl pair "$mac" 2>/dev/null || true
        bluetoothctl trust "$mac" 2>/dev/null || true
        if bluetoothctl connect "$mac"; then
          dunstify -a "Bluetooth" -u normal -i "bluetooth-active" -r 9995 -t 3000 "$name conectado com sucesso!"
        else
          dunstify -a "Bluetooth" -u critical -i "bluetooth-disabled" -r 9995 "Falha ao conectar a $name"
        fi
      fi
    fi
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
      # Cápsula renderizada dinamicamente apenas quando há janelas ocultas
      echo "%{F${colors.surface0}}%{T5}%{T-}%{F-}%{B${colors.surface0}}%{F${colors.peach}}󰖯 $count%{F-}%{B-}%{F${colors.surface0}}%{T5}%{T-}%{F-}"
      # echo "󰖯 $count" # Versão de texto simples sem cápsula embutida
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
