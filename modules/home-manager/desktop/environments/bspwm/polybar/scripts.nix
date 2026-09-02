{ pkgs, ... }:
{
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
      echo "󰎈 $artist - $title" | cut -c1-32
    elif [ "$status" = "Paused" ]; then
      echo "󰏤 Pausado"
    else
      echo ""
    fi
  '';

  # --- Script de Status do Bluetooth ---
  bluetoothScript = pkgs.writeShellScript "polybar-bluetooth" ''
    export PATH="${pkgs.bluez}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"
    if ! command -v bluetoothctl >/dev/null 2>&1; then
      echo "󰂲"
      exit 0
    fi

    power=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
    if [ "$power" = "yes" ]; then
      connected_dev=$(bluetoothctl info 2>/dev/null | grep "Name:" | cut -d: -f2 | sed 's/^ *//')
      if [ -n "$connected_dev" ]; then
        echo "󰂱 $connected_dev" | cut -c1-15
      else
        echo "󰂯"
      fi
    else
      echo "󰂲"
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
      echo "󰖯 $count"
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
}
