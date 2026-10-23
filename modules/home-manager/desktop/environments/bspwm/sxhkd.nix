{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) attrsOf bool str;
  cfg = config.desktop.bspwm.sxhkd;
  fmCmd = config.system.programs.file-manager.activeCommand or "file-manager";
  fmName = config.system.programs.file-manager.activeName or "Gerenciador de Arquivos";

  terminalCfg = config.system.programs.terminal;
  termCmd = terminalCfg.activeCommand;
  termDisplayName = terminalCfg.activeName;
  scratchpadLaunchCmd = "${terminalCfg.scratchpadCommand} &";

  browserBin = config.system.programs.browsers.activeBin or null;
  browserLaunchCmd =
    if browserBin != null then
      "${browserBin} &"
    else
      ''if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || ${pkgs.firefox}/bin/firefox & fi'';

  picomBin = "${nixGLWrapper pkgs.picom}/bin/picom";

  # Script nativo de Scratchpad dinâmico para BSPWM (Inspirado no gh0stzk/dotfiles)
  # - Monitor-aware (adapta geometria e move instantaneamente para o monitor ativo)
  # - Alternância suave via flag hidden nativa do bspwm
  # - Centralizado horizontalmente e posicionado logo abaixo da Polybar
  scratchpadScript = pkgs.writeShellScript "bspwm-scratchpad" ''
    SCRATCHPAD_NAME="bspwm-scratch"
    MAX_WIDTH_PERCENT=75
    HEIGHT_PERCENT=48

    # 1. Obter geometria do monitor atualmente focado
    mon_geo=$(${pkgs.bspwm}/bin/bspc query -T -m focused | ${pkgs.jq}/bin/jq -r '.rectangle | "\(.width) \(.height) \(.x) \(.y)"')
    SCREEN_WIDTH=$(echo "$mon_geo" | awk '{print $1}')
    SCREEN_HEIGHT=$(echo "$mon_geo" | awk '{print $2}')
    MONITOR_X=$(echo "$mon_geo" | awk '{print $3}')
    MONITOR_Y=$(echo "$mon_geo" | awk '{print $4}')

    # 2. Calcular dimensões e posicionamento (respeitando espaçamento da Polybar)
    WIDTH=$((SCREEN_WIDTH * MAX_WIDTH_PERCENT / 100))
    HEIGHT=$((SCREEN_HEIGHT * HEIGHT_PERCENT / 100))
    X_POS=$((MONITOR_X + (SCREEN_WIDTH - WIDTH) / 2))
    Y_POS=$((MONITOR_Y + 44))

    # 3. Localizar janela existente do scratchpad
    get_scratchpad_id() {
      for node in $(${pkgs.bspwm}/bin/bspc query -N -n ".floating.window" 2>/dev/null); do
        if ${pkgs.xprop}/bin/xprop -id "$node" WM_CLASS 2>/dev/null | grep -q "$SCRATCHPAD_NAME"; then
          echo "$node"
          return 0
        fi
      done
    }

    WINDOW_ID=$(get_scratchpad_id)

    if [ -n "$WINDOW_ID" ]; then
      CURRENT_STATE=$(${pkgs.bspwm}/bin/bspc query -T -n "$WINDOW_ID" | ${pkgs.jq}/bin/jq -r '.hidden')

      if [ "$CURRENT_STATE" = "false" ]; then
        # Se visível: oculta
        ${pkgs.bspwm}/bin/bspc node "$WINDOW_ID" -g hidden
      else
        # Se oculto: move para o monitor focado, reposiciona, redimensiona e foca
        ${pkgs.bspwm}/bin/bspc node "$WINDOW_ID" -m focused
        ${pkgs.xdo}/bin/xdo move -x "$X_POS" -y "$Y_POS" "$WINDOW_ID"
        ${pkgs.xdo}/bin/xdo resize -w "$WIDTH" -h "$HEIGHT" "$WINDOW_ID"
        ${pkgs.bspwm}/bin/bspc node "$WINDOW_ID" -g hidden=off -f
      fi
    else
      # Se não existe, cria a regra temporária one-shot no BSPWM
      ${pkgs.bspwm}/bin/bspc rule -a "$SCRATCHPAD_NAME" \
        state=floating \
        sticky=on \
        rectangle="''${WIDTH}x''${HEIGHT}+''${X_POS}+''${Y_POS}" \
        --one-shot

      # Inicia o terminal dedicado com a classe bspwm-scratch em $HOME
      ${scratchpadLaunchCmd}

      # Aguarda a criação e ajusta posição/tamanho se necessário
      for i in 1 2 3 4 5; do
        sleep 0.1
        WINDOW_ID=$(get_scratchpad_id)
        if [ -n "$WINDOW_ID" ]; then
          ${pkgs.xdo}/bin/xdo move -x "$X_POS" -y "$Y_POS" "$WINDOW_ID" 2>/dev/null || true
          ${pkgs.xdo}/bin/xdo resize -w "$WIDTH" -h "$HEIGHT" "$WINDOW_ID" 2>/dev/null || true
          break
        fi
      done
    fi
  '';

  screenshotSavePath = "${config.home.homeDirectory}/Pictures/Screenshots";

  # --- Suite de Captura de Tela Dinâmica e Suave (Inspirado no ScreenShoTer do gh0stzk/dotfiles) ---
  screenshotScript = pkgs.writeShellScript "bspwm-screenshot" ''
    dir="${screenshotSavePath}"
    [ -d "$dir" ] || mkdir -p "$dir"
    timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
    file="$dir/Screenshot_$timestamp.png"

    notify_shot() {
      if [ -f "$1" ]; then
        # Copia imagem diretamente para a área de transferência
        ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png < "$1" 2>/dev/null || true

        # Dispara notificação Dunst com miniatura e ações interativas
        action=$(${pkgs.dunst}/bin/dunstify -a "Screenshot" \
          -i "$1" \
          -u normal \
          -t 5000 \
          -h string:x-dunst-stack-tag:screenshot \
          "Captura de Tela Realizada" \
          "Salvo em <i>Pictures/Screenshots</i> e copiado para a área de transferência." \
          --action="open,Visualizar" \
          --action="folder,Abrir Pasta" \
          --action="delete,Excluir" 2>/dev/null || echo "")

        case "$action" in
          open) ${pkgs.xdg-utils}/bin/xdg-open "$1" 2>/dev/null || ${pkgs.feh}/bin/feh "$1" & ;;
          folder) ${pkgs.xdg-utils}/bin/xdg-open "$dir" 2>/dev/null || ${fmCmd} "$dir" & ;;
          delete) rm -f "$1" && ${pkgs.dunst}/bin/dunstify -a "Screenshot" -u low -t 1500 "Captura excluída" ;;
        esac
      fi
    }

    get_focused_monitor_geo() {
      ${pkgs.bspwm}/bin/bspc query -T -m pointed 2>/dev/null | ${pkgs.jq}/bin/jq -r '.rectangle | "\(.width)x\(.height)+\(.x)+\(.y)"' 2>/dev/null
    }

    case "$1" in
      full|--now)
        # Captura apenas o monitor onde o cursor do mouse está (sem barras pretas multi-monitor)
        geo=$(get_focused_monitor_geo)
        if [ -n "$geo" ] && [ "$geo" != "null" ]; then
          ${pkgs.maim}/bin/maim -g "$geo" "$file" 2>/dev/null || ${pkgs.maim}/bin/maim "$file"
        else
          ${pkgs.maim}/bin/maim "$file"
        fi
        notify_shot "$file"
        ;;

      all|--all)
        # Captura todos os monitores combinados
        ${pkgs.maim}/bin/maim "$file"
        notify_shot "$file"
        ;;

      area|--sel|-s)
        # Seleção interativa retangular
        sleep 0.2
        # Desativa temporariamente o picom durante o recorte para garantir 100% que a tela fique limpa e sem nenhum blur
        was_picom=0
        if ${pkgs.procps}/bin/pgrep -x picom >/dev/null 2>&1; then
          was_picom=1
          ${pkgs.procps}/bin/pkill -x picom 2>/dev/null || true
          sleep 0.05
        fi

        ${pkgs.maim}/bin/maim -s -u "$file" 2>/dev/null
        ret=$?

        # Restaura o compositor imediatamente após o recorte (ou cancelamento com Esc)
        if [ "$was_picom" -eq 1 ]; then
          (${picomBin} -b 2>/dev/null || ${pkgs.picom}/bin/picom -b 2>/dev/null || true) &
        fi

        [ "$ret" -eq 0 ] && notify_shot "$file"
        ;;

      window|--win|-w)
        # Captura a janela atualmente focada
        sleep 0.2
        active_win=$(${pkgs.bspwm}/bin/bspc query -N -n focused 2>/dev/null)
        if [ -n "$active_win" ]; then
          ${pkgs.maim}/bin/maim -i "$active_win" "$file" 2>/dev/null && notify_shot "$file"
        else
          $0 area
        fi
        ;;

      in3|--in3)
        # Temporizador de 3 segundos com contagem regressiva OSD
        for sec in 3 2 1; do
          ${pkgs.dunst}/bin/dunstify -a "Screenshot" -u low -t 950 -h string:x-dunst-stack-tag:screenshot-timer "Captura em..." "$sec segundo(s)"
          sleep 1
        done
        ${pkgs.dunst}/bin/dunstify -a "Screenshot" -u low -t 500 -h string:x-dunst-stack-tag:screenshot-timer "Capturando..." "Sorria! 📸"
        sleep 0.2
        geo=$(get_focused_monitor_geo)
        if [ -n "$geo" ] && [ "$geo" != "null" ]; then
          ${pkgs.maim}/bin/maim -g "$geo" "$file" 2>/dev/null || ${pkgs.maim}/bin/maim "$file"
        else
          ${pkgs.maim}/bin/maim "$file"
        fi
        notify_shot "$file"
        ;;

      in5|--in5)
        # Temporizador de 5 segundos com contagem regressiva OSD
        for sec in 5 4 3 2 1; do
          ${pkgs.dunst}/bin/dunstify -a "Screenshot" -u low -t 950 -h string:x-dunst-stack-tag:screenshot-timer "Captura em..." "$sec segundo(s)"
          sleep 1
        done
        ${pkgs.dunst}/bin/dunstify -a "Screenshot" -u low -t 500 -h string:x-dunst-stack-tag:screenshot-timer "Capturando..." "Sorria! 📸"
        sleep 0.2
        geo=$(get_focused_monitor_geo)
        if [ -n "$geo" ] && [ "$geo" != "null" ]; then
          ${pkgs.maim}/bin/maim -g "$geo" "$file" 2>/dev/null || ${pkgs.maim}/bin/maim "$file"
        else
          ${pkgs.maim}/bin/maim "$file"
        fi
        notify_shot "$file"
        ;;

      menu|--menu|*)
        OPT_FULL="󰹑  Monitor Atual           (Imediato)"
        OPT_AREA="󰆞  Recorte de Área         (Seleção com cursor)"
        OPT_WIN="󰖲  Janela Ativa            (Focada)"
        OPT_IN3="󱎫  Temporizador (3s)       (Contagem rápida)"
        OPT_IN5="󱎫  Temporizador (5s)       (Contagem regressiva)"
        OPT_ALL="󰍹  Todos os Monitores      (Canvas completo)"
        OPT_DIR="󰈊  Abrir Pasta de Capturas (~/Pictures/Screenshots)"

        CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s" \
          "$OPT_FULL" \
          "$OPT_AREA" \
          "$OPT_WIN" \
          "$OPT_IN3" \
          "$OPT_IN5" \
          "$OPT_ALL" \
          "$OPT_DIR" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰹑 Screenshot " -theme-str 'window { width: 560px; height: 350px; } listview { columns: 1; lines: 7; }')

        case "$CHOICE" in
          *"Monitor Atual"*) $0 full ;;
          *"Recorte de Área"*) sleep 0.2 && $0 area ;;
          *"Janela Ativa"*) sleep 0.2 && $0 window ;;
          *"Temporizador (3s)"*) $0 in3 ;;
          *"Temporizador (5s)"*) $0 in5 ;;
          *"Todos os Monitores"*) $0 all ;;
          *"Abrir Pasta"*) ${pkgs.xdg-utils}/bin/xdg-open "$dir" 2>/dev/null || ${fmCmd} "$dir" & ;;
        esac
        ;;
    esac
  '';

  isAppleKeyboard =
    (config.home.keyboard.model or "") == "apple"
    || (config.home.keyboard.model or "") == "macbook";

  effectiveScreenshotProfile =
    if cfg.screenshotProfile != "auto" then
      cfg.screenshotProfile
    else if isAppleKeyboard then
      "mac"
    else
      "standard";

  screenshotBindings =
    if effectiveScreenshotProfile == "none" then
      { }
    else if effectiveScreenshotProfile == "custom" then
      cfg.screenshotKeybindings
    else if effectiveScreenshotProfile == "mac" then
      {
        # --- Perfil macOS (MacBook Pro / Air e teclados Apple sem tecla Print física) ---
        # Super + Shift + 3: captura imediata da tela inteira (estilo macOS)
        "${mod} + shift + 3" = "${screenshotScript} full";
        # Super + Shift + 4: recorte interativo de área retangular com seleção visual
        "${mod} + shift + 4" = "${screenshotScript} area";
        # Super + Shift + 5: abre o menu interativo com todas as opções de captura
        "${mod} + shift + 5" = "${screenshotScript} menu";
        # Tecla Print dedicada (se disponível): captura de tela inteira
        "Print" = "${screenshotScript} full";
        # Shift + Print: recorte de área
        "shift + Print" = "${screenshotScript} area";
        # Ctrl + Print: captura da janela ativa
        "ctrl + Print" = "${screenshotScript} window";
        # Super + Shift + S: atalho de teclado moderno / tecla Print de notebooks
        "super + shift + s" = "${screenshotScript} menu";
        # Tecla de hardware de captura seletiva
        "XF86SelectiveScreenshot" = "${screenshotScript} area";
      }
      // lib.optionalAttrs (mod != "super") {
        "${mod} + shift + s" = "${screenshotScript} area";
      }
    else
      {
        # --- Perfil Standard / PC (Acer Nitro, PCs desktop, VMs, etc.) ---
        # Print / PrtSc: captura imediata da tela do monitor onde está o cursor
        "Print" = "${screenshotScript} full";
        # Shift + Print: recorte interativo de área retangular com seleção visual
        "shift + Print" = "${screenshotScript} area";
        # Ctrl + Print: captura apenas a janela atualmente em foco
        "ctrl + Print" = "${screenshotScript} window";
        # Super + Shift + Print: captura com contagem regressiva de 5 segundos
        "${mod} + shift + Print" = "${screenshotScript} in5";
        # Super + Print: menu completo interativo no Rofi (ScreenShoTer)
        "${mod} + Print" = "${screenshotScript} menu";

        # Sys_Req: tratamento para teclados de notebook onde PrtSc emite Sys_Req no X11
        "Sys_Req" = "${screenshotScript} full";
        # Shift + Sys_Req: recorte de área via Sys_Req
        "shift + Sys_Req" = "${screenshotScript} area";

        # Super + Shift + S: tecla Print em notebooks modernos (cujo firmware emite Win+Shift+S)
        "super + shift + s" = "${screenshotScript} menu";
        # Tecla de hardware de captura seletiva (Fn + PrtSc)
        "XF86SelectiveScreenshot" = "${screenshotScript} area";
      }
      // lib.optionalAttrs (mod != "super") {
        "${mod} + shift + s" = "${screenshotScript} area";
      };

  normMod =
    let
      k = lib.toLower (cfg.modifierKey or "super");
    in
    if k == "super" || k == "mod4" then
      "Super"
    else if k == "alt" || k == "mod1" then
      "Alt"
    else if k == "ctrl" || k == "control" then
      "Ctrl"
    else
      "Super";

  mod =
    if normMod == "Alt" then
      "alt"
    else if normMod == "Ctrl" then
      "ctrl"
    else
      "super";

  ctrlMod = if mod == "ctrl" then "super" else "ctrl";
  modDisplayName = normMod; # "Super", "Alt", "Ctrl"

  # --- Script de Notificação de Volume Suave (Estilo gh0stzk / Catppuccin) ---
  volumeOsd = pkgs.writeShellScript "volume-osd" ''
    case "$1" in
      up)
        ${pkgs.pamixer}/bin/pamixer --allow-boost --set-limit 150 -i 2 2>/dev/null || {
          if command -v pactl >/dev/null 2>&1; then
            curr_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o -E '[0-9]+%' | head -n1 | tr -d '%')
            if [ -n "$curr_vol" ] && [ "$curr_vol" -lt 150 ]; then
              next_vol=$(( curr_vol + 2 ))
              [ "$next_vol" -gt 150 ] && next_vol=150
              pactl set-sink-volume @DEFAULT_SINK@ "$next_vol%" 2>/dev/null || true
            fi
          fi
        }
        ;;
      down)
        ${pkgs.pamixer}/bin/pamixer -d 2 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ -2% 2>/dev/null || true
        ;;
      mute)
        ${pkgs.pamixer}/bin/pamixer -t 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null || true
        ;;
    esac

    vol=$(${pkgs.pamixer}/bin/pamixer --get-volume 2>/dev/null)
    is_muted=$(${pkgs.pamixer}/bin/pamixer --get-mute 2>/dev/null || echo "false")
    if [ -z "$vol" ] && command -v pactl >/dev/null 2>&1; then
      vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o -E '[0-9]+%' | head -n1 | tr -d '%')
      pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -qi "yes" && is_muted="true"
    fi
    [ -z "$vol" ] && vol="0"

    if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
      icon="audio-volume-muted"
      text="Volume: Mudo"
      bar_val=0
    else
      if [ "$vol" -lt 30 ]; then
        icon="audio-volume-low"
      elif [ "$vol" -lt 70 ]; then
        icon="audio-volume-medium"
      else
        icon="audio-volume-high"
      fi
      text="Volume: $vol%"
      bar_val=$(( vol * 100 / 150 ))
      [ "$bar_val" -gt 100 ] && bar_val=100
    fi

    ${pkgs.dunst}/bin/dunstify -a "OSD" \
      -u low \
      -i "$icon" \
      -h string:x-dunst-stack-tag:volume \
      -h int:value:"$bar_val" \
      -t 1500 \
      "$text"
  '';

  # --- Script de Notificação de Brilho da Tela Suave (Estilo gh0stzk / Catppuccin) ---
  brightnessOsd = pkgs.writeShellScript "brightness-osd" ''
    # Identificar dispositivo de tela real (priorizar intel_backlight > nv_backlight > apple_backlight > acpi_video0)
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

    dev_args=()
    if [ -n "$dev" ]; then
      dev_args=(-d "$dev")
    fi

    case "$1" in
      up)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set +2% >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set +1 >/dev/null 2>&1
        fi
        ;;
      down)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set 2%- >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set 1- >/dev/null 2>&1
        fi
        ;;
    esac

    val=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
    if [ -n "$val" ]; then
      if [ "$val" -lt 33 ]; then
        icon="display-brightness-low"
      elif [ "$val" -lt 66 ]; then
        icon="display-brightness-medium"
      else
        icon="display-brightness-high"
      fi

      ${pkgs.dunst}/bin/dunstify -a "OSD" \
        -u low \
        -i "$icon" \
        -h string:x-dunst-stack-tag:brightness \
        -h int:value:"$val" \
        -t 1500 \
        "Brilho da Tela: $val%"
    fi
  '';

  # --- Script de Controle de Mídia com Feedback Visual OSD (Estilo gh0stzk MediaControl) ---
  mediaControl = pkgs.writeShellScript "bspwm-media-control" ''
    case "$1" in
      play-pause) ${pkgs.playerctl}/bin/playerctl play-pause 2>/dev/null ;;
      next)       ${pkgs.playerctl}/bin/playerctl next 2>/dev/null ;;
      prev)       ${pkgs.playerctl}/bin/playerctl previous 2>/dev/null ;;
      stop)       ${pkgs.playerctl}/bin/playerctl stop 2>/dev/null ;;
    esac

    sleep 0.1
    status=$(${pkgs.playerctl}/bin/playerctl status 2>/dev/null || echo "Parado")
    track_info=$(${pkgs.playerctl}/bin/playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null || true)

    case "$status" in
      Playing)   icon="media-playback-start"; header="Reproduzindo" ;;
      Paused)    icon="media-playback-pause"; header="Pausado" ;;
      *)         icon="media-playback-stop";  header="Reprodutor" ;;
    esac

    if [ -n "$track_info" ] && [ "$track_info" != " - " ]; then
      ${pkgs.dunst}/bin/dunstify -a "Mídia" \
        -u low \
        -i "$icon" \
        -h string:x-dunst-stack-tag:media \
        -t 2000 \
        "$header" \
        "<b>$track_info</b>"
    fi
  '';

  # --- Conta-gotas / Seletor de Cores Dinâmico (Estilo gh0stzk Colorpicker) ---
  colorPickerScript = pkgs.writeShellScript "bspwm-colorpicker" ''
    color=$(${pkgs.xcolor}/bin/xcolor -s 2>/dev/null || true)
    [ -z "$color" ] && exit 0

    echo -n "$color" | ${pkgs.xclip}/bin/xclip -selection clipboard

    ${pkgs.dunst}/bin/dunstify -a "Colorpicker" \
      -u low \
      -i "color-picker" \
      -h string:x-dunst-stack-tag:colorpicker \
      -t 3500 \
      "Cor Capturada" \
      "Código: <b>$color</b> copiado para a área de transferência!"
  '';

  # --- Script de Controle e Notificação de Luz do Teclado (Logitech MX Keys / MacBook / Laptops) ---
  kbdBrightnessOsd = pkgs.writeShellScript "kbd-brightness-osd" ''
    # 1. Identificar dispositivo de iluminação de teclado via brightnessctl
    dev=""
    for candidate in "smc::kbd_backlight" "apple::kbd_backlight" "dell::kbd_backlight" "asus::kbd_backlight" "tpacpi::kbd_backlight"; do
      if ${pkgs.brightnessctl}/bin/brightnessctl -d "$candidate" info >/dev/null 2>&1; then
        dev="$candidate"
        break
      fi
    done

    if [ -z "$dev" ]; then
      dev=$(${pkgs.brightnessctl}/bin/brightnessctl --list 2>/dev/null | grep -E -m1 "kbd_backlight|keyboard" | cut -d\' -f2 || true)
    fi

    if [ -n "$dev" ]; then
      case "$1" in
        up)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +5% >/dev/null 2>&1 || ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          fi
          ;;
        down)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 5%- >/dev/null 2>&1 || ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 1- >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 1- >/dev/null 2>&1
          fi
          ;;
        toggle)
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
          if [ "$curr" -gt 0 ] 2>/dev/null; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 0%
          else
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 50%
          fi
          ;;
      esac

      val=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
      if [ -n "$val" ]; then
        ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -h int:value:"$val" -t 1500 "Luz do Teclado: $val%"
      fi
    else
      # 2. Teclados externos (Logitech MX Keys / sem interface direta em /sys/class/leds)
      SOLAAR_CMD=""
      if command -v solaar >/dev/null 2>&1; then
        SOLAAR_CMD="solaar"
      elif [ -x "${pkgs.solaar}/bin/solaar" ]; then
        SOLAAR_CMD="${pkgs.solaar}/bin/solaar"
      fi

      if [ -n "$SOLAAR_CMD" ]; then
        case "$1" in
          up|toggle)
            "$SOLAAR_CMD" config "MX Keys" backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight true 2>/dev/null || true
            ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Aumentar / Ativada"
            ;;
          down)
            "$SOLAAR_CMD" config "MX Keys" backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight false 2>/dev/null || true
            ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Diminuir / Desativada"
            ;;
        esac
      else
        case "$1" in
          up)   ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F4 / MX Keys): Aumentar" ;;
          down) ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F3 / MX Keys): Diminuir" ;;
          toggle) ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Alternar" ;;
        esac
      fi
    fi
  '';

  # Script nativo de alternância de Pseudo-Tiling com notificação visual OSD
  pseudoTileScript = pkgs.writeShellScript "bspwm-toggle-pseudo-tile" ''
    export PATH="${lib.makeBinPath [ pkgs.bspwm pkgs.dunst pkgs.jq pkgs.coreutils ]}:$PATH"

    target="focused"
    action="toggle"

    case "''${1:-}" in
      on|enable|--on|--enable)
        action="on"
        ;;
      off|disable|--off|--disable)
        action="off"
        ;;
      status|--status|-s)
        action="status"
        ;;
      toggle|--toggle|"")
        action="toggle"
        ;;
      0x*|[0-9]*)
        target="$1"
        case "''${2:-}" in
          on|enable) action="on" ;;
          off|disable) action="off" ;;
          status) action="status" ;;
          *) action="toggle" ;;
        esac
        ;;
    esac

    # Validar se há janela válida focada ou selecionada
    wid=$(bspc query -N -n "$target.window" 2>/dev/null || bspc query -N -n "focused.window" 2>/dev/null)
    if [ -z "$wid" ]; then
      exit 0
    fi

    if [ "$action" = "status" ]; then
      state=$(bspc query -T -n "$wid" 2>/dev/null | jq -r '.client.state // empty' 2>/dev/null)
      echo "''${state:-unknown}"
      exit 0
    elif [ "$action" = "on" ]; then
      bspc node "$wid" -t pseudo_tiled 2>/dev/null || true
    elif [ "$action" = "off" ]; then
      bspc node "$wid" -t tiled 2>/dev/null || true
    else
      bspc node "$wid" -t '~pseudo_tiled' 2>/dev/null || true
    fi

    state=$(bspc query -T -n "$wid" 2>/dev/null | jq -r '.client.state // empty' 2>/dev/null)
    if [ "$state" = "pseudo_tiled" ]; then
      dunstify -a "BSPWM" -u low -i "view-restore" -h string:x-dunst-stack-tag:window-state -r 9994 -t 1500 "󱒆 Janela: Pseudo-Tiled" "Janela em grade preservando dimensões naturais" 2>/dev/null || true
    else
      dunstify -a "BSPWM" -u low -i "view-grid" -h string:x-dunst-stack-tag:window-state -r 9994 -t 1500 "󰄬 Janela: Tiled" "Modo tiling em grade completa restaurado" 2>/dev/null || true
    fi
  '';

  # --- Dashboard Unificado: Quick Settings + Manual de Atalhos (Estilo Hyprland) ---
  quickSettings = pkgs.writeShellScript "quick-settings" ''
        show_manual() {
          KB_LIST="󰌌  ${modDisplayName} + Space / ${modDisplayName} + D     ➜  Lançador de Aplicativos (Rofi)
    󰌌  ${modDisplayName} + Enter / ${modDisplayName} + T     ➜  Abrir Terminal (${termDisplayName})
    󰌌  ${modDisplayName} + B                     ➜  Navegador Web Padrão
    󰌌  ${modDisplayName} + Shift + B             ➜  Menu Interativo de Bluetooth
    󰌌  ${modDisplayName} + E / ${modDisplayName} + Shift + E ➜  Gerenciador de Arquivos (''${fmName})
    󰌌  ${modDisplayName} + , / ${modDisplayName} + C / Botão Dir. ➜ Painel Quick Settings / Preferências
    󰌌  ${modDisplayName} + / ou ${modDisplayName} + F1       ➜  Manual e Guia de Atalhos (Cheat-Sheet)
    󰌌  ${modDisplayName} + W                     ➜  Alternador de Janelas Abertas
    󰌌  ${modDisplayName} + U                     ➜  Terminal Flutuante Rápido (Scratchpad)
    󰌌  ${modDisplayName} + Q / ${modDisplayName} + Shift + Q ➜  Fechar / Encerrar Janela
    󰌌  ${modDisplayName} + Shift + Escape        ➜  Forçar Fechamento de Janela Travada
    󰌌  ${modDisplayName} + A                     ➜  Alternar Tela Cheia (Fullscreen)
    󰌌  ${modDisplayName} + F / ${modDisplayName} + S ➜  Alternar Janela Flutuante (Floating/Tiling)
    󰌌  ${modDisplayName} + Shift + F / Shift + T ➜  Alternar Janela Pseudo-Tiled (Grade com Tamanho Natural)
    󰌌  ${modDisplayName} + M                     ➜  Modo Monocle (Foco em Janela Única)
    󰌌  ${modDisplayName} + Y / ${modDisplayName} + Minus     ➜  Esconder / Minimizar Janela Ativa
    󰌌  ${modDisplayName} + Shift + Y / Shift+-  ➜  Restaurar Última Janela Escondida
    󰌌  ${modDisplayName} + Shift + M            ➜  Mostrar Desktop (Minimizar/Restaurar Todas)
    󰌌  ${modDisplayName} + Tab / Shift + Tab       ➜  Alternar Foco Entre Janelas (Próxima/Anterior)
    󰌌  ${modDisplayName} + ` (Grave) / Shift + `   ➜  Alternar Foco Entre Janelas (Próxima/Anterior)
    󰌌  ${modDisplayName} + Ctrl + Tab / Shift+Tab  ➜  Trocar Janela com Próxima / Anterior (Swap)
    󰌌  ${modDisplayName} + Ctrl + Space           ➜  Ciclar Layouts (Tall, Wide, Grid, Even, Monocle...)
    󰌌  ${modDisplayName} + Ctrl + L               ➜  Menu Interativo de Layouts (bsp-layout)
    󰌌  ${modDisplayName} + {H,J,K,L} ou Setas    ➜  Navegar Foco Entre Janelas (Vim/Setas)
    󰌌  ${modDisplayName} + Shift + {H,J,K,L}     ➜  Mover / Trocar Posição da Janela
    󰌌  ${modDisplayName} + Ctrl + Setas          ➜  Redimensionar Tamanho da Janela
    󰌌  ${modDisplayName} + Botão Esquerdo        ➜  Mover Janela Flutuante com o Mouse
    󰌌  ${modDisplayName} + Botão Direito         ➜  Redimensionar Janela com o Mouse
    󰌌  ${modDisplayName} + 1..9, 0               ➜  Ir para Área de Trabalho (Workspace) 1 a 10
    󰌌  ${modDisplayName} + Shift + 1..9, 0       ➜  Enviar Janela para Workspace 1 a 10
    󰌌  ${modDisplayName} + Ctrl + 1..9, 0        ➜  Enviar Janela sem Seguir (Segundo Plano)
    󰌌  Print / ${modDisplayName} + Print         ➜  Captura Imediata / Menu ScreenShoTer
    󰌌  Shift + Print / ${modDisplayName} + Shift + S ➜  Recorte de Área Interativo
    󰌌  Ctrl + Print                              ➜  Capturar Janela Ativa
    󰌌  ${modDisplayName} + Shift + Print         ➜  Captura com Temporizador (5s)
    󰌌  ${modDisplayName} + P                     ➜  Conta-gotas de Cor (Colorpicker)
    󰌌  ${modDisplayName} + Shift + R             ➜  Recarregar BSPWM e Polybar
    󰌌  ${modDisplayName} + Shift + L / ${modDisplayName} + Ctrl + Q ➜ Bloquear Sessão do Usuário
    󰌌  Teclas de Volume / Brilho / Mídia ➜  Controle com Feedback Visual OSD"

          CHOICE=$(echo "$KB_LIST" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰌌 Manual de Atalhos (Keybinds) " -theme-str 'window { width: 720px; height: 520px; } listview { columns: 1; lines: 12; }')

          case "$CHOICE" in
            *"Lançador de Aplicativos"*) ${pkgs.rofi}/bin/rofi -show drun ;;
            *"Abrir Terminal"*) ${termCmd} & ;;
            *"Navegador Web Padrão"*) ${browserLaunchCmd} ;;
            *"Menu Interativo de Bluetooth"*) rofi-bluetooth & ;;
            *"Gerenciador de Arquivos"*) ''${fmCmd} ~ & ;;
            *"Painel Quick Settings"*) show_control_center ;;
            *"Alternador de Janelas"*) ${pkgs.rofi}/bin/rofi -show window ;;
            *"Alternar Foco Entre Janelas"*) bspc node -f next.local.!hidden.window || bspc node -f next.local.window ;;
            *"Menu Interativo de Layouts"*) rofi-bsp-layout & ;;
            *"Ciclar Layouts"*) bsp-layout-switch next & ;;
            *"Terminal Flutuante"*) ${scratchpadScript} ;;
            *"Fechar / Encerrar Janela"*) bspc node -c ;;
            *"Tela Cheia"*) bspc node -t '~fullscreen' ;;
            *"Janela Flutuante"*) bspc node -t '~floating' ;;
            *"Pseudo-Tiled"*|*"Pseudo-tiled"*) ${pseudoTileScript} ;;
            *"Esconder / Minimizar Janela"*) bspc node -g hidden=on ;;
            *"Restaurar Última Janela"*) bspc node any.hidden.local -g hidden=off -f ;;
            *"Captura de Tela"*) ${screenshotScript} menu & ;;
            *"Recorte de Área"*) ${screenshotScript} area & ;;
            *"Conta-gotas"*) ${colorPickerScript} & ;;
            *"Recarregar BSPWM"*) bspc wm -r ;;
            *"Bloquear Sessão"*) bspwm-lock || loginctl lock-session ;;
          esac
        }

        show_control_center() {
          OPT_SHOT="󰹑  Captura de Tela & Recorte (ScreenShoTer)"
          OPT_COLOR="󰈊  Conta-gotas de Cor (Colorpicker)"
          OPT_BT="󰂯  Dispositivos Bluetooth (rofi-bluetooth)"
          OPT_LAYOUT="󰕰  Gerenciador de Layouts (rofi-bsp-layout)"
          OPT_PSEUDO="󱒆  Alternar Janela Pseudo-Tiled (Pseudo-Tiling)"
          OPT_RES="󰍹  Resolução da Tela (Display Resolution)"
          OPT_TOUCH="󰟸  Velocidade do Touchpad (Touchpad Speed)"
          OPT_SOUND="󰕾  Controle de Áudio & Volume (Pavucontrol)"
          OPT_NET="󰖩  Wi-Fi & Conexões (NetworkManager)"
          OPT_THEME="󰔎  Aparência, Ícones & Temas (LXAppearance)"
          OPT_WALL="󰸉  Papel de Parede (Wallpaper)"
          OPT_BROWSER="󰈹  Navegador Web (Firefox / Padrão)"
          OPT_FILES="󰉋  Gerenciador de Arquivos (''${fmName})"
          OPT_TERM="󰞷  Abrir Terminal (${termDisplayName})"
          OPT_KEYS="󰌌  Manual & Guia de Atalhos (Keybinds)"
          OPT_RELOAD="󰑐  Recarregar BSPWM & Polybar"
          OPT_POWER="󰐥  Menu de Energia & Bloqueio de Sessão"

          CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s" \
            "$OPT_SHOT" \
            "$OPT_COLOR" \
            "$OPT_BT" \
            "$OPT_LAYOUT" \
            "$OPT_PSEUDO" \
            "$OPT_RES" \
            "$OPT_TOUCH" \
            "$OPT_SOUND" \
            "$OPT_NET" \
            "$OPT_THEME" \
            "$OPT_WALL" \
            "$OPT_BROWSER" \
            "$OPT_FILES" \
            "$OPT_TERM" \
            "$OPT_KEYS" \
            "$OPT_RELOAD" \
            "$OPT_POWER" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󱗼 Quick Settings " \
            -theme-str 'window {width: 620px; border-radius: 14px;} listview {columns: 1; lines: 17;}')

          case "$CHOICE" in
            "$OPT_SHOT") ${screenshotScript} menu & ;;
            "$OPT_COLOR") ${colorPickerScript} & ;;
            "$OPT_BT") rofi-bluetooth & ;;
            "$OPT_LAYOUT") rofi-bsp-layout & ;;
            "$OPT_PSEUDO") ${pseudoTileScript} ;;
            "$OPT_RES")
              R_1080="1920x1080 (Full HD 1080p)"
              R_2K="2560x1440 (Quad HD 2K)"
              R_900="1600x900 (HD+)"
              R_768="1366x768 (HD)"
              R_CUSTOM="⚙ Painel Avançado de Telas (ARandR)"

              RES=$(printf "%s\n%s\n%s\n%s\n%s" "$R_1080" "$R_2K" "$R_900" "$R_768" "$R_CUSTOM" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰍹 Selecionar Resolução " -theme-str 'window {width: 500px; border-radius: 14px;} listview {columns: 1; lines: 5;}')
              case "$RES" in
                "$R_1080") ${pkgs.xrandr}/bin/xrandr -s 1920x1080 ;;
                "$R_2K")   ${pkgs.xrandr}/bin/xrandr -s 2560x1440 ;;
                "$R_900")  ${pkgs.xrandr}/bin/xrandr -s 1600x900 ;;
                "$R_768")  ${pkgs.xrandr}/bin/xrandr -s 1366x768 ;;
                "$R_CUSTOM") ${pkgs.arandr}/bin/arandr || ${pkgs.xrandr}/bin/xrandr ;;
              esac
              ;;
            "$OPT_TOUCH")
              T_DEF="󰟸  0.0  (Padrão do Sistema / Lento)"
              T_MOD="󰟸  0.3  (Moderado)"
              T_FAST="󰟸  0.5  (Rápido & Ágil - Recomendado)"
              T_VFAST="󰟸  0.7  (Muito Rápido)"
              T_MAX="󰟸  1.0  (Velocidade Máxima)"
              T_SEL=$(printf "%s\n%s\n%s\n%s\n%s" "$T_DEF" "$T_MOD" "$T_FAST" "$T_VFAST" "$T_MAX" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰟸 Velocidade do Touchpad " -theme-str 'window {width: 540px; border-radius: 14px;} listview {columns: 1; lines: 5;}')
              case "$T_SEL" in
                *"0.0"*) touchpad-speed 0.0 ;;
                *"0.3"*) touchpad-speed 0.3 ;;
                *"0.5"*) touchpad-speed 0.5 ;;
                *"0.7"*) touchpad-speed 0.7 ;;
                *"1.0"*) touchpad-speed 1.0 ;;
              esac
              ;;
            "$OPT_SOUND") ${pkgs.pavucontrol}/bin/pavucontrol & ;;
            "$OPT_NET") ${pkgs.networkmanagerapplet}/bin/nm-connection-editor & ;;
            "$OPT_THEME") ${pkgs.lxappearance}/bin/lxappearance & ;;
            "$OPT_WALL")
              if command -v set-wallpaper >/dev/null 2>&1; then
                set-wallpaper --random &
              elif [ -x "${pkgs.nitrogen}/bin/nitrogen" ]; then
                ${pkgs.nitrogen}/bin/nitrogen &
              else
                ${pkgs.feh}/bin/feh &
              fi
              ;;
            "$OPT_BROWSER")
              if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || ${pkgs.firefox}/bin/firefox & fi
              ;;
            "$OPT_FILES") ''${fmCmd} ~ & ;;
            "$OPT_TERM") ${termCmd} & ;;
            "$OPT_KEYS") show_manual ;;
            "$OPT_RELOAD")
              bspc wm -r
              ${pkgs.dunst}/bin/dunstify -a "Sistema" -u low -i "view-refresh" -t 2000 "BSPWM e Polybar recarregados com sucesso!"
              ;;
            "$OPT_POWER")
              ${pkgs.rofi}/bin/rofi -show power-menu -modi "power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu" || bspwm-lock || loginctl lock-session
              ;;
          esac
        }

        case "$1" in
          --manual) show_manual ;;
          *) show_control_center ;;
        esac
  '';

  # Script universal de foco de workspace (funciona tanto em monitor único quanto em multi-monitor)
  desktopFocusScript = pkgs.writeShellScript "bspwm-desktop-focus" ''
    BSPC="${pkgs.bspwm}/bin/bspc"
    d="$1"
    # 1. Tenta focar diretamente no monitor atual
    $BSPC desktop -f "$d" 2>/dev/null && exit 0
    # 2. Se o workspace estiver em outro monitor, localiza o monitor e foca
    for m in $($BSPC query -M --names 2>/dev/null); do
      if $BSPC query -D -m "$m" --names 2>/dev/null | grep -qx "$d"; then
        $BSPC monitor -f "$m" 2>/dev/null && $BSPC desktop -f "$d" 2>/dev/null
        exit 0
      fi
    done
  '';

  # Script universal de envio de janela para workspace (funciona tanto em monitor único quanto em multi-monitor)
  desktopNodeScript = pkgs.writeShellScript "bspwm-node-to-desktop" ''
    BSPC="${pkgs.bspwm}/bin/bspc"
    d="$1"
    follow="$2"

    # Verifica se há janela focada
    cur_node=$($BSPC query -N -n focused 2>/dev/null)
    [ -z "$cur_node" ] && exit 0

    # Verifica se o desktop de destino existe
    if ! $BSPC query -D -d "$d" --names >/dev/null 2>&1; then
      exit 1
    fi

    # Envia a janela para o workspace de destino
    $BSPC node "$cur_node" -d "$d"

    if [ "$follow" = "true" ]; then
      # Localiza o monitor onde o desktop de destino está e foca o monitor, o desktop e a janela
      for m in $($BSPC query -M --names 2>/dev/null); do
        if $BSPC query -D -m "$m" --names 2>/dev/null | grep -qx "$d"; then
          $BSPC monitor -f "$m" 2>/dev/null
          break
        fi
      done
      $BSPC desktop -f "$d" 2>/dev/null
      $BSPC node "$cur_node" -f 2>/dev/null
    fi
  '';

  # Script para tratar clique com botão direito no desktop sem interferir em aplicações (Thunar, popups, etc.)
  desktopRightClickScript = pkgs.writeShellScript "bspwm-desktop-right-click" ''
    # Identifica a janela X11 sob as coordenadas atuais do cursor do mouse
    mouse_win="$(${pkgs.xdotool}/bin/xdotool getmouselocation --shell 2>/dev/null | awk -F= '/WINDOW/{print $2}')"
    [ -z "$mouse_win" ] && exit 0

    root_win="$(${pkgs.xdotool}/bin/xdotool getrootwindow 2>/dev/null)"

    # Se a janela sob o mouse for exatamente a Root Window (Desktop limpo)
    if [ -n "$root_win" ] && [ "$mouse_win" = "$root_win" ]; then
      exec ${quickSettings}
    fi

    # Se for uma janela com _NET_WM_WINDOW_TYPE_DESKTOP (ex: xfdesktop ou desktop gerenciado)
    if ${pkgs.xprop}/bin/xprop -id "$mouse_win" _NET_WM_WINDOW_TYPE 2>/dev/null | grep -q "_NET_WM_WINDOW_TYPE_DESKTOP"; then
      exec ${quickSettings}
    fi
  '';

  # Script para alternar visibilidade de janelas no workspace ativo (Mostrar Desktop / Restaurar)
  toggleDesktopScript = pkgs.writeShellScript "bspwm-toggle-desktop" ''
    # Busca janelas visíveis (não ocultas) no desktop focado
    visible_nodes=$(${pkgs.bspwm}/bin/bspc query -N -d focused -n .window.!hidden 2>/dev/null)

    if [ -n "$visible_nodes" ]; then
      # Oculta todas as janelas visíveis no workspace
      for node in $visible_nodes; do
        ${pkgs.bspwm}/bin/bspc node "$node" -g hidden=on
      done
    else
      # Se não há janelas visíveis, restaura as que estavam ocultas neste workspace
      hidden_nodes=$(${pkgs.bspwm}/bin/bspc query -N -d focused -n .window.hidden 2>/dev/null)
      last_node=""
      for node in $hidden_nodes; do
        ${pkgs.bspwm}/bin/bspc node "$node" -g hidden=off
        last_node="$node"
      done
      # Restaura o foco para a última janela reexibida
      if [ -n "$last_node" ]; then
        ${pkgs.bspwm}/bin/bspc node "$last_node" -f 2>/dev/null || true
      fi
    fi
  '';
