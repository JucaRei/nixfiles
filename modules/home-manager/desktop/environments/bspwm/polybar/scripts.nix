{ pkgs, ... }:
{
  # --- Script de Controle de Mídia (Playerctl) ---
  mediaScript = pkgs.writeShellScript "polybar-media" ''
    export PATH="${pkgs.playerctl}/bin:${pkgs.coreutils}/bin:$PATH"
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
    export PATH="${pkgs.bluez}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.coreutils}/bin:$PATH"
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
    export PATH="${pkgs.bluez}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.coreutils}/bin:$PATH"
    
    power=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
    if [ "$power" = "yes" ]; then
      toggle_text="󰂲  Desativar Bluetooth"
    else
      toggle_text="󰂯  Ativar Bluetooth"
    fi

    devices=$(bluetoothctl devices 2>/dev/null | awk '{$1=""; $2=""; print "󰂱 " $0}' | sed 's/^[ \t]*//')

    chosen=$(echo -e "$toggle_text\n󰑐  Buscar novos dispositivos\n$devices" | rofi \
      -dmenu \
      -i \
      -p "Bluetooth" \
      -theme-str 'window {width: 340px; border-radius: 12px;} listview {lines: 8;}' \
      -no-custom)

    if [ -z "$chosen" ]; then
      exit 0
    fi

    if [[ "$chosen" =~ "Desativar" ]]; then
      bluetoothctl power off
      dunstify -a "Bluetooth" -u low -i "bluetooth-disabled" -r 9995 -t 1500 "Bluetooth desativado"
    elif [[ "$chosen" =~ "Ativar" ]]; then
      bluetoothctl power on
      dunstify -a "Bluetooth" -u low -i "bluetooth-active" -r 9995 -t 1500 "Bluetooth ativado"
    elif [[ "$chosen" =~ "Buscar" ]]; then
      bluetoothctl scan on &
      dunstify -a "Bluetooth" -u normal -i "bluetooth-active" -r 9995 "Buscando dispositivos Bluetooth..."
    elif [[ "$chosen" =~ "󰂱" ]]; then
      dev_name=$(echo "$chosen" | sed 's/󰂱 //')
      dev_mac=$(bluetoothctl devices | grep -F "$dev_name" | awk '{print $2}')
      if [ -n "$dev_mac" ]; then
        dunstify -a "Bluetooth" -u low -i "bluetooth-active" -r 9995 "Conectando a $dev_name..."
        bluetoothctl connect "$dev_mac"
      fi
    fi
  '';

  # --- Menu Interativo de Wi-Fi (Rofi) ---
  rofiWifiMenu = pkgs.writeShellScript "rofi-wifi-menu" ''
    export PATH="${pkgs.networkmanager}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.gnugrep}/bin:${pkgs.coreutils}/bin:$PATH"

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
    export PATH="${pkgs.rofi}/bin:${pkgs.systemd}/bin:${pkgs.bspwm}/bin:${pkgs.coreutils}/bin:$PATH"

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
}
