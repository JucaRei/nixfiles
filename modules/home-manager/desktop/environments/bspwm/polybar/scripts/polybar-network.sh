#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

# 1. Verifica se há conexão cabeada (Ethernet) ativa
    eth_conn=$(nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | grep "^ethernet:connected:" | head -n1)
    if [ -n "$eth_conn" ]; then
      con_name=$(echo "$eth_conn" | cut -d: -f3 | cut -c1-14)
      [ -z "$con_name" ] && con_name="Ethernet"
      echo "%{F${COLOR_TEAL:-}}󰈀%{F-} $con_name"
      # echo "%{F${COLOR_TEAL:-}}󰈀%{F-} $con_name" # sem corte de caracteres
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

      echo "%{F${COLOR_TEAL:-}}$icon%{F-} $ssid"
      exit 0
    fi

    # 3. Verifica se o rádio Wi-Fi está desativado
    wifi_radio=$(nmcli radio wifi 2>/dev/null)
    if [ "$wifi_radio" = "disabled" ]; then
      echo "%{F${COLOR_SURFACE2:-}}󰤮%{F-} %{F${COLOR_SURFACE2:-}}Desativado%{F-}"
      exit 0
    fi

    # 4. Desconectado / Offline
    echo "%{F${COLOR_RED:-}}󰤮%{F-} %{F${COLOR_SUBTEXT0:-}}Offline%{F-}"
