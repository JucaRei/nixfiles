#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if ! command -v bluetoothctl >/dev/null 2>&1; then
      echo "%{F${COLOR_SURFACE2:-}}󰂲%{F-}"
      exit 0
    fi

    get_device_icon() {
      local icon_class="${1:-}"
      local class_hex="${2:-}"
      local uuids="${3:-}"
      local dev_name="${4:-}"
      local dev_name_lower="${dev_name,,}"

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
        *headphone*|*fone*|*buds*|*airpod*|*freebud*|*soundcore*|*space*travel*|*moondrop*|*wh-*|*wf-*|*tune*|*live*|*earphone*|*earbuds*)
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

    format_batt() {
      local b="$1"
      [ -z "$b" ] && return
      local b_color="${COLOR_GREEN:-}"
      local b_icon="󰁹"
      if [ "$b" -le 20 ] 2>/dev/null; then
        b_color="${COLOR_RED:-}"
        b_icon="󰂃"
      elif [ "$b" -le 40 ] 2>/dev/null; then
        b_color="${COLOR_YELLOW:-}"
        b_icon="󰁼"
      elif [ "$b" -le 70 ] 2>/dev/null; then
        b_color="${COLOR_YELLOW:-}"
        b_icon="󰁾"
      fi
      echo "%{F$b_color}$b_icon $b%%{F-}"
    }

    power=$(bluetoothctl show 2>/dev/null | grep -i "Powered:" | awk '{print $2}')
    if [ "$power" = "yes" ]; then
      seen_macs=()
      conn_macs=()
      conn_names=()
      conn_icons=()
      conn_batts=()

      # Busca dispositivos conectados iterando sobre os dispositivos conhecidos pelo BlueZ
      while IFS= read -r dev_line; do
        [ -z "$dev_line" ] && continue
        echo "$dev_line" | grep -q "^Device " || continue
        pmac=$(echo "$dev_line" | awk '{print $2}')
        [[ "$pmac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || continue

        for sm in "${seen_macs[@]}"; do
          [ "$sm" = "$pmac" ] && continue 2
        done
        seen_macs+=("$pmac")

        pinfo=$(bluetoothctl info "$pmac" 2>/dev/null)
        if echo "$pinfo" | grep -q "Connected: yes"; then
          pname=$(echo "$pinfo" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          if [ -z "$pname" ]; then
            pname=$(echo "$pinfo" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          fi
          if [ -z "$pname" ]; then
            pname=$(echo "$dev_line" | cut -d' ' -f3-)
          fi
          [ -z "$pname" ] && pname="Dispositivo"

          icon_class=$(echo "$pinfo" | grep -i "Icon:" | awk '{print $2}')
          class_hex=$(echo "$pinfo" | grep -i "Class:" | awk '{print $2}')
          uuids=$(echo "$pinfo" | grep -i "UUID:")
          dev_icon=$(get_device_icon "$icon_class" "$class_hex" "$uuids" "$pname")

          batt_val=""
          if [[ "$pinfo" =~ [Bb]attery.*\(+([0-9]+)\)+ ]]; then
            batt_val="${BASH_REMATCH[1]}"
          elif [[ "$pinfo" =~ [Bb]attery[^:]*:[[:space:]]*0x([0-9a-fA-F]+) ]]; then
            batt_val=$(( 16#${BASH_REMATCH[1]} ))
          elif [[ "$pinfo" =~ [Bb]attery[^:]*:[[:space:]]*([0-9]+)%? ]]; then
            batt_val="${BASH_REMATCH[1]}"
          fi

          # Fallback para sysfs (/sys/class/power_supply) caso não venha no bluetoothctl info
          if [ -z "$batt_val" ] && [ -d /sys/class/power_supply ]; then
            mac_clean="${pmac//:/_}"
            mac_clean_lower="${mac_clean,,}"
            for pdir in /sys/class/power_supply/*"$mac_clean"* /sys/class/power_supply/*"$mac_clean_lower"*; do
              if [ -f "$pdir/capacity" ]; then
                batt_val=$(cat "$pdir/capacity" 2>/dev/null || true)
                [ -n "$batt_val" ] && break
              fi
            done
          fi

          if [ -n "$batt_val" ]; then
            if ! [[ "$batt_val" =~ ^[0-9]+$ ]] || [ "$batt_val" -gt 100 ]; then
              batt_val=""
            fi
          fi

          conn_macs+=("$pmac")
          conn_names+=("$pname")
          conn_icons+=("$dev_icon")
          conn_batts+=("$batt_val")
        fi
      done < <(bluetoothctl paired-devices 2>/dev/null; bluetoothctl devices 2>/dev/null)

      num_conn="${#conn_macs[@]}"
      if [ "$num_conn" -eq 0 ]; then
        echo "%{F${COLOR_SAPPHIRE:-}}󰂯%{F-}"
      elif [ "$num_conn" -eq 1 ]; then
        icon="${conn_icons[0]}"
        name="${conn_names[0]}"
        short_name=$(echo "$name" | cut -c1-14)
        batt="${conn_batts[0]}"
        batt_str=$(format_batt "$batt")
        if [ -n "$batt_str" ]; then
          echo "%{F${COLOR_BLUE:-}}$icon%{F-} $short_name  $batt_str"
        else
          echo "%{F${COLOR_BLUE:-}}$icon%{F-} $short_name"
        fi
      else
        icons_str=""
        main_idx=0
        for i in "${!conn_icons[@]}"; do
          ic="${conn_icons[$i]}"
          icons_str="$icons_str%{F${COLOR_BLUE:-}}$ic%{F-} "
          if [ "$ic" = "󰥰" ] || [ "$ic" = "󰋋" ] || [ "$ic" = "󰓃" ]; then
            main_idx=$i
          fi
        done
        main_name=$(echo "${conn_names[$main_idx]}" | cut -c1-12)
        main_batt="${conn_batts[$main_idx]}"
        batt_str=$(format_batt "$main_batt")
        if [ -n "$batt_str" ]; then
          echo "$icons_str$main_name  $batt_str"
        else
          echo "$icons_str$main_name"
        fi
      fi
    else
      echo "%{F${COLOR_SURFACE2:-}}󰂲%{F-}"
    fi
