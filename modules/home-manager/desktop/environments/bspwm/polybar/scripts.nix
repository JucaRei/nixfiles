{
  pkgs,
  colors,
  lib ? pkgs.lib,
  polybar ? (pkgs.polybar.override { pulseSupport = true; i3Support = false; }),
  ...
}:
rec {
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
  # --- Script de Controle de Mídia Interativo (Playerctl com OSD) ---
  mediaControlScript = pkgs.writeShellScript "polybar-media-control" ''
    export PATH="${lib.makeBinPath [ pkgs.playerctl pkgs.dunst pkgs.coreutils ]}:$PATH"

    action="''${1:-play-pause}"
    case "$action" in
      play-pause|toggle) playerctl play-pause 2>/dev/null ;;
      next)              playerctl next 2>/dev/null ;;
      prev|previous)      playerctl previous 2>/dev/null ;;
      stop)              playerctl stop 2>/dev/null ;;
    esac

    sleep 0.1
    status=$(playerctl status 2>/dev/null || echo "Parado")
    track_info=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null || true)

    case "$status" in
      Playing) icon="media-playback-start"; header="󰐊 Reproduzindo" ;;
      Paused)  icon="media-playback-pause"; header="󰏤 Pausado" ;;
      *)       icon="media-playback-stop";  header="󰓛 Reprodutor Parado" ;;
    esac

    if [ -n "$track_info" ] && [ "$track_info" != " - " ]; then
      dunstify -a "Mídia" \
        -u low \
        -i "$icon" \
        -h string:x-dunst-stack-tag:media \
        -t 1500 \
        "$header" \
        "<b>$track_info</b>" 2>/dev/null || true
    fi
  '';

  # --- Script de Visualização de Mídia com Botões Interativos (Playerctl) ---
  mediaScript = pkgs.writeShellScript "polybar-media" ''
    export PATH="${lib.makeBinPath [ pkgs.playerctl pkgs.coreutils pkgs.gnused ]}:$PATH"
    if ! command -v playerctl >/dev/null 2>&1; then
      exit 0
    fi

    status=$(playerctl status 2>/dev/null || echo "")
    [ -z "$status" ] && exit 0

    title=$(playerctl metadata title 2>/dev/null || echo "")
    artist=$(playerctl metadata artist 2>/dev/null || echo "")

    if [ -n "$artist" ] && [ -n "$title" ]; then
      track="$artist - $title"
    elif [ -n "$title" ]; then
      track="$title"
    else
      track="Mídia"
    fi

    display_track=$(echo "$track" | cut -c1-35)
    [ "''${#track}" -gt 35 ] && display_track="''${display_track}..."

    btn_prev="%{A1:${mediaControlScript} prev:}%{F${colors.blue}}󰒮%{F-}%{A}"
    btn_next="%{A1:${mediaControlScript} next:}%{F${colors.blue}}󰒭%{F-}%{A}"
    btn_stop="%{A1:${mediaControlScript} stop:}%{F${colors.red}}󰓛%{F-}%{A}"

    if [ "$status" = "Playing" ]; then
      btn_play_pause="%{A1:${mediaControlScript} play-pause:}%{F${colors.green}}󰏤%{F-}%{A}"
      track_label="%{A1:${mediaControlScript} play-pause:}%{F${colors.mauve}}󰎈%{F-} %{F${colors.text}}$display_track%{F-}%{A}"
      echo "$btn_prev  $btn_play_pause  $btn_next  $btn_stop  %{F${colors.surface1}}│%{F-}  $track_label"
    elif [ "$status" = "Paused" ]; then
      btn_play_pause="%{A1:${mediaControlScript} play-pause:}%{F${colors.peach}}󰐊%{F-}%{A}"
      track_label="%{A1:${mediaControlScript} play-pause:}%{F${colors.surface2}}󰎊 $display_track%{F-}%{A}"
      echo "$btn_prev  $btn_play_pause  $btn_next  $btn_stop  %{F${colors.surface1}}│%{F-}  $track_label"
    else
      echo ""
    fi
  '';

  # --- Função Auxiliar Bash para Detecção de Ícones Bluetooth (Nerd Fonts) ---
  btDeviceIconFn = ''
    get_device_icon() {
      local icon_class="''${1:-}"
      local class_hex="''${2:-}"
      local uuids="''${3:-}"
      local dev_name="''${4:-}"
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
  '';

  # --- Script de Status do Bluetooth com Detecção de Dispositivos e Bateria ---
  bluetoothScript = pkgs.writeShellScript "polybar-bluetooth" ''
    export PATH="/usr/bin:/usr/sbin:${pkgs.bluez}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"
    if ! command -v bluetoothctl >/dev/null 2>&1; then
      echo "%{F${colors.surface2}}󰂲%{F-}"
      exit 0
    fi

    ${btDeviceIconFn}

    format_batt() {
      local b="$1"
      [ -z "$b" ] && return
      local b_color="${colors.green}"
      local b_icon="󰁹"
      if [ "$b" -le 20 ] 2>/dev/null; then
        b_color="${colors.red}"
        b_icon="󰂃"
      elif [ "$b" -le 40 ] 2>/dev/null; then
        b_color="${colors.yellow}"
        b_icon="󰁼"
      elif [ "$b" -le 70 ] 2>/dev/null; then
        b_color="${colors.yellow}"
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

        for sm in "''${seen_macs[@]}"; do
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

          batt_val=$(echo "$pinfo" | grep -i "Battery Percentage" | sed -E 's/.*\(([0-9]+)\).*/\1/; s/.*:[[:space:]]*([0-9]+).*/\1/' | tr -dc '0-9')
          [ -n "$batt_val" ] && [ "$batt_val" -gt 100 ] 2>/dev/null && batt_val=""

          conn_macs+=("$pmac")
          conn_names+=("$pname")
          conn_icons+=("$dev_icon")
          conn_batts+=("$batt_val")
        fi
      done < <(bluetoothctl paired-devices 2>/dev/null; bluetoothctl devices 2>/dev/null)

      num_conn="''${#conn_macs[@]}"
      if [ "$num_conn" -eq 0 ]; then
        echo "%{F${colors.sapphire}}󰂯%{F-}"
      elif [ "$num_conn" -eq 1 ]; then
        icon="''${conn_icons[0]}"
        name="''${conn_names[0]}"
        short_name=$(echo "$name" | cut -c1-14)
        batt="''${conn_batts[0]}"
        batt_str=$(format_batt "$batt")
        if [ -n "$batt_str" ]; then
          echo "%{F${colors.blue}}$icon%{F-} $short_name  $batt_str"
        else
          echo "%{F${colors.blue}}$icon%{F-} $short_name"
        fi
      else
        icons_str=""
        main_idx=0
        for i in "''${!conn_icons[@]}"; do
          ic="''${conn_icons[$i]}"
          icons_str="$icons_str%{F${colors.blue}}$ic%{F-} "
          if [ "$ic" = "󰥰" ] || [ "$ic" = "󰋋" ] || [ "$ic" = "󰓃" ]; then
            main_idx=$i
          fi
        done
        main_name=$(echo "''${conn_names[$main_idx]}" | cut -c1-12)
        main_batt="''${conn_batts[$main_idx]}"
        batt_str=$(format_batt "$main_batt")
        if [ -n "$batt_str" ]; then
          echo "$icons_str$main_name  $batt_str"
        else
          echo "$icons_str$main_name"
        fi
      fi
    else
      echo "%{F${colors.surface2}}󰂲%{F-}"
    fi
  '';

  # --- Script de Áudio Dinâmico com Detecção de Saída (Fones, Caixas, HDMI, Bluetooth) ---
  audioScript = pkgs.writeShellScript "polybar-audio" ''
    export PATH="/usr/bin:/usr/sbin:${lib.makeBinPath [ pkgs.pulseaudio pkgs.pamixer pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.gawk ]}:$PATH"

    get_audio_info() {
      local vol=""
      local is_muted="false"

      if command -v pamixer >/dev/null 2>&1; then
        vol=$(pamixer --get-volume 2>/dev/null)
        is_muted=$(pamixer --get-mute 2>/dev/null || echo "false")
      fi

      if [ -z "$vol" ] && command -v pactl >/dev/null 2>&1; then
        vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o -E '[0-9]+%' | head -n1 | tr -d '%')
        pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -qi "yes" && is_muted="true"
      fi

      [ -z "$vol" ] && vol="0"

      local dev_type="speaker"
      if command -v pactl >/dev/null 2>&1; then
        local default_sink
        default_sink=$(pactl get-default-sink 2>/dev/null)
        [ -z "$default_sink" ] && default_sink=$(pactl info 2>/dev/null | grep "Default Sink:" | cut -d: -f2- | xargs)

        local sink_info
        sink_info=$(pactl list sinks 2>/dev/null | awk -v sink="$default_sink" '
          $1 == "Sink" { in_sink=0 }
          $1 == "Name:" && $2 == sink { in_sink=1 }
          in_sink { print }
        ')
        [ -z "$sink_info" ] && sink_info=$(pactl list sinks 2>/dev/null)

        local active_port
        active_port=$(echo "$sink_info" | grep -E '^[[:space:]]*Active Port:' | head -n1 | cut -d: -f2- | tr '[:upper:]' '[:lower:]' | xargs)

        local form_factor
        form_factor=$(echo "$sink_info" | grep -E 'device.form_factor' | head -n1 | cut -d= -f2- | tr -d ' "' | tr '[:upper:]' '[:lower:]' | xargs)

        local bus
        bus=$(echo "$sink_info" | grep -E 'device.bus' | head -n1 | cut -d= -f2- | tr -d ' "' | tr '[:upper:]' '[:lower:]' | xargs)

        local desc
        desc=$(echo "$sink_info" | grep -E '^[[:space:]]*Description:' | head -n1 | cut -d: -f2- | xargs)
        local desc_lower
        desc_lower=$(echo "$desc" | tr '[:upper:]' '[:lower:]')

        if [ "$bus" = "bluetooth" ] || [[ "$default_sink" =~ bluez_sink|bluez_output ]]; then
          dev_type="bluetooth"
        elif [[ "$active_port" =~ hdmi|displayport ]] || [[ "$default_sink" =~ hdmi ]] || [[ "$desc_lower" =~ hdmi|displayport ]]; then
          dev_type="hdmi"
        elif [[ "$active_port" =~ headset ]] || [ "$form_factor" = "headset" ] || [[ "$desc_lower" =~ headset ]]; then
          dev_type="headset"
        elif [[ "$active_port" =~ headphone ]] || [ "$form_factor" = "headphone" ] || [[ "$desc_lower" =~ headphone|fone|earphone|earbuds|buds|airpod ]]; then
          dev_type="headphone"
        elif [ "$bus" = "usb" ]; then
          dev_type="usb"
        else
          dev_type="speaker"
        fi
      fi

      if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
        echo "%{F${colors.red}}󰝟%{F-} %{F${colors.subtext0}}0%%{F-}"
        return
      fi

      local icon="󰕾"
      local icon_color="${colors.blue}"

      case "$dev_type" in
        headphone)
          icon="󰋋"
          icon_color="${colors.sapphire}"
          ;;
        headset)
          icon="󰋎"
          icon_color="${colors.sapphire}"
          ;;
        bluetooth)
          icon="󰂰"
          icon_color="${colors.lavender}"
          ;;
        hdmi)
          icon="󰡁"
          icon_color="${colors.sky}"
          ;;
        usb)
          icon="󰟵"
          icon_color="${colors.teal}"
          ;;
        speaker|*)
          if [ "$vol" -lt 30 ]; then
            icon="󰕿"
          elif [ "$vol" -lt 70 ]; then
            icon="󰖀"
          else
            icon="󰕾"
          fi
          icon_color="${colors.blue}"
          ;;
      esac

      echo "%{F$icon_color}$icon%{F-} %{F${colors.text}}$vol%%{F-}"
    }

    get_audio_info

    while true; do
      if command -v pactl >/dev/null 2>&1; then
        pactl subscribe 2>/dev/null | grep --line-buffered -E "('change'|'remove'|'new') on (sink|server)" | while read -r _; do
          get_audio_info
        done
      fi
      sleep 2
      get_audio_info
    done
  '';

  # --- Script de Controle de Áudio (Volume, Mute e Troca Cíclica de Saída) ---
  audioControlScript = pkgs.writeShellScript "polybar-audio-control" ''
    export PATH="/usr/bin:/usr/sbin:${lib.makeBinPath [ pkgs.pulseaudio pkgs.pamixer pkgs.dunst pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.gawk ]}:$PATH"

    action="''${1:-}"

    notify_vol() {
      local vol
      vol=$(pamixer --get-volume 2>/dev/null || echo "0")
      local is_muted
      is_muted=$(pamixer --get-mute 2>/dev/null || echo "false")
      local icon="audio-volume-medium"
      local text="Volume: $vol%"
      local bar_val="$vol"

      if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
        icon="audio-volume-muted"
        text="Volume: Mudo"
        bar_val=0
      elif [ "$vol" -lt 30 ]; then
        icon="audio-volume-low"
      elif [ "$vol" -gt 70 ]; then
        icon="audio-volume-high"
      fi

      if command -v dunstify >/dev/null 2>&1; then
        dunstify -a "OSD" -u low -i "$icon" -h string:x-dunst-stack-tag:volume -h int:value:"$bar_val" -t 1200 "$text"
      fi
    }

    case "$action" in
      volume-up)
        pamixer -i 2 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ +2% 2>/dev/null || true
        notify_vol
        ;;
      volume-down)
        pamixer -d 2 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ -2% 2>/dev/null || true
        notify_vol
        ;;
      toggle-mute)
        pamixer -t 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null || true
        notify_vol
        ;;
      next-sink)
        if command -v pactl >/dev/null 2>&1; then
          sinks=($(pactl list short sinks 2>/dev/null | awk '{print $2}'))
          if [ "''${#sinks[@]}" -gt 1 ]; then
            current=$(pactl get-default-sink 2>/dev/null)
            next_sink=""
            for i in "''${!sinks[@]}"; do
              if [ "''${sinks[$i]}" = "$current" ]; then
                next_idx=$(( (i + 1) % ''${#sinks[@]} ))
                next_sink="''${sinks[$next_idx]}"
                break
              fi
            done
            [ -z "$next_sink" ] && next_sink="''${sinks[0]}"
            pactl set-default-sink "$next_sink" 2>/dev/null
            for input in $(pactl list short sink-inputs 2>/dev/null | awk '{print $1}'); do
              pactl move-sink-input "$input" "$next_sink" 2>/dev/null || true
            done
            desc=$(pactl list sinks 2>/dev/null | awk -v s="$next_sink" '
              $1 == "Name:" && $2 == s { f=1 }
              f && /Description:/ { sub(/^[[:space:]]*Description:[[:space:]]*/, ""); print; exit }
            ')
            [ -z "$desc" ] && desc="$next_sink"
            if command -v dunstify >/dev/null 2>&1; then
              dunstify -a "Áudio" -u low -i "audio-card" -h string:x-dunst-stack-tag:audio-sink -t 2000 "Saída de Áudio" "$desc"
            fi
          fi
        fi
        ;;
    esac
  '';

  # --- Menu Interativo de Bluetooth Avançado (Rofi - Inspirado no gh0stzk/dotfiles e nickclyde) ---
  rofiBluetoothMenu = pkgs.writeShellScript "rofi-bluetooth" ''
    export PATH="/usr/bin:/usr/sbin:${pkgs.bluez}/bin:${pkgs.blueman}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.util-linux}/bin:${pkgs.procps}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    ${btDeviceIconFn}

    notify_bt() {
      local urgency="$1"
      local icon="$2"
      local title="$3"
      local msg="$4"
      ${pkgs.dunst}/bin/dunstify -a "Bluetooth" -u "$urgency" -i "$icon" -h string:x-dunst-stack-tag:bluetooth-osd -t 3000 "$title" "$msg"
    }

    power_on() {
      bluetoothctl show 2>/dev/null | grep -i "Powered:" | grep -q "yes"
    }

    toggle_power() {
      local from_cli="''${1:-}"
      if power_on; then
        # 1. Parar qualquer escaneamento em andamento
        pkill -f "bluetoothctl.*scan" >/dev/null 2>&1 || true

        # 2. Desligar o controlador via pipe e direto
        local ctrl
        ctrl=$(bluetoothctl list 2>/dev/null | head -n1 | awk '{print $2}')
        if [ -n "$ctrl" ]; then
          printf "select %s\npower off\nquit\n" "$ctrl" | bluetoothctl >/dev/null 2>&1 || true
        fi
        bluetoothctl power off >/dev/null 2>&1 || true

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
          ctrl=$(bluetoothctl list 2>/dev/null | head -n1 | awk '{print $2}')
          [ -n "$ctrl" ] && break
          sleep 0.2
          k=$((k + 1))
        done

        # 3. Ligar controlador
        if [ -n "$ctrl" ]; then
          printf "select %s\npower on\nquit\n" "$ctrl" | bluetoothctl >/dev/null 2>&1 || true
        fi
        bluetoothctl power on >/dev/null 2>&1 || true

        # 4. Aguardar o controlador efetivamente ligar
        local i=0
        while ! power_on && [ "$i" -lt 20 ]; do
          if [ $((i % 3)) -eq 0 ]; then
            if [ -n "$ctrl" ]; then
              printf "select %s\npower on\nquit\n" "$ctrl" | bluetoothctl >/dev/null 2>&1 || true
            else
              bluetoothctl power on >/dev/null 2>&1 || true
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
      bluetoothctl show 2>/dev/null | grep -i "Discovering:" | grep -q "yes"
    }

    toggle_scan() {
      if scan_on; then
        pkill -f "bluetoothctl.*scan" >/dev/null 2>&1 || true
        bluetoothctl scan off >/dev/null 2>&1 || true
        sleep 0.2
        notify_bt "low" "bluetooth-active" "Escaneamento Parado" "Busca por dispositivos interrompida."
      else
        notify_bt "normal" "bluetooth-active" "Buscando Dispositivos..." "Varredura ativa em segundo plano."
        bluetoothctl scan on >/dev/null 2>&1 &
        sleep 1.2
      fi
      show_menu
    }

    pairable_on() {
      bluetoothctl show 2>/dev/null | grep -i "Pairable:" | grep -q "yes"
    }

    toggle_pairable() {
      if pairable_on; then
        bluetoothctl pairable off >/dev/null 2>&1 || true
        notify_bt "low" "bluetooth-active" "Modo Pareável" "Desativado."
      else
        bluetoothctl pairable on >/dev/null 2>&1 || true
        notify_bt "normal" "bluetooth-active" "Modo Pareável" "Ativado. Outros dispositivos podem parear."
      fi
      sleep 0.2
      show_menu
    }

    discoverable_on() {
      bluetoothctl show 2>/dev/null | grep -i "Discoverable:" | grep -q "yes"
    }

    toggle_discoverable() {
      if discoverable_on; then
        bluetoothctl discoverable off >/dev/null 2>&1 || true
        notify_bt "low" "bluetooth-active" "Visibilidade" "Oculto para novos aparelhos."
      else
        bluetoothctl discoverable on >/dev/null 2>&1 || true
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
      info=$(bluetoothctl info "$mac" 2>/dev/null)

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

      local batt_val
      batt_val=$(echo "$info" | grep -i "Battery Percentage" | sed -E 's/.*\(([0-9]+)\).*/\1/; s/.*:[[:space:]]*([0-9]+).*/\1/' | tr -dc '0-9')
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
        "$OPT_BACK" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "$PROMPT_TEXT" \
        -theme-str 'window {width: 850px; border-radius: 14px;} listview {columns: 1; lines: 6;}' -no-custom)

      case "$CHOICE" in
        *"Desconectar"*)
          notify_bt "low" "bluetooth-active" "Desconectando..." "Desconectando $name..."
          bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
          printf "disconnect %s\nquit\n" "$mac" | bluetoothctl >/dev/null 2>&1 || true
          local i=0
          while bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" && [ "$i" -lt 15 ]; do
            sleep 0.1
            i=$((i + 1))
          done
          notify_bt "normal" "bluetooth-active" "Desconectado" "$name foi desconectado."
          show_menu
          ;;
        *"Conectar"*)
          notify_bt "normal" "bluetooth-active" "Conectando..." "Tentando conectar a $name..."
          bluetoothctl trust "$mac" >/dev/null 2>&1 || true
          if [ "$is_paired" != "Sim" ]; then
            bluetoothctl pair "$mac" >/dev/null 2>&1 || true
            sleep 0.4
          fi
          printf "trust %s\nconnect %s\nquit\n" "$mac" "$mac" | bluetoothctl >/dev/null 2>&1 || true
          bluetoothctl connect "$mac" >/dev/null 2>&1 || true
          local i=0
          while ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" && [ "$i" -lt 20 ]; do
            sleep 0.1
            i=$((i + 1))
          done
          if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            notify_bt "normal" "bluetooth-active" "Conectado!" "$name conectado com sucesso."
          else
            notify_bt "critical" "bluetooth-disabled" "Erro de Conexão" "Falha ao conectar a $name. Se necessário, abra o Blueman."
          fi
          show_menu
          ;;
        *"Desparear"*)
          notify_bt "low" "bluetooth-active" "Despareando..." "Desconectando e despareando $name..."
          bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
          sleep 0.2
          bluetoothctl untrust "$mac" >/dev/null 2>&1 || true
          bluetoothctl remove "$mac" >/dev/null 2>&1 || true
          sleep 0.4
          notify_bt "normal" "bluetooth-disabled" "Dispositivo Despareado" "$name foi despareado com sucesso."
          show_menu
          ;;
        *"Remover"*|*"Esquecer"*)
          notify_bt "low" "bluetooth-active" "Removendo..." "Desconectando e esquecendo $name..."
          bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
          local i=0
          while bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" && [ "$i" -lt 15 ]; do
            sleep 0.1
            i=$((i + 1))
          done
          bluetoothctl untrust "$mac" >/dev/null 2>&1 || true
          bluetoothctl remove "$mac" >/dev/null 2>&1 || true
          printf "disconnect %s\nuntrust %s\nremove %s\nquit\n" "$mac" "$mac" "$mac" | bluetoothctl >/dev/null 2>&1 || true
          sleep 0.5
          notify_bt "normal" "bluetooth-disabled" "Dispositivo Removido" "$name foi esquecido com sucesso."
          show_menu
          ;;
        *"Parear"*)
          notify_bt "normal" "bluetooth-active" "Pareando..." "Pareando com $name..."
          bluetoothctl pair "$mac" >/dev/null 2>&1 || true
          bluetoothctl trust "$mac" >/dev/null 2>&1 || true
          printf "pair %s\ntrust %s\nconnect %s\nquit\n" "$mac" "$mac" | bluetoothctl >/dev/null 2>&1 || true
          sleep 0.5
          notify_bt "normal" "bluetooth-active" "Pareado!" "$name pareado com sucesso."
          show_menu
          ;;
        *"Remover Confiança"*)
          bluetoothctl untrust "$mac" >/dev/null 2>&1 || true
          notify_bt "low" "bluetooth-active" "Não Confiável" "Confiança removida de $name."
          sleep 0.2
          device_menu "$mac" "$name"
          ;;
        *"Confiar"*)
          bluetoothctl trust "$mac" >/dev/null 2>&1 || true
          notify_bt "normal" "bluetooth-active" "Confiável" "$name marcado como confiável."
          sleep 0.2
          device_menu "$mac" "$name"
          ;;
        *"Desbloquear"*)
          bluetoothctl unblock "$mac" >/dev/null 2>&1 || true
          notify_bt "normal" "bluetooth-active" "Desbloqueado" "$name foi desbloqueado."
          sleep 0.2
          device_menu "$mac" "$name"
          ;;
        *"Bloquear"*)
          bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
          sleep 0.2
          bluetoothctl block "$mac" >/dev/null 2>&1 || true
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
        CH=$(printf "%s\n%s" "$OFF_OPT" "$BM_OPT" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰂲 Bluetooth Desligado " \
          -theme-str 'window {width: 600px; border-radius: 14px;} listview {columns: 1; lines: 2;}' -no-custom)
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

      local SCAN_TEXT="󰑐  Escanear Novos Dispositivos (Scan: OFF)"
      scan_on && SCAN_TEXT="󰑐  Parar Escaneamento (Scan: ATIVO)"

      local PAIR_TEXT="󰌆  Modo Pareável (Pairable: OFF)"
      pairable_on && PAIR_TEXT="󰌆  Modo Pareável (Pairable: ON)"

      local DISC_TEXT="󰈈  Visibilidade (Discoverable: OFF)"
      discoverable_on && DISC_TEXT="󰈈  Visibilidade (Discoverable: ON)"

      local HEADER_ITEMS="󰂲  Desligar Bluetooth\n$SCAN_TEXT\n$PAIR_TEXT\n$DISC_TEXT\n󰂯  Abrir Blueman (Gerenciador Avançado)"

      local CONN_ITEMS=""
      local PAIRED_ITEMS=""
      local SCANNED_ITEMS=""
      local SEEN_MACS=()

      # 1. Obter dispositivos pareados e checar conexões
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        echo "$line" | grep -q "^Device " || continue
        local mac
        mac=$(echo "$line" | awk '{print $2}')
        [[ "$mac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || continue
        SEEN_MACS+=("$mac")

        local dinfo
        dinfo=$(bluetoothctl info "$mac" 2>/dev/null)

        local name
        name=$(echo "$dinfo" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
        if [ -z "$name" ]; then
          name=$(echo "$dinfo" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
        fi
        if [ -z "$name" ]; then
          name=$(echo "$line" | cut -d' ' -f3-)
        fi
        [ -z "$name" ] && name="Dispositivo Desconhecido"

        local icon_class; icon_class=$(echo "$dinfo" | grep -i "Icon:" | awk '{print $2}')
        local class_hex; class_hex=$(echo "$dinfo" | grep -i "Class:" | awk '{print $2}')
        local uuids; uuids=$(echo "$dinfo" | grep -i "UUID:")
        local icon; icon=$(get_device_icon "$icon_class" "$class_hex" "$uuids" "$name")

        if echo "$dinfo" | grep -q "Connected: yes"; then
          local batt
          batt=$(echo "$dinfo" | grep -i "Battery Percentage" | sed -E 's/.*\(([0-9]+)\).*/\1/; s/.*:[[:space:]]*([0-9]+).*/\1/' | tr -dc '0-9')
          if [ -n "$batt" ] && [ "$batt" -le 100 ] 2>/dev/null; then
            CONN_ITEMS+="$icon  $name  [$mac]  (󰂱 Conectado 󰁹 $batt%)\n"
          else
            CONN_ITEMS+="$icon  $name  [$mac]  (󰂱 Conectado)\n"
          fi
        else
          PAIRED_ITEMS+="$icon  $name  [$mac]  (Pareado)\n"
        fi
      done < <(bluetoothctl paired-devices 2>/dev/null)

      # 2. Também verificar se há algum dispositivo conectado não pareado (ex: BLE)
      while IFS= read -r cline; do
        [ -z "$cline" ] && continue
        echo "$cline" | grep -q "^Device " || continue
        local cmac
        cmac=$(echo "$cline" | awk '{print $2}')
        [[ "$cmac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || continue

        local already_seen=0
        for seen in "''${SEEN_MACS[@]}"; do
          if [ "$seen" = "$cmac" ]; then
            already_seen=1
            break
          fi
        done
        [ "$already_seen" -eq 1 ] && continue

        local cdinfo
        cdinfo=$(bluetoothctl info "$cmac" 2>/dev/null)
        if echo "$cdinfo" | grep -q "Connected: yes"; then
          SEEN_MACS+=("$cmac")
          local cname
          cname=$(echo "$cdinfo" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          if [ -z "$cname" ]; then
            cname=$(echo "$cdinfo" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          fi
          if [ -z "$cname" ]; then
            cname=$(echo "$cline" | cut -d' ' -f3-)
          fi
          [ -z "$cname" ] && cname="Dispositivo Desconhecido"

          local cicon_class; cicon_class=$(echo "$cdinfo" | grep -i "Icon:" | awk '{print $2}')
          local cclass_hex; cclass_hex=$(echo "$cdinfo" | grep -i "Class:" | awk '{print $2}')
          local cuuids; cuuids=$(echo "$cdinfo" | grep -i "UUID:")
          local cicon; cicon=$(get_device_icon "$cicon_class" "$cclass_hex" "$cuuids" "$cname")

          local cbatt
          cbatt=$(echo "$cdinfo" | grep -i "Battery Percentage" | sed -E 's/.*\(([0-9]+)\).*/\1/; s/.*:[[:space:]]*([0-9]+).*/\1/' | tr -dc '0-9')
          if [ -n "$cbatt" ] && [ "$cbatt" -le 100 ] 2>/dev/null; then
            CONN_ITEMS+="$cicon  $cname  [$cmac]  (󰂱 Conectado 󰁹 $cbatt%)\n"
          else
            CONN_ITEMS+="$cicon  $cname  [$cmac]  (󰂱 Conectado)\n"
          fi
        fi
      done < <(bluetoothctl devices 2>/dev/null)

      # 3. Se o escaneamento estiver ativo, listar dispositivos descobertos não pareados
      if scan_on; then
        while IFS= read -r line; do
          [ -z "$line" ] && continue
          echo "$line" | grep -q "^Device " || continue
          local mac
          mac=$(echo "$line" | awk '{print $2}')
          [[ "$mac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || continue

          # Pula se já estiver na lista de pareados ou conectados
          local already_seen=0
          for seen in "''${SEEN_MACS[@]}"; do
            if [ "$seen" = "$mac" ]; then
              already_seen=1
              break
            fi
          done
          [ "$already_seen" -eq 1 ] && continue

          local sdinfo
          sdinfo=$(bluetoothctl info "$mac" 2>/dev/null)
          local name
          name=$(echo "$sdinfo" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          if [ -z "$name" ]; then
            name=$(echo "$sdinfo" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          fi
          if [ -z "$name" ]; then
            name=$(echo "$line" | cut -d' ' -f3-)
          fi
          [ -z "$name" ] && name="Dispositivo Desconhecido"

          local sicon_class; sicon_class=$(echo "$sdinfo" | grep -i "Icon:" | awk '{print $2}')
          local sclass_hex; sclass_hex=$(echo "$sdinfo" | grep -i "Class:" | awk '{print $2}')
          local suuids; suuids=$(echo "$sdinfo" | grep -i "UUID:")
          local sicon; sicon=$(get_device_icon "$sicon_class" "$sclass_hex" "$suuids" "$name")
          [ "$sicon" = "󰂱" ] && sicon="󰑐"

          SCANNED_ITEMS+="$sicon  $name  [$mac]  (Disponível)\n"
        done < <(bluetoothctl devices 2>/dev/null)
      fi

      local DEV_LIST=""
      [ -n "$CONN_ITEMS" ] && DEV_LIST+="$CONN_ITEMS"
      [ -n "$PAIRED_ITEMS" ] && DEV_LIST+="$PAIRED_ITEMS"
      [ -n "$SCANNED_ITEMS" ] && DEV_LIST+="$SCANNED_ITEMS"

      local MENU_CONTENT="$HEADER_ITEMS"
      if [ -n "$DEV_LIST" ]; then
        MENU_CONTENT+="\n------------------------------------\n$DEV_LIST"
      else
        MENU_CONTENT+="\n------------------------------------\n󰂲  Nenhum dispositivo pareado (ative o Escaneamento)"
      fi

      local SELECTED
      SELECTED=$(printf "%b" "$MENU_CONTENT" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰂯 Bluetooth " \
        -theme-str 'window {width: 900px; border-radius: 14px;} listview {columns: 1; lines: 14;}' -no-custom)

      [ -z "$SELECTED" ] && exit 0

      case "$SELECTED" in
        *"Desligar Bluetooth"*)
          toggle_power
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
          if command -v blueman-manager >/dev/null 2>&1; then
            blueman-manager &
          else
            ${pkgs.blueman}/bin/blueman-manager &
          fi
          ;;
        *"----------------"*)
          show_menu
          ;;
        *"Nenhum dispositivo"*)
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

    case "''${1:-}" in
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

  # --- Menu Interativo de Redes & Wi-Fi (Rofi) ---
  rofiWifiMenu = pkgs.writeShellScript "rofi-wifi-menu" ''
    export PATH="/usr/bin:/usr/sbin:${lib.makeBinPath [
      pkgs.networkmanager
      pkgs.networkmanagerapplet
      pkgs.rofi
      pkgs.dunst
      pkgs.iproute2
      pkgs.gawk
      pkgs.gnused
      pkgs.gnugrep
      pkgs.uutils-coreutils-noprefix
      pkgs.procps
    ]}:$PATH"

    notify_wifi() {
      local urgency="$1"
      local icon="$2"
      local title="$3"
      local msg="$4"
      ${pkgs.dunst}/bin/dunstify -a "Rede" -u "$urgency" -i "$icon" -h string:x-dunst-stack-tag:network-osd -t 3500 "$title" "$msg"
    }

    get_wifi_device() {
      nmcli -t -f DEVICE,TYPE device 2>/dev/null | grep ':wifi$' | head -n1 | cut -d: -f1
    }

    get_wired_device() {
      nmcli -t -f DEVICE,TYPE device 2>/dev/null | grep ':ethernet$' | head -n1 | cut -d: -f1
    }

    wifi_radio_on() {
      [ "$(nmcli radio wifi 2>/dev/null)" = "enabled" ]
    }

    toggle_wifi_radio() {
      if wifi_radio_on; then
        nmcli radio wifi off 2>/dev/null || true
        notify_wifi "low" "network-wireless-offline" "Wi-Fi Desativado" "O rádio Wi-Fi foi desligado."
      else
        nmcli radio wifi on 2>/dev/null || true
        notify_wifi "normal" "network-wireless" "Wi-Fi Ativado" "O rádio Wi-Fi foi ligado. Escaneando redes..."
        sleep 1.5
      fi
      show_main_menu
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
        notify_wifi "normal" "network-wired-disconnected" "Rede Cabeada Desconectada" "Interface $eth_dev desconectada. Sistema agora em Wi-Fi/offline."
      else
        notify_wifi "low" "network-wired" "Rede Cabeada" "Conectando interface $eth_dev..."
        nmcli device connect "$eth_dev" 2>/dev/null || true
        sleep 1.2
        local eth_ip
        eth_ip=$(nmcli -t -f IP4.ADDRESS dev show "$eth_dev" 2>/dev/null | head -n1 | cut -d: -f2)
        notify_wifi "normal" "network-wired" "Rede Cabeada Conectada" "Interface $eth_dev conectada com sucesso!''${eth_ip:+ IP: $eth_ip}"
      fi
      show_main_menu
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
        if [[ "$security" =~ WPA|WEP|802.1X ]]; then
          local wifi_pass
          wifi_pass=$(rofi -dmenu -password -p "Senha para $ssid" -theme-str 'window {width: 600px; border-radius: 14px;}')
          [ -z "$wifi_pass" ] && return

          notify_wifi "low" "network-wireless" "Autenticando..." "Conectando a \"$ssid\"..."
          if nmcli device wifi connect "$ssid" password "$wifi_pass" ''${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
            notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso a \"$ssid\"!"
          else
            notify_wifi "critical" "network-wireless-offline" "Falha na Senha" "Senha incorreta ou erro ao conectar a \"$ssid\"."
          fi
        else
          notify_wifi "low" "network-wireless" "Conectando..." "Conectando à rede aberta \"$ssid\"..."
          if nmcli device wifi connect "$ssid" ''${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
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
        if nmcli connection delete id "$ssid" 2>/dev/null || nmcli connection delete "$ssid" 2>/dev/null; then
          notify_wifi "normal" "network-wireless" "Rede Esquecida" "O perfil e a senha da rede \"$ssid\" foram removidos."
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
        if nmcli device wifi connect "$hidden_ssid" password "$hidden_pass" hidden yes ''${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
          notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso à rede oculta \"$hidden_ssid\"!"
        else
          notify_wifi "critical" "network-wireless-offline" "Falha" "Não foi possível conectar à rede oculta."
        fi
      else
        notify_wifi "low" "network-wireless" "Conectando..." "Conectando à rede oculta \"$hidden_ssid\"..."
        if nmcli device wifi connect "$hidden_ssid" hidden yes ''${wifi_dev:+ifname "$wifi_dev"} 2>/dev/null; then
          notify_wifi "normal" "network-wireless" "Wi-Fi Conectado" "Conectado com sucesso à rede oculta \"$hidden_ssid\"!"
        else
          notify_wifi "critical" "network-wireless-offline" "Falha" "Não foi possível conectar à rede oculta."
        fi
      fi
      show_main_menu
    }

    saved_networks_menu() {
      local saved_list
      saved_list=$(nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep ':802-11-wireless$' | cut -d: -f1)

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
      chosen_saved=$(printf "%s\n" "''${options[@]}" | rofi \
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
      local bssid="$2"
      local chan="$3"
      local freq="$4"
      local signal="$5"
      local bars="$6"
      local security="$7"
      local is_connected="$8"

      local wifi_dev
      wifi_dev=$(get_wifi_device)
      local ip_info="" gw_info="" dns_info=""

      if [ "$is_connected" = true ] && [ -n "$wifi_dev" ]; then
        ip_info=$(nmcli -t -f IP4.ADDRESS dev show "$wifi_dev" 2>/dev/null | head -n1 | cut -d: -f2)
        gw_info=$(nmcli -t -f IP4.GATEWAY dev show "$wifi_dev" 2>/dev/null | head -n1 | cut -d: -f2)
        dns_info=$(nmcli -t -f IP4.DNS dev show "$wifi_dev" 2>/dev/null | tr '\n' ' ' | sed 's/IP4.DNS:[[:space:]]*//g')
      fi

      local details=()
      details+=("󰤨  SSID:              ''${ssid}")
      details+=("󰌘  Status:            $([ "$is_connected" = true ] && echo "Conectada (Ativa)" || echo "Ao alcance")")
      [ -n "$ip_info" ] && details+=("󱦂  Endereço IP:       $ip_info")
      [ -n "$gw_info" ] && details+=("󰒍  Gateway:           $gw_info")
      [ -n "$dns_info" ] && details+=("󰀂  Servidores DNS:    $dns_info")
      [ -n "$signal" ] && details+=("󰤨  Sinal:             ''${signal}% (''${bars})")
      [ -n "$security" ] && details+=("󰌾  Segurança:         ''${security}")
      [ -n "$chan" ] && details+=("󰀝  Canal / Freq:      Canal ''${chan} (''${freq})")
      [ -n "$bssid" ] && details+=("󰈀  BSSID (MAC AP):    ''${bssid}")
      [ -n "$wifi_dev" ] && details+=("󰞌  Interface:         ''${wifi_dev}")
      details+=("󰌍  Voltar")

      printf "%s\n" "''${details[@]}" | rofi \
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
      nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep ':802-11-wireless$' | grep -Fxq "$ssid:802-11-wireless" && is_saved=true

      local net_info
      net_info=$(nmcli -t -f SSID,BSSID,CHAN,FREQ,SIGNAL,BARS,SECURITY dev wifi list 2>/dev/null | grep -E "^$ssid:" | head -n1)
      local bssid chan freq signal bars security
      IFS=: read -r _ bssid chan freq signal bars security <<< "$net_info"

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
      chosen_sub=$(printf "%s\n" "''${options[@]}" | rofi \
        -dmenu \
        -i \
        -p "$sub_prompt" \
        -theme-str 'window {width: 680px; border-radius: 14px;} listview {columns: 1; lines: 6;}' \
        -no-custom)

      [ -z "$chosen_sub" ] && { show_main_menu; return; }

      case "$chosen_sub" in
        *"Desconectar da Rede"*)
          notify_wifi "low" "network-wireless-offline" "Wi-Fi" "Desconectando de \"$ssid\"..."
          nmcli device disconnect "$wifi_dev" 2>/dev/null || nmcli connection down "$ssid" 2>/dev/null || true
          sleep 0.5
          notify_wifi "normal" "network-wireless-offline" "Wi-Fi Desconectado" "Você foi desconectado da rede \"$ssid\"."
          show_main_menu
          ;;
        *"Reconectar"*)
          notify_wifi "low" "network-wireless" "Wi-Fi" "Reconectando a \"$ssid\"..."
          nmcli connection up id "$ssid" 2>/dev/null || nmcli connection up "$ssid" 2>/dev/null || nmcli device wifi connect "$ssid" 2>/dev/null || true
          sleep 1
          notify_wifi "normal" "network-wireless" "Wi-Fi Reconectado" "Conexão com \"$ssid\" restabelecida."
          show_main_menu
          ;;
        *"Conectar a esta Rede"*)
          connect_to_network "$ssid" "$security" "$is_saved"
          show_main_menu
          ;;
        *"Esquecer Rede"*)
          forget_network "$ssid"
          show_main_menu
          ;;
        *"Detalhes da Rede"*)
          show_network_details "$ssid" "$bssid" "$chan" "$freq" "$signal" "$bars" "$security" "$is_connected"
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

      # Controle da Rede Cabeada (Wired Toggle)
      if [ -n "$eth_dev" ]; then
        if [ "$eth_state" = "connected" ]; then
          top_options+=("󰈂  Desconectar Rede Cabeada        [Cabo: $eth_dev (''${eth_conn:-Ativo})''${eth_ip:+ - $eth_ip}]")
        else
          top_options+=("󰈀  Conectar Rede Cabeada           [Cabo: $eth_dev Desconectado]")
        fi
      fi

      # Controle do Rádio Wi-Fi
      if [ "$is_wifi_on" = true ]; then
        top_options+=("󰤮  Desativar Rádio Wi-Fi           [Wi-Fi Ligado''${active_wifi_ssid:+ - $active_wifi_ssid}]")
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
        saved_names=$(nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep ':802-11-wireless$' | cut -d: -f1)

        local raw_list
        raw_list=$(nmcli -t -f IN-USE,BSSID,SSID,SIGNAL,BARS,SECURITY dev wifi list 2>/dev/null)

        local seen_ssids="|"
        while IFS=: read -r in_use bssid ssid signal bars security; do
          [ -z "$ssid" ] && continue
          if [[ "$seen_ssids" =~ "|$ssid|" ]]; then
            continue
          fi
          seen_ssids="$seen_ssids$ssid|"

          local prefix="󰌾"
          local status_tag=""
          local is_sec="WPA"
          if [[ "$security" =~ WPA|WEP|802.1X ]]; then
            prefix="󰌾"
            is_sec="$security"
          else
            prefix="󰤨"
            is_sec="Aberta"
          fi

          if [ "$in_use" = "*" ]; then
            status_tag="[Conectada]"
            prefix="󰤨"
          elif echo "$saved_names" | grep -Fxq "$ssid"; then
            status_tag="[Salva]"
          else
            status_tag="[$is_sec]"
          fi

          local line
          line=$(printf "%s  %-34s  %-14s  [%s] %s%%" "$prefix" "$ssid" "$status_tag" "$bars" "$signal")
          wifi_entries+=("$line")
        done <<< "$raw_list"
      fi

      local menu_content=""
      for opt in "''${top_options[@]}"; do
        menu_content="''${menu_content}''${opt}\n"
      done

      if [ "''${#wifi_entries[@]}" -gt 0 ]; then
        menu_content="''${menu_content}────────────────────────────────────────────────────────────────────────\n"
        for w in "''${wifi_entries[@]}"; do
          menu_content="''${menu_content}''${w}\n"
        done
      elif [ "$is_wifi_on" = true ]; then
        menu_content="''${menu_content}────────────────────────────────────────────────────────────────────────\n"
        menu_content="''${menu_content}󰤮  Nenhuma rede Wi-Fi encontrada ao alcance\n"
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
        *"Desconectar Rede Cabeada"*)
          toggle_wired
          ;;
        *"Conectar Rede Cabeada"*)
          toggle_wired
          ;;
        *"Desativar Rádio Wi-Fi"*)
          toggle_wifi_radio
          ;;
        *"Ativar Rádio Wi-Fi"*)
          toggle_wifi_radio
          ;;
        *"Escanear Redes Novamente"*)
          notify_wifi "low" "network-wireless" "Escaneando..." "Buscando redes Wi-Fi disponíveis..."
          nmcli device wifi rescan 2>/dev/null || true
          sleep 1.2
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
          elif [ -x "${pkgs.networkmanagerapplet}/bin/nm-connection-editor" ]; then
            ${pkgs.networkmanagerapplet}/bin/nm-connection-editor &
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
          sel_ssid=$(echo "$chosen" | sed -E 's/^[󰌾󰤨 ]+//; s/  +\[.*//; s/ +$//')
          if [ -n "$sel_ssid" ]; then
            network_menu "$sel_ssid"
          else
            show_main_menu
          fi
          ;;
      esac
    }

    show_main_menu
  '';

  # --- Menu de Desligamento com Rofi ---
  rofiPowerMenu = pkgs.writeShellScript "rofi-powermenu" ''
    export PATH="${pkgs.rofi}/bin:${pkgs.systemd}/bin:${pkgs.bspwm}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    chosen=$(printf "󰐥  Desligar\n󰜉  Reiniciar\n󰤄  Suspender\n󰒲  Hibernar\n󰈆  Sair (logout)\n󰌾  Bloquear" \
      | rofi \
          -dmenu \
          -i \
          -p "Power Menu" \
          -theme-str 'window {width: 320px; border-radius: 14px;} listview {columns: 1; lines: 6;}' \
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

    chosen=$(printf "$entries" | rofi -dmenu -i -p " 󰖯 Restaurar Janela " -theme-str 'window { width: 700px; border-radius: 14px; } listview { columns: 1; lines: 8; }')
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
      -theme-str 'window {width: 360px; border-radius: 14px;} listview {columns: 1; lines: 4;}' \
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
      step="''${1:-100}"
      temp=$(get_temp)
      temp=$((temp + step))
      [ "$temp" -gt 6500 ] && temp=6500
      set_temp "$temp"
    }

    decrease() {
      step="''${1:-100}"
      temp=$(get_temp)
      temp=$((temp - step))
      [ "$temp" -lt 2500 ] && temp=2500
      set_temp "$temp"
    }

    case "$1" in
      toggle)
        toggle
        ;;
      increase)
        increase "''${2:-100}"
        ;;
      decrease)
        decrease "''${2:-100}"
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

  # --- Indicador Dinâmico de Layout do BSPWM na Polybar ---
  bspLayoutScript = pkgs.writeShellScript "bsp-layout-status" ''
    export PATH="${lib.makeBinPath [ pkgs.bsp-layout pkgs.bspwm pkgs.jq pkgs.coreutils ]}:$PATH"
    layout=$(bsp-layout get 2>/dev/null)

    if [ -z "$layout" ] || [ "$layout" = "-" ]; then
      layout=$(bspc query -T -d focused 2>/dev/null | jq -r '.layout' 2>/dev/null || echo "tiled")
    fi

    case "$layout" in
      tall)
        icon="󰕰"
        name="Tall"
        ;;
      rtall)
        icon="󰕰"
        name="RTall"
        ;;
      wide)
        icon="󰕰"
        name="Wide"
        ;;
      rwide)
        icon="󰕰"
        name="RWide"
        ;;
      grid)
        icon="󰝘"
        name="Grid"
        ;;
      even)
        icon="󱒅"
        name="Even"
        ;;
      monocle)
        icon="󰍹"
        name="Monocle"
        ;;
      tiled|*)
        icon="󱒆"
        name="Tiled"
        ;;
    esac

    echo "%{F${colors.blue}}$icon%{F-} %{F${colors.text}}$name%{F-}"
  '';

  # --- Alternador de Layout com Notificação OSD (Dunst) ---
  bspLayoutSwitchScript = pkgs.writeShellScript "bsp-layout-switch" ''
    export PATH="${lib.makeBinPath [ pkgs.bsp-layout pkgs.bspwm pkgs.dunst pkgs.jq pkgs.coreutils ]}:$PATH"

    notify_layout() {
      layout=$(bsp-layout get 2>/dev/null)
      if [ -z "$layout" ] || [ "$layout" = "-" ]; then
        layout=$(bspc query -T -d focused 2>/dev/null | jq -r '.layout' 2>/dev/null || echo "tiled")
      fi

      case "$layout" in
        tall)
          icon="preferences-desktop-display"
          label="Tall (Master-Stack V)"
          ;;
        rtall)
          icon="preferences-desktop-display"
          label="RTall (Master-Stack Invertido)"
          ;;
        wide)
          icon="preferences-desktop-display"
          label="Wide (Master-Stack H)"
          ;;
        rwide)
          icon="preferences-desktop-display"
          label="RWide (Wide Invertido)"
          ;;
        grid)
          icon="preferences-desktop-display"
          label="Grid (Grade)"
          ;;
        even)
          icon="preferences-desktop-display"
          label="Even (Divisão Igual)"
          ;;
        monocle)
          icon="view-fullscreen"
          label="Monocle (Tela Única)"
          ;;
        tiled|*)
          icon="preferences-desktop-display"
          label="Tiled (Padrão BSPWM)"
          ;;
      esac

      dunstify -a "BSPWM Layout" -u low -i "$icon" -r 9993 -t 1500 "Layout: $label"
    }

    ACTION="''${1:-next}"

    case "$ACTION" in
      next|cycle)
        bsp-layout next
        notify_layout
        ;;
      prev|previous)
        bsp-layout prev
        notify_layout
        ;;
      tall|rtall|wide|rwide|grid|even|monocle|tiled)
        bsp-layout set "$ACTION"
        notify_layout
        ;;
      remove|reset)
        bsp-layout remove
        notify_layout
        ;;
      *)
        bsp-layout next
        notify_layout
        ;;
    esac
  '';

  # --- Menu Rofi para Seleção Interativa de Layouts ---
  rofiLayoutMenu = pkgs.writeShellScript "rofi-bsp-layout" ''
    export PATH="${lib.makeBinPath [ pkgs.bsp-layout pkgs.bspwm pkgs.rofi pkgs.dunst pkgs.jq pkgs.coreutils ]}:$PATH"

    curr_layout=$(bsp-layout get 2>/dev/null)
    if [ -z "$curr_layout" ] || [ "$curr_layout" = "-" ]; then
      curr_layout=$(bspc query -T -d focused 2>/dev/null | jq -r '.layout' 2>/dev/null || echo "tiled")
    fi

    OPTIONS="󰕰  Tall (Master vertical)\n󰕰  Wide (Master horizontal)\n󰝘  Grid (Grade balanceada)\n󱒅  Even (Divisão simétrica)\n󰕰  RTall (Master à direita)\n󰕰  RWide (Master abaixo)\n󰍹  Monocle (Janela maximizada)\n󱒆  Tiled (Padrão BSPWM)"

    CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Layout ($curr_layout)" -theme-str 'window { width: 420px; } listview { lines: 8; }')

    case "$CHOSEN" in
      *RTall*)
        ${bspLayoutSwitchScript} rtall
        ;;
      *Tall*)
        ${bspLayoutSwitchScript} tall
        ;;
      *RWide*)
        ${bspLayoutSwitchScript} rwide
        ;;
      *Wide*)
        ${bspLayoutSwitchScript} wide
        ;;
      *Grid*)
        ${bspLayoutSwitchScript} grid
        ;;
      *Even*)
        ${bspLayoutSwitchScript} even
        ;;
      *Monocle*)
        ${bspLayoutSwitchScript} monocle
        ;;
      *Tiled*)
        ${bspLayoutSwitchScript} tiled
        ;;
    esac
  '';

  # --- Script de Detecção do Logo do Sistema Operacional (Ícone e Cor Dinâmicos) ---
  osLogoScript = pkgs.writeShellScript "polybar-os-logo" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gnused
      ]
    }:$PATH"

    if [ -n "''${OS_LOGO_ICON:-}" ]; then
      echo "$OS_LOGO_ICON"
      exit 0
    fi

    os_id=""
    os_like=""

    if [ -r /etc/os-release ]; then
      . /etc/os-release 2>/dev/null
      os_id="''${ID:-}"
      os_like="''${ID_LIKE:-}"
    elif [ -r /usr/lib/os-release ]; then
      . /usr/lib/os-release 2>/dev/null
      os_id="''${ID:-}"
      os_like="''${ID_LIKE:-}"
    fi

    if [ -z "$os_id" ] && [ -e /etc/NIXOS ]; then
      os_id="nixos"
    fi

    os_id=$(echo "$os_id" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

    icon=""
    color="${colors.yellow}"

    case "$os_id" in
      nixos)
        icon="󱄅"
        color="${colors.sky}"
        ;;
      debian)
        icon=""
        color="${colors.red}"
        ;;
      fedora)
        icon=""
        color="${colors.blue}"
        ;;
      arch|archarm)
        icon="󰣇"
        color="${colors.sapphire}"
        ;;
      endeavouros)
        icon=""
        color="${colors.mauve}"
        ;;
      artix)
        icon=""
        color="${colors.sapphire}"
        ;;
      ubuntu)
        icon=""
        color="${colors.peach}"
        ;;
      pop)
        icon=""
        color="${colors.teal}"
        ;;
      linuxmint|mint)
        icon=""
        color="${colors.green}"
        ;;
      void)
        icon=""
        color="${colors.green}"
        ;;
      opensuse*|suse)
        icon=""
        color="${colors.green}"
        ;;
      gentoo)
        icon=""
        color="${colors.lavender}"
        ;;
      alpine)
        icon=""
        color="${colors.blue}"
        ;;
      manjaro)
        icon=""
        color="${colors.teal}"
        ;;
      centos)
        icon=""
        color="${colors.mauve}"
        ;;
      rhel|redhat|almalinux|rocky)
        icon=""
        color="${colors.red}"
        ;;
      kali)
        icon=""
        color="${colors.blue}"
        ;;
      *)
        case "$os_like" in
          *arch*)
            icon="󰣇"
            color="${colors.sapphire}"
            ;;
          *debian*)
            icon=""
            color="${colors.red}"
            ;;
          *fedora*|*rhel*)
            icon=""
            color="${colors.blue}"
            ;;
          *ubuntu*)
            icon=""
            color="${colors.peach}"
            ;;
          *suse*)
            icon=""
            color="${colors.green}"
            ;;
          *)
            icon=""
            color="${colors.yellow}"
            ;;
        esac
        ;;
    esac

    if [ "''${1:-}" = "--pill" ]; then
      echo "%{T5}%{F$color}%{F-}%{T-}%{O-1}%{B$color}%{F${colors.crust}}%{T4}$icon%{T-}%{F-}%{B-}%{O-1}%{T5}%{F$color}%{F-}%{T-}"
    elif [ "''${1:-}" = "--icon-only" ]; then
      echo "$icon"
    elif [ "''${1:-}" = "--color-only" ]; then
      echo "$color"
    else
      echo "%{F$color}$icon%{F-}"
    fi
  '';

  # --- Tempo de Atividade do Sistema (Uptime) ---
  uptimeScript = pkgs.writeShellScript "polybar-uptime" ''
    export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.gawk ]}:$PATH"
    if [ -f /proc/uptime ]; then
      seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
      hours=$((seconds / 3600))
      minutes=$(((seconds % 3600) / 60))
      if [ "$hours" -gt 0 ]; then
        echo "%{F${colors.lavender}}󰔚%{F-} ''${hours}h ''${minutes}m"
      else
        echo "%{F${colors.lavender}}󰔚%{F-} ''${minutes}m"
      fi
    else
      echo "%{F${colors.lavender}}󰔚%{F-} up"
    fi
  '';

  # --- Velocidade Dinâmica de Rede (Download / Upload Universal) ---
  netspeedScript = pkgs.writeShellScript "polybar-netspeed" ''
    export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.gawk pkgs.iproute2 ]}:$PATH"

    cache_file="/tmp/.polybar-netspeed-cache"

    iface=$(ip route 2>/dev/null | awk '/^default/ {print $5; exit}')
    if [ -z "$iface" ]; then
      iface=$(awk -F: '/^[a-zA-Z0-9]+:/ && !/lo/ {gsub(/ /, "", $1); print $1; exit}' /proc/net/dev 2>/dev/null)
    fi

    if [ -z "$iface" ]; then
      echo "%{F${colors.blue}}󰇚 0K%{F-}  %{F${colors.peach}}󰕒 0K%{F-}"
      exit 0
    fi

    read -r rx tx < <(awk -v dev="$iface:" '$1 == dev {print $2, $10}' /proc/net/dev 2>/dev/null)
    now=$(date +%s)

    if [ -f "$cache_file" ]; then
      read -r prev_time prev_rx prev_tx prev_iface < "$cache_file"
      if [ "$prev_iface" = "$iface" ] && [ -n "$prev_time" ] && [ "$now" -gt "$prev_time" ]; then
        dt=$((now - prev_time))
        rx_speed=$(( (rx - prev_rx) / dt ))
        tx_speed=$(( (tx - prev_tx) / dt ))
      else
        rx_speed=0
        tx_speed=0
      fi
    else
      rx_speed=0
      tx_speed=0
    fi

    echo "$now $rx $tx $iface" > "$cache_file"

    format_speed() {
      local bytes=$1
      if [ "$bytes" -ge 1048576 ]; then
        awk -v b="$bytes" 'BEGIN {printf "%.1fM", b/1048576}'
      elif [ "$bytes" -ge 1024 ]; then
        echo "$((bytes / 1024))K"
      else
        echo "0K"
      fi
    }

    down_str=$(format_speed "$rx_speed")
    up_str=$(format_speed "$tx_speed")

    echo "%{F${colors.blue}}󰇚 $down_str%{F-}  %{F${colors.peach}}󰕒 $up_str%{F-}"
  '';

  # --- Controle e Status de Brilho da Tela ---
  backlightScript = pkgs.writeShellScript "polybar-backlight" ''
    export PATH="${lib.makeBinPath [ pkgs.brightnessctl pkgs.coreutils ]}:$PATH"
    dev=""
    for d in intel_backlight nv_backlight apple_backlight acpi_video0; do
      if [ -d "/sys/class/backlight/$d" ]; then
        dev="$d"
        break
      fi
    done
    if [ -z "$dev" ] && [ -d /sys/class/backlight ]; then
      dev=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1)
    fi
    [ -z "$dev" ] && exit 0

    case "''${1:-}" in
      up) brightnessctl -d "$dev" set +5% >/dev/null 2>&1 ;;
      down) brightnessctl -d "$dev" set 5%- >/dev/null 2>&1 ;;
      *)
        pct=$(brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' || true)
        if [ -n "$pct" ]; then
          echo "%{F${colors.yellow}}󰃠%{F-} $pct%"
        fi
        ;;
    esac
  '';

  # --- Script de Alternância da Bandeja do Sistema (Stalonetray) ---
  stalonetrayToggleScript = pkgs.writeShellScript "stalonetray-toggle" ''
    export PATH="${lib.makeBinPath [
      pkgs.stalonetray
      pkgs.xdotool
      pkgs.procps
      pkgs.coreutils
    ]}:$PATH"

    if ! pgrep -x "stalonetray" >/dev/null 2>&1; then
      stalonetray &
      sleep 0.2
      wid=$(xdotool search --class Stalonetray 2>/dev/null | head -n1 || xdotool search --class stalonetray 2>/dev/null | head -n1)
      [ -n "$wid" ] && xdotool windowraise "$wid"
    else
      wid=$(xdotool search --class Stalonetray 2>/dev/null | head -n1 || xdotool search --class stalonetray 2>/dev/null | head -n1)
      if [ -n "$wid" ]; then
        if xdotool search --onlyvisible --class Stalonetray 2>/dev/null | grep -q "^$wid$" || xdotool search --onlyvisible --class stalonetray 2>/dev/null | grep -q "^$wid$"; then
          xdotool windowunmap "$wid"
        else
          xdotool windowmap "$wid"
          xdotool windowraise "$wid"
        fi
      else
        pkill -x stalonetray || true
        stalonetray &
      fi
    fi
  '';

  # --- Script Inteligente de Inicialização Multi-Monitor da Polybar ---
  polybarLaunchScript = pkgs.writeShellScript "polybar-launch" ''
    export PATH="${lib.makeBinPath [
      polybar
      pkgs.xrandr
      pkgs.gnugrep
      pkgs.gawk
      pkgs.coreutils
      pkgs.procps
      pkgs.util-linux
      pkgs.bspwm
    ]}:$PATH"

    MY_PID=$$

    # 1. Prevenir concorrência entre invocações simultâneas via lock (flock)
    LOCK_FILE="/tmp/polybar-launch.lock"
    exec 200>"$LOCK_FILE"
    if ! flock -n 200; then
      flock -w 3 200 || exit 0
    fi

    # 2. Debounce: se a Polybar real já estiver ativa e foi iniciada há menos de 1s, sai
    LAST_RUN_FILE="/tmp/.polybar-last-launch"
    now=$(date +%s)
    if [ -f "$LAST_RUN_FILE" ]; then
      last_run=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)
      if [ $((now - last_run)) -lt 1 ]; then
        if pgrep -u "$UID" -x "polybar" >/dev/null 2>&1 || \
           pgrep -u "$UID" -x ".polybar-wrapped" >/dev/null 2>&1 || \
           pgrep -u "$UID" -f "polybar.*--reload" >/dev/null 2>&1; then
          flock -u 200
          exec 200>&-
          exit 0
        fi
      fi
    fi

    # 3. Limpar cache de estado, arquivos temporários e sockets IPC da Polybar
    rm -f /tmp/.polybar-netspeed-cache 2>/dev/null || true
    rm -f /tmp/polybar_redshift_* 2>/dev/null || true
    rm -f /tmp/polybar_mqueue.* 2>/dev/null || true
    rm -rf /tmp/polybar-*.log 2>/dev/null || true
    rm -rf /tmp/polybar-*.sock 2>/dev/null || true
    [ -n "''${XDG_RUNTIME_DIR:-}" ] && rm -rf "$XDG_RUNTIME_DIR"/polybar*.sock 2>/dev/null || true
    rm -rf "$HOME/.cache/polybar" 2>/dev/null || true

    # 4. Encerrar instâncias anteriores da Polybar (NUNCA matando o próprio polybar-launch)
    ${polybar}/bin/polybar-msg cmd quit 2>/dev/null || true
    pkill -u "$UID" -x "polybar" 2>/dev/null || true
    pkill -u "$UID" -x ".polybar-wrapped" 2>/dev/null || true
    pkill -u "$UID" -f "polybar.*--reload" 2>/dev/null || true

    # Matar quaisquer outros processos do polybar (excluindo explicitamente este script)
    for p in $(pgrep -u "$UID" -f "polybar" 2>/dev/null); do
      if [ "$p" != "$MY_PID" ] && ! grep -q "polybar-launch" "/proc/$p/cmdline" 2>/dev/null; then
        kill -15 "$p" 2>/dev/null || true
      fi
    done

    # Aguardar até 0.5s para que processos e janelas X11 sejam liberados
    wait_count=0
    while [ "$wait_count" -lt 5 ]; do
      active_pids=0
      for p in $(pgrep -u "$UID" -f "polybar" 2>/dev/null); do
        if [ "$p" != "$MY_PID" ] && ! grep -q "polybar-launch" "/proc/$p/cmdline" 2>/dev/null; then
          active_pids=1
          break
        fi
      done
      [ "$active_pids" -eq 0 ] && break
      sleep 0.1
      wait_count=$((wait_count + 1))
    done

    # Forçar término de processos rebeldes da Polybar se ainda restarem
    for p in $(pgrep -u "$UID" -f "polybar" 2>/dev/null); do
      if [ "$p" != "$MY_PID" ] && ! grep -q "polybar-launch" "/proc/$p/cmdline" 2>/dev/null; then
        kill -9 "$p" 2>/dev/null || true
      fi
    done

    # 5. Sincronizar detecção de telas e layout multi-monitor
    if command -v xrandr >/dev/null 2>&1; then
      export _POLYBAR_LAUNCHING=1

      # Se nenhum monitor primário estiver configurado e houver setup-monitors, sincroniza o layout
      if ! xrandr --query 2>/dev/null | grep -q " connected primary"; then
        if command -v setup-monitors >/dev/null 2>&1; then
          setup-monitors 2>/dev/null || true
        fi
      fi

      # Identificar saídas ativas com resolução configurada (evita saídas fantasmas)
      active_mons=($(xrandr --query 2>/dev/null | awk '/ connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {print $1}'))
      [ ''${#active_mons[@]} -eq 0 ] && active_mons=($(xrandr --query 2>/dev/null | awk '/ connected/ {print $1}'))

      # Identificar monitor primário de forma determinística
      primary_mon=$(xrandr --query 2>/dev/null | awk '/ connected primary/ {print $1}')
      [ -z "$primary_mon" ] && command -v bspc >/dev/null 2>&1 && primary_mon=$(bspc query -M -m primary --names 2>/dev/null || true)
      [ -z "$primary_mon" ] && [ ''${#active_mons[@]} -gt 0 ] && primary_mon="''${active_mons[0]}"

      mon_count=''${#active_mons[@]}

      # Atualizar timestamp de inicialização e liberar lock antes do spawn em background
      echo "$(date +%s)" > "$LAST_RUN_FILE"
      flock -u 200
      exec 200>&-

      if [ "$mon_count" -gt 1 ]; then
        # Multi-Monitor: Barra 1 (primary) no monitor principal e Barra 2 (secondary) nas demais telas
        for m in "''${active_mons[@]}"; do
          if [ "$m" = "$primary_mon" ]; then
            MONITOR=$m ${polybar}/bin/polybar --reload primary &
          else
            MONITOR=$m ${polybar}/bin/polybar --reload secondary &
          fi
        done
      elif [ "$mon_count" -eq 1 ]; then
        # Monitor Único: Barra completa com todos os módulos essenciais
        MONITOR="$primary_mon" ${polybar}/bin/polybar --reload main &
      else
        ${polybar}/bin/polybar --reload main &
      fi
    else
      echo "$(date +%s)" > "$LAST_RUN_FILE"
      flock -u 200
      exec 200>&-
      ${polybar}/bin/polybar --reload main &
    fi
  '';
}
