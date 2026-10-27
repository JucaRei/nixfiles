#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2016,SC2028,SC2034,SC2046,SC2059,SC2076,SC2086,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

NMCLI="/usr/bin/nmcli"
    if ! command -v "$NMCLI" >/dev/null 2>&1; then
      NMCLI=$(command -v nmcli 2>/dev/null || true)
    fi
    if [ -z "$NMCLI" ]; then
      notify-send -u critical "WiFi" "nmcli não encontrado. Instale o NetworkManager."
      exit 1
    fi

    connected=$($NMCLI -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    wifi_status=$($NMCLI radio wifi)

    if [ "$wifi_status" = "disabled" ]; then
      action=$(printf "󰤮 WiFi Desligado\n󰖩 Ligar WiFi" | rofi -dmenu -p " 󰤮 WiFi " -theme-str 'window {width: 360px; height: 200px;} listview {lines: 2;}')
      case "$action" in
        *"Ligar WiFi") $NMCLI radio wifi on; notify-send -u low "WiFi" "Rádio WiFi ligado!" ;;
      esac
      exit 0
    fi

    $NMCLI dev wifi rescan 2>/dev/null || true
    sleep 1

    networks=$($NMCLI -t -f SSID,SIGNAL,SECURITY dev wifi list | grep -v '^$' | sort -t: -k2 -rn | head -15)
    menu=""
    if [ -n "$connected" ]; then
      menu="󰤨 Conectado: $connected\n󰤭 Desconectar\n"
    fi
    menu="$menu󰤯 Desligar WiFi\n─────────────\n"

    while IFS=: read -r ssid signal security; do
      [ -z "$ssid" ] && continue
      if [ "$signal" -ge 75 ]; then icon="󰤨";
      elif [ "$signal" -ge 50 ]; then icon="󰤥";
      elif [ "$signal" -ge 25 ]; then icon="󰤢";
      else icon="󰤟"; fi
      lock=""; [ -n "$security" ] && [ "$security" != "--" ] && lock=" 󰌾"
      menu="$menu$icon $ssid ($signal%)$lock\n"
    done <<< "$networks"

    chosen=$(printf "$menu" | rofi -dmenu -p " 󰤨 WiFi " -theme-str 'window {width: 750px; height: 480px;} listview {columns: 1; lines: 12;}')
    [ -z "$chosen" ] && exit 0

    case "$chosen" in
      *"Desconectar")
        $NMCLI dev disconnect iface wlp2s0b1 2>/dev/null || $NMCLI con down id "$connected" 2>/dev/null
        notify-send -u low "WiFi" "Desconectado de $connected"
        ;;
      *"Desligar WiFi")
        $NMCLI radio wifi off
        notify-send -u low "WiFi" "Rádio WiFi desligado"
        ;;
      *"Conectado"*) ;;
      *"─────"*) ;;
      *)
        ssid=$(echo "$chosen" | sed 's/^[^ ]* //' | sed 's/ ([0-9]*%).*$//')
        if $NMCLI -t -f NAME con show | grep -qx "$ssid"; then
          $NMCLI con up id "$ssid" 2>/dev/null
        else
          pass=$(rofi -dmenu -p " 󰌾 Senha WiFi: $ssid " -password -theme-str 'window {width: 580px; height: 100px;} listview {lines: 0;}')
          if [ -n "$pass" ]; then
            $NMCLI dev wifi connect "$ssid" password "$pass" 2>/dev/null
          fi
        fi
        ;;
    esac