in
{
  options.desktop.bspwm.sxhkd = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable sxhkd keybindings for bspwm";
    };

    modifierKey = mkOption {
      type = lib.types.str;
      default = config.desktop.bspwm.modifierKey or (config.desktop.modifierKey or "Super");
      description = "Tecla modificadora principal do SXHKD (ex: 'super', 'alt', 'ctrl').";
    };

    keybindings = mkOption {
      type = attrsOf str;
      default = { };
      description = "sxhkd keybindings adicionais ou customizadas.";
    };

    extraKeybindings = mkOption {
      type = attrsOf str;
      default = { };
      description = "Atalhos adicionais ou personalizados do SXHKD definidos no host.";
    };

    screenshotProfile = mkOption {
      type = lib.types.enum [
        "auto"
        "standard"
        "mac"
        "custom"
        "none"
      ];
      default = "auto";
      description = ''
        Perfil de teclas de atalho para captura de tela (screenshots):
        - "auto": detecta automaticamente (teclado Apple/Mac usa "mac", outros usam "standard").
        - "standard": ideal para PCs (Acer, Nitro, VMs, etc.) usando Print, Shift+Print, Ctrl+Print. Preserva Super+Shift+1..0 livres para workspaces!
        - "mac": estilo macOS usando Super+Shift+3/4/5 para telas/áreas de captura.
        - "custom": utiliza os atalhos declarados em screenshotKeybindings.
        - "none": desativa os atalhos de screenshot do sxhkd.
      '';
    };

    screenshotKeybindings = mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Mapeamento customizado de atalhos para captura de tela quando screenshotProfile = 'custom'.";
    };
  };

  config = mkIf cfg.enable {
    # Recarregar automaticamente o sxhkd ao rodar switch-home (sem reiniciar o bspwm)
    home.activation.reloadSxhkd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -USR1 -x sxhkd 2>/dev/null || (cd "$HOME" && ${pkgs.sxhkd}/bin/sxhkd &)
    '';

    services.sxhkd = {
      enable = true;
      package = pkgs.sxhkd;
      keybindings =
        {
          # =========================================================================
          # CENTRAL DE CONTROLE, PREFERÊNCIAS E AJUDA
          # =========================================================================
          # Clique com botão direito na área de trabalho vazia (Root Window): abre o painel Quick Settings
          "~button3" = "${desktopRightClickScript}";
          # Super + Botão Direito do mouse: abre o painel Quick Settings
          "${mod} + button3" = "${quickSettings}";
          # Super + Vírgula: atalho universal de Preferências e Painel Quick Settings (estilo macOS/GNOME)
          "${mod} + comma" = "${quickSettings}";
          # Super + C: atalho mnemônico para a Central de Controle (Control Center / Quick Settings)
          "${mod} + c" = "${quickSettings}";
          # Super + /: abre o Manual Interativo de Atalhos (Cheat-Sheet via Rofi)
          "${mod} + slash" = "${quickSettings} --manual";
          # Super + F1: Ajuda do sistema e guia de teclas de atalho
          "${mod} + F1" = "${quickSettings} --manual";

          # =========================================================================
          # FERRAMENTAS DE TELA E CORES
          # =========================================================================
          # Super + P: conta-gotas de cor (Colorpicker) - copia código HEX para a área de transferência
          "${mod} + p" = "${colorPickerScript}";
          # Super + Shift + P: menu completo de captura de tela com opções avançadas (ScreenShoTer via Rofi)
          "${mod} + shift + p" = "${screenshotScript} menu";

          # =========================================================================
          # LANÇADORES DE APLICATIVOS (ESTILO SPOTLIGHT / ROFI)
          # =========================================================================
          # Super + Espaço: menu lançador de aplicativos instalados (Rofi drun)
          "${mod} + space" = "${pkgs.rofi}/bin/rofi -show drun";
          # Super + D: atalho clássico para o lançador de aplicativos (Rofi drun)
          "${mod} + d" = "${pkgs.rofi}/bin/rofi -show drun";
          # Super + Shift + D: executor de comandos de terminal e binários no PATH (Rofi run)
          "${mod} + shift + d" = "${pkgs.rofi}/bin/rofi -show run";

          # Super + B: abre o navegador web padrão (Firefox / LibreWolf)
          "${mod} + b" = browserLaunchCmd;
          # Super + Shift + B: menu interativo de gerenciamento e pareamento Bluetooth (rofi-bluetooth)
          "${mod} + shift + b" = "rofi-bluetooth";

          # Super + Enter: abre o emulador de terminal principal em $HOME
          "${mod} + Return" = termCmd;
          # Super + Enter do Teclado Numérico: abre o emulador de terminal principal
          "${mod} + KP_Enter" = termCmd;
          # Super + T: atalho alternativo para abrir o terminal
          "${mod} + t" = termCmd;

          # Super + E: abre o gerenciador de arquivos padrão (Thunar) em $HOME
          "${mod} + e" = fmCmd;
          # Super + Shift + E: atalho alternativo para o gerenciador de arquivos
          "${mod} + shift + e" = fmCmd;

          # Super + W: alternador visual de janelas ativas em todos os workspaces (Rofi window)
          "${mod} + w" = "${pkgs.rofi}/bin/rofi -show window";

          # Super + U: abre ou oculta o terminal suspenso flutuante rápido (Scratchpad drop-down)
          "${mod} + u" = "${scratchpadScript}";

          # =========================================================================
          # GERENCIAMENTO DE JANELAS (FECHAMENTO E ENCERRAMENTO)
          # =========================================================================
          # Super + Q: fecha a janela ativa normalmente (sinal de fechamento suave)
          "${mod} + q" = "bspc node -c";
          # Super + Shift + Q: força o encerramento imediato do processo da janela (kill)
          "${mod} + shift + q" = "bspc node -k";
          # Super + Shift + Escape: atalho de emergência para matar processo de janela travada
          "${mod} + shift + Escape" = "bspc node -k";

          # =========================================================================
          # ESTADOS DE JANELA (FLUTUANTE / TELA CHEIA / PSEUDO-TILED / MONOCLE)
          # =========================================================================
          # Super + F: alterna a janela entre modo flutuante (floating) e modo grade (tiling)
          "${mod} + f" = "bspc node -t '~floating'";
          # Super + S: atalho alternativo para alternar estado flutuante/tiling
          "${mod} + s" = "bspc node -t '~floating'";
          # Super + A: alterna a janela ativa em modo Tela Cheia (Fullscreen)
          "${mod} + a" = "bspc node -t '~fullscreen'";
          # Super + Shift + F: alterna o modo Pseudo-Tiled (janela na grade mas com tamanho natural original)
          "${mod} + shift + f" = "${pseudoTileScript}";
          # Super + Shift + T: atalho alternativo para o modo Pseudo-Tiled
          "${mod} + shift + t" = "${pseudoTileScript}";
          # Super + M: alterna o layout da área de trabalho atual para Monocle (janela maximizada individual)
          "${mod} + m" = "bspc desktop -l next";

          # =========================================================================
          # CAMADAS E SOBREPOSIÇÃO (PIP / SEMPRE NO TOPO)
          # =========================================================================
          # Super + =: coloca a janela focada na camada superior ('above' - sempre sobre as outras / Picture-in-Picture)
          "${mod} + equal" = "bspc node focused -l above";
          # Super + +: atalho alternativo para fixar a janela no topo
          "${mod} + plus" = "bspc node focused -l above";
          # Super + _: retorna a janela focada para a camada normal de sobreposição
          "${mod} + underscore" = "bspc node focused -l normal";

          # =========================================================================
          # MINIMIZAR / ESCONDER JANELAS E MOSTRAR ÁREA DE TRABALHO
          # =========================================================================
          # Super + Y: esconde/minimiza a janela ativa da tela
          "${mod} + y" = "bspc node -g hidden=on";
          # Super + Menos (-): atalho alternativo para minimizar/esconder a janela ativa
          "${mod} + minus" = "bspc node -g hidden=on";

          # Super + Shift + Y: desoculta e restaura o foco da última janela minimizada
          "${mod} + shift + y" = "bspc node any.hidden.local -g hidden=off -f";
          # Super + Shift + Menos (-): atalho alternativo para restaurar a janela minimizada
          "${mod} + shift + minus" = "bspc node any.hidden.local -g hidden=off -f";

          # Super + Shift + M: Mostrar Área de Trabalho (minimiza todas as janelas do workspace ou restaura todas)
          "${mod} + shift + m" = "${toggleDesktopScript}";

          # =========================================================================
          # BLOQUEIO DE SESSÃO E SEGURANÇA
          # =========================================================================
          # Super + Ctrl + Q: bloqueia a sessão do usuário com a tela de bloqueio
          "${mod} + ${ctrlMod} + q" = "bspwm-lock || loginctl lock-session";
          # Super + Shift + X: atalho alternativo para bloquear a tela
          "${mod} + shift + x" = "bspwm-lock || loginctl lock-session";
          # Super + Shift + L: atalho padrão de bloqueio de tela (Lock Screen)
          "${mod} + shift + l" = "bspwm-lock || loginctl lock-session";
          # Tecla de hardware ScreenSaver: aciona o bloqueador de tela
          "XF86ScreenSaver" = "bspwm-lock || loginctl lock-session";

          # =========================================================================
          # NAVEGAÇÃO E FOCO ENTRE JANELAS
          # =========================================================================
          # Super + H/J/K/L: navega o foco direcional entre janelas (Esquerda, Baixo, Cima, Direita - estilo Vim)
          "${mod} + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
          # Super + Setas: navega o foco direcional entre janelas pelas teclas direcionais
          "${mod} + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
          # Super + Shift + H/J/K/L: move e troca a posição da janela ativa com a janela vizinha (Vim)
          "${mod} + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}";
          # Super + Shift + Setas: move e troca a posição da janela ativa na direção das setas
          "${mod} + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";

          # Super + Tab: cicla o foco para a próxima janela visível no workspace ativo
          "${mod} + Tab" = "bspc node -f next.local.!hidden.window || bspc node -f next.local.window";
          # Super + Shift + Tab: cicla o foco para a janela anterior no workspace ativo
          "${mod} + shift + Tab" = "bspc node -f prev.local.!hidden.window || bspc node -f prev.local.window";
          # Super + `: cicla o foco para a próxima janela (atalho alternativo estilo macOS)
          "${mod} + grave" = "bspc node -f next.local.!hidden.window || bspc node -f next.local.window";
          # Super + Shift + `: cicla o foco para a janela anterior
          "${mod} + shift + grave" = "bspc node -f prev.local.!hidden.window || bspc node -f prev.local.window";
          # Super + \: retorna o foco instantaneamente para a última janela focada anteriormente
          "${mod} + backslash" = "bspc node -f last.local.!hidden.window";

          # Super + Ctrl + Tab: troca a posição física da janela ativa com a próxima janela
          "${mod} + ctrl + Tab" = "bspc node -s next.local.!hidden.window";
          # Super + Ctrl + Shift + Tab: troca a posição física da janela ativa com a janela anterior
          "${mod} + ctrl + shift + Tab" = "bspc node -s prev.local.!hidden.window";
          # Super + Ctrl + `: troca de posição com a próxima janela
          "${mod} + ctrl + grave" = "bspc node -s next.local.!hidden.window";
          # Super + Ctrl + Shift + `: troca de posição com a janela anterior
          "${mod} + ctrl + shift + grave" = "bspc node -s prev.local.!hidden.window";

          # =========================================================================
          # NAVEGAÇÃO AVANÇADA NA ÁRVORE BSP (PAI E IRMÃO)
          # =========================================================================
          # Super + Ctrl + P: move o foco para o nó pai da árvore BSP (@parent)
          "${mod} + ctrl + p" = "bspc node -f @parent";
          # Super + Ctrl + B: move o foco para o nó irmão da árvore BSP (@brother)
          "${mod} + ctrl + b" = "bspc node -f @brother";
          # Super + Ctrl + Shift + P: troca de posição com o nó pai na árvore BSP
          "${mod} + ctrl + shift + p" = "bspc node -s @parent";
          # Super + Ctrl + Shift + B: troca de posição com o nó irmão na árvore BSP
          "${mod} + ctrl + shift + b" = "bspc node -s @brother";

          # =========================================================================
          # GERENCIAMENTO DINÂMICO DE LAYOUTS (BSP-LAYOUT)
          # =========================================================================
          # Super + Ctrl + Espaço: cicla para o próximo layout automático (Tall, Wide, Grid, Even, Monocle)
          "${mod} + ctrl + space" = "bsp-layout-switch next";
          # Super + Ctrl + Shift + Espaço: retorna para o layout anterior
          "${mod} + ctrl + shift + space" = "bsp-layout-switch prev";
          # Super + Ctrl + L: abre menu interativo no Rofi para escolher o layout do workspace
          "${mod} + ctrl + l" = "rofi-bsp-layout";
          # Super + Ctrl + T: aplica diretamente o layout 'Tall' (coluna mestre à esquerda)
          "${mod} + ctrl + t" = "bsp-layout-switch tall";
          # Super + Ctrl + W: aplica diretamente o layout 'Wide' (linha mestre no topo)
          "${mod} + ctrl + w" = "bsp-layout-switch wide";
          # Super + Ctrl + G: aplica diretamente o layout 'Grid' (grade simétrica balanceada)
          "${mod} + ctrl + g" = "bsp-layout-switch grid";
          # Super + Ctrl + E: aplica diretamente o layout 'Even' (divisão perfeitamente igual)
          "${mod} + ctrl + e" = "bsp-layout-switch even";
          # Super + Ctrl + M: aplica diretamente o layout 'Monocle' (janela cheia)
          "${mod} + ctrl + m" = "bsp-layout-switch monocle";
          # Super + Ctrl + R: reseta a organização do workspace para o layout padrão
          "${mod} + ctrl + r" = "bsp-layout-switch reset";

          # =========================================================================
          # MULTI-MONITORES
          # =========================================================================
          # Super + [: move o foco para o monitor anterior
          "${mod} + bracketleft" = "bspc monitor -f prev";
          # Super + ]: move o foco para o próximo monitor
          "${mod} + bracketright" = "bspc monitor -f next";
          # Super + Shift + [: move a janela ativa para o monitor anterior e acompanha o foco
          "${mod} + shift + bracketleft" = "bspc node -m prev --follow";
          # Super + Shift + ]: move a janela ativa para o próximo monitor e acompanha o foco
          "${mod} + shift + bracketright" = "bspc node -m next --follow";

          # =========================================================================
          # ÁREAS DE TRABALHO / WORKSPACES (1 A 10, ONDE 0 É O WORKSPACE 10)
          # =========================================================================
          # Super + [1-9,0]: muda o foco para a área de trabalho 1 a 10
          "${mod} + {1-9,0}" = "${desktopFocusScript} {1-9,0}";
          # Super + Shift + [1-9,0]: move a janela focada para a área 1 a 10 e muda o foco junto (--follow)
          "${mod} + shift + {1-9,0}" = "${desktopNodeScript} {1-9,0} true";
          # Super + Ctrl + [1-9,0]: move a janela para a área 1 a 10 em segundo plano (sem mudar o foco da tela)
          "${mod} + ctrl + {1-9,0}" = "${desktopNodeScript} {1-9,0} false";

          # =========================================================================
          # REDIMENSIONAMENTO DE JANELAS (EXPANDIR / CONTRAIR)
          # =========================================================================
          # Super + Ctrl + Setas: expande ou contrai a janela em 20px na direção das setas
          "${mod} + ctrl + {Left,Down,Up,Right}" =
            "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
          # Super + Ctrl + Shift + H/J/K/L: expande ou contrai a janela em 20px usando as teclas Vim
          "${mod} + ctrl + shift + {h,j,k,l}" =
            "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";

          # =========================================================================
          # REINICIALIZAÇÃO DO AMBIENTE
          # =========================================================================
          # Super + Shift + R: recarrega o BSPWM, reinicia o SXHKD e reabre a Polybar
          "${mod} + shift + r" = "bspc wm -r; ${pkgs.procps}/bin/pkill -USR1 -x sxhkd; polybar-launch &";
          # Super + Escape: recarrega o daemon de atalhos SXHKD sem reiniciar a sessão
          "${mod} + Escape" = "${pkgs.procps}/bin/pkill -USR1 -x sxhkd";

          # =========================================================================
          # CONTROLES DE VOLUME E MÍDIA (COM OSD DUNST)
          # =========================================================================
          # Tecla Volume Up: aumenta o volume em 2% com feedback visual OSD
          "XF86AudioRaiseVolume" = "${volumeOsd} up";
          # Tecla Volume Down: diminui o volume em 2% com feedback visual OSD
          "XF86AudioLowerVolume" = "${volumeOsd} down";
          # Tecla Mute: ativa/desativa o mudo com feedback visual OSD
          "XF86AudioMute" = "${volumeOsd} mute";
          # Tecla Play/Pause: alterna reprodução/pausa de áudio/vídeo
          "XF86AudioPlay" = "${mediaControl} play-pause";
          # Tecla Next: avança para a próxima faixa de mídia
          "XF86AudioNext" = "${mediaControl} next";
          # Tecla Previous: retrocede para a faixa de mídia anterior
          "XF86AudioPrev" = "${mediaControl} prev";
          # Tecla Stop: interrompe a reprodução de mídia
          "XF86AudioStop" = "${mediaControl} stop";

          # =========================================================================
          # CONTROLES DE BRILHO DA TELA
          # =========================================================================
          # Tecla Brilho + (F2 / Fn+F2): aumenta o brilho da tela em 2% com OSD
          "XF86MonBrightnessUp" = "${brightnessOsd} up";
          # Tecla Brilho - (F1 / Fn+F1): diminui o brilho da tela em 2% com OSD
          "XF86MonBrightnessDown" = "${brightnessOsd} down";

          # =========================================================================
          # CONTROLES DE ILUMINAÇÃO DO TECLADO (NOTEBOOKS E LOGITECH MX KEYS)
          # =========================================================================
          # Tecla Hardware Iluminação +: aumenta o brilho do teclado
          "XF86KbdBrightnessUp" = "${kbdBrightnessOsd} up";
          # Tecla Hardware Iluminação -: diminui o brilho do teclado
          "XF86KbdBrightnessDown" = "${kbdBrightnessOsd} down";
          # Tecla Hardware Alternar Luz: liga/desliga a luz do teclado
          "XF86KbdLightOnOff" = "${kbdBrightnessOsd} toggle";

          # Super + F6 (ou Fn+F6 em MacBook): aumenta luz do teclado
          "${mod} + F6" = "${kbdBrightnessOsd} up";
          # Super + F5 (ou Fn+F5 em MacBook): diminui luz do teclado
          "${mod} + F5" = "${kbdBrightnessOsd} down";
          # Super + Shift + F5: alterna luz do teclado
          "${mod} + shift + F5" = "${kbdBrightnessOsd} toggle";

          # Super + F4 (Logitech MX Keys / teclados padrão): aumenta luz do teclado
          "${mod} + F4" = "${kbdBrightnessOsd} up";
          # Super + F3 (Logitech MX Keys / teclados padrão): diminui luz do teclado
          "${mod} + F3" = "${kbdBrightnessOsd} down";
          # Super + Shift + F4: alterna luz do teclado (Logitech MX Keys)
          "${mod} + shift + F4" = "${kbdBrightnessOsd} toggle";
        }
        // screenshotBindings
        // lib.optionalAttrs (config.desktop.bspwm.polybar.enable && config.desktop.bspwm.polybar.tray.enable) {
          # Bandeja do Sistema Stalonetray (oculta/exibe)
          "${mod} + i" = "stalonetray-toggle";
          "${mod} + shift + i" = "stalonetray-toggle";
        }
        // lib.optionalAttrs (mod == "super") {
          # Super + Alt + Setas / H,J,K,L: redimensionamento rápido tradicional de janelas
          "super + alt + {Left,Down,Up,Right}" =
            "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
          "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
        }
        // (config.desktop.bspwm.extraKeybindings or { })
        // cfg.keybindings
        // cfg.extraKeybindings;
    };

    # Utilitários de linha de comando para uso interativo e scripts
    home.packages = [
      (pkgs.writeShellScriptBin "bspwm-pseudo-tile" ''exec ${pseudoTileScript} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-toggle-pseudo-tile" ''exec ${pseudoTileScript} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-screenshot" ''exec ${screenshotScript} "$@"'')
      (pkgs.writeShellScriptBin "screenshoter" ''exec ${screenshotScript} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-colorpicker" ''exec ${colorPickerScript} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-media-control" ''exec ${mediaControl} "$@"'')
    ];
  };
}
