{
  pkgs,
  colors,
  lib ? pkgs.lib,
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

  # --- Script de Status do Bluetooth com Detecção de Bateria e Conexão ---
  bluetoothScript = pkgs.writeShellScript "polybar-bluetooth" ''
    export PATH="/usr/bin:/usr/sbin:${pkgs.bluez}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"
    if ! command -v bluetoothctl >/dev/null 2>&1; then
      echo "%{F${colors.surface2}}󰂲%{F-}"
      exit 0
    fi

    power=$(bluetoothctl show 2>/dev/null | grep -i "Powered:" | awk '{print $2}')
    if [ "$power" = "yes" ]; then
      conn_mac=""
      conn_name=""

      # Busca dispositivos conectados iterando sobre os dispositivos conhecidos pelo BlueZ
      while IFS= read -r dev_line; do
        [ -z "$dev_line" ] && continue
        echo "$dev_line" | grep -q "^Device " || continue
        pmac=$(echo "$dev_line" | awk '{print $2}')
        [[ "$pmac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || continue

        pinfo=$(bluetoothctl info "$pmac" 2>/dev/null)
        if echo "$pinfo" | grep -q "Connected: yes"; then
          conn_mac="$pmac"
          pname=$(echo "$pinfo" | grep -E '^[[:space:]]*Alias:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          if [ -z "$pname" ]; then
            pname=$(echo "$pinfo" | grep -E '^[[:space:]]*Name:' | head -n1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
          fi
          if [ -z "$pname" ]; then
            pname=$(echo "$dev_line" | cut -d' ' -f3-)
          fi
          conn_name="$pname"
          break
        fi
      done < <(bluetoothctl paired-devices 2>/dev/null; bluetoothctl devices 2>/dev/null)

      if [ -n "$conn_mac" ]; then
        display_name=$(echo "$conn_name" | cut -c1-14)
        [ -z "$display_name" ] && display_name="Conectado"
        dinfo=$(bluetoothctl info "$conn_mac" 2>/dev/null)
        batt_val=$(echo "$dinfo" | grep -i "Battery Percentage" | sed -E 's/.*\(([0-9]+)\).*/\1/; s/.*:[[:space:]]*([0-9]+).*/\1/' | tr -dc '0-9')
        if [ -n "$batt_val" ] && [ "$batt_val" -le 100 ] 2>/dev/null; then
          batt_color="${colors.green}"
          batt_icon="󰁹"
          if [ "$batt_val" -le 20 ] 2>/dev/null; then
            batt_color="${colors.red}"
            batt_icon="󰂃"
          elif [ "$batt_val" -le 40 ] 2>/dev/null; then
            batt_color="${colors.yellow}"
            batt_icon="󰁼"
          elif [ "$batt_val" -le 70 ] 2>/dev/null; then
            batt_color="${colors.yellow}"
            batt_icon="󰁾"
          fi
          echo "%{F${colors.blue}}󰂱%{F-} $display_name  %{F$batt_color}$batt_icon $batt_val%%{F-}"
        else
          echo "%{F${colors.blue}}󰂱%{F-} $display_name"
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
    export PATH="/usr/bin:/usr/sbin:${pkgs.bluez}/bin:${pkgs.blueman}/bin:${pkgs.rofi}/bin:${pkgs.dunst}/bin:${pkgs.util-linux}/bin:${pkgs.procps}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.uutils-coreutils-noprefix}/bin:$PATH"

    notify_bt() {
      local urgency="$1"
      local icon="$2"
      local title="$3"
      local msg="$4"
      ${pkgs.dunst}/bin/dunstify -a "Bluetooth" -u "$urgency" -i "$icon" -h string:x-dunst-stack-tag:bluetooth-osd -t 2500 "$title" "$msg"
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

      local PROMPT_TEXT=" $name [$mac] (Conectado: $is_connected$battery) "

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

          local cbatt
          cbatt=$(echo "$cdinfo" | grep -i "Battery Percentage" | sed -E 's/.*\(([0-9]+)\).*/\1/; s/.*:[[:space:]]*([0-9]+).*/\1/' | tr -dc '0-9')
          if [ -n "$cbatt" ] && [ "$cbatt" -le 100 ] 2>/dev/null; then
            CONN_ITEMS+="󰂱  $cname  [$cmac]  (󰂱 Conectado 󰁹 $cbatt%)\n"
          else
            CONN_ITEMS+="󰂱  $cname  [$cmac]  (󰂱 Conectado)\n"
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

          SCANNED_ITEMS+="󰑐  $name  [$mac]  (Disponível)\n"
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
        printf "%s  %-48s  [%s]\n", icon, ssid, bars;
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
      -theme-str 'window {width: 820px; border-radius: 14px;} listview {columns: 1; lines: 13;}' \
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

    chosen_ssid=$(echo "$chosen_line" | sed -E 's/^[󰌾󰤨 ]+//; s/  +\[.*//; s/ +$//')

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
          wifi_pass=$(rofi -dmenu -password -p "Senha para $chosen_ssid" -theme-str 'window {width: 600px; border-radius: 14px;}')
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

    if [ "''${1:-}" = "--icon-only" ]; then
      echo "$icon"
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

  # --- Script Inteligente de Inicialização Multi-Monitor da Polybar ---
  polybarLaunchScript = pkgs.writeShellScript "polybar-launch" ''
    export PATH="${lib.makeBinPath [ pkgs.polybar pkgs.xrandr pkgs.gnugrep pkgs.coreutils pkgs.procps ]}:$PATH"

    polybar-msg cmd quit 2>/dev/null || true
    pkill -x polybar 2>/dev/null || true
    while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

    if command -v xrandr >/dev/null 2>&1; then
      primary_mon=$(xrandr --query 2>/dev/null | grep " connected primary" | cut -d" " -f1)
      [ -z "$primary_mon" ] && primary_mon=$(xrandr --query 2>/dev/null | grep " connected" | head -n1 | cut -d" " -f1)

      connected_mons=($(xrandr --query 2>/dev/null | grep " connected" | cut -d" " -f1))
      mon_count=''${#connected_mons[@]}

      if [ "$mon_count" -gt 1 ]; then
        # Multi-Monitor: Barras complementares contínuas (sem repetição de módulos)
        for m in "''${connected_mons[@]}"; do
          if [ "$m" = "$primary_mon" ]; then
            MONITOR=$m polybar --reload primary &
          else
            MONITOR=$m polybar --reload secondary &
          fi
        done
      elif [ "$mon_count" -eq 1 ]; then
        # Monitor Único: Barra completa com todos os módulos essenciais
        MONITOR="$primary_mon" polybar --reload main &
      else
        polybar --reload main &
      fi
    else
      polybar --reload main &
    fi
  '';
}
