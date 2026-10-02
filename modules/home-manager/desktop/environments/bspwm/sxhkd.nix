{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool attrs;
  cfg = config.desktop.bspwm.sxhkd;
  fmCmd = config.system.programs.file-manager.activeCommand or "file-manager";
  fmName = config.system.programs.file-manager.activeName or "Gerenciador de Arquivos";

  browserBin = config.system.programs.browsers.activeBin or null;
  browserLaunchCmd =
    if browserBin != null then
      "${browserBin} &"
    else
      ''if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || ${pkgs.firefox}/bin/firefox & fi'';

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
        layer=above \
        rectangle="''${WIDTH}x''${HEIGHT}+''${X_POS}+''${Y_POS}" \
        --one-shot

      # Inicia o terminal dedicado com a classe bspwm-scratch
      ${pkgs.alacritty}/bin/alacritty --class "$SCRATCHPAD_NAME,$SCRATCHPAD_NAME" &

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
        ${pkgs.maim}/bin/maim -s -u "$file" 2>/dev/null && notify_shot "$file"
        ;;

      window|--win|-w)
        # Captura a janela atualmente focada
        active_win=$(${pkgs.bspwm}/bin/bspc query -N -n focused 2>/dev/null)
        if [ -n "$active_win" ]; then
          ${pkgs.maim}/bin/maim -i "$active_win" "$file" 2>/dev/null && notify_shot "$file"
        else
          ${pkgs.maim}/bin/maim -s -u "$file" 2>/dev/null && notify_shot "$file"
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
        # Perfil macOS (MacBook Pro / Air, teclados Apple sem tecla Print dedicada)
        "${mod} + shift + 3" = "${screenshotScript} full";
        "${mod} + shift + 4" = "${screenshotScript} area";
        "${mod} + shift + 5" = "${screenshotScript} menu";
        "Print" = "${screenshotScript} full";
        "shift + Print" = "${screenshotScript} area";
        "ctrl + Print" = "${screenshotScript} window";
        "super + shift + s" = "${screenshotScript} area";
        "XF86SelectiveScreenshot" = "${screenshotScript} area";
      }
    else
      {
        # Perfil Standard / PC (Acer Nitro, PCs, VMs, etc.) - Inspirado no gh0stzk/dotfiles
        # Captura imediata do monitor com o cursor
        "Print" = "${screenshotScript} full";
        # Recorte de área interativo
        "shift + Print" = "${screenshotScript} area";
        # Captura da janela ativa
        "ctrl + Print" = "${screenshotScript} window";
        # Temporizador de 5 segundos
        "alt + Print" = "${screenshotScript} in5";
        # Menu completo interativo no Rofi
        "super + Print" = "${screenshotScript} menu";

        # Em teclados de notebook / Linux X11, Alt + PrtSc gera o keysym Sys_Req
        "Sys_Req" = "${screenshotScript} full";
        "alt + Sys_Req" = "${screenshotScript} area";

        # Windows Snipping Tool / GNOME Area Screenshot
        "super + shift + s" = "${screenshotScript} area";
        "alt + shift + s" = "${screenshotScript} area";
        "XF86SelectiveScreenshot" = "${screenshotScript} area";
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

  altMod = if mod == "alt" then "super" else "alt";
  ctrlMod = if mod == "ctrl" then "super" else "ctrl";
  modDisplayName = normMod; # "Super", "Alt", "Ctrl"
  altDisplayName = if mod == "alt" then "Super" else "Alt";

  # --- Script de Notificação de Volume Suave (Estilo gh0stzk / Catppuccin) ---
  volumeOsd = pkgs.writeShellScript "volume-osd" ''
    case "$1" in
      up)   ${pkgs.pamixer}/bin/pamixer -i 2 ;;
      down) ${pkgs.pamixer}/bin/pamixer -d 2 ;;
      mute) ${pkgs.pamixer}/bin/pamixer -t ;;
    esac

    vol=$(${pkgs.pamixer}/bin/pamixer --get-volume 2>/dev/null || echo "0")
    is_muted=$(${pkgs.pamixer}/bin/pamixer --get-mute 2>/dev/null || echo "false")

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
      bar_val="$vol"
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

  # --- Dashboard Unificado: Quick Settings + Manual de Atalhos (Estilo Hyprland) ---
  quickSettings = pkgs.writeShellScript "quick-settings" ''
        show_manual() {
          KB_LIST="󰌌  ${modDisplayName} + Space / ${modDisplayName} + D     ➜  Lançador de Aplicativos (Rofi)
    󰌌  ${modDisplayName} + Enter / ${modDisplayName} + T     ➜  Abrir Terminal (Alacritty)
    󰌌  ${modDisplayName} + B                     ➜  Navegador Web Padrão
    󰌌  ${modDisplayName} + E / ${modDisplayName} + Shift + E ➜  Gerenciador de Arquivos (''${fmName})
    󰌌  ${modDisplayName} + , / ${modDisplayName} + C / Botão Dir. ➜ Painel Quick Settings / Preferências
    󰌌  ${modDisplayName} + / ou ${modDisplayName} + F1       ➜  Manual e Guia de Atalhos (Cheat-Sheet)
    󰌌  ${altDisplayName} + Tab / ${modDisplayName} + W         ➜  Alternador de Janelas Abertas
    󰌌  ${modDisplayName} + U                     ➜  Terminal Flutuante Rápido (Scratchpad)
    󰌌  ${modDisplayName} + Q / ${modDisplayName} + Shift + Q ➜  Fechar / Encerrar Janela
    󰌌  ${modDisplayName} + ${
      if mod == "alt" then "Super" else "Alt"
    } + Esc             ➜  Forçar Fechamento de Janela Travada
    󰌌  Alt + A                                 ➜  Alternar Tela Cheia (Fullscreen)
    󰌌  ${modDisplayName} + F                     ➜  Alternar Janela Flutuante (Floating/Tiling)
    󰌌  ${modDisplayName} + M                     ➜  Modo Monocle (Foco em Janela Única)
    󰌌  ${modDisplayName} + Y / ${modDisplayName} + Minus     ➜  Esconder / Minimizar Janela Ativa
    󰌌  ${modDisplayName} + Shift + Y / Shift+-  ➜  Restaurar Última Janela Escondida
    󰌌  ${modDisplayName} + Shift + M            ➜  Mostrar Desktop (Minimizar/Restaurar Todas)
    󰌌  ${modDisplayName} + {H,J,K,L} ou Setas    ➜  Navegar Foco Entre Janelas (Vim/Setas)
    󰌌  ${modDisplayName} + Shift + {H,J,K,L}     ➜  Mover / Trocar Posição da Janela
    󰌌  ${modDisplayName} + ${
      if mod == "alt" then "Super" else "Alt"
    } + {H,J,K,L}/Setas ➜  Redimensionar Tamanho da Janela
    󰌌  ${modDisplayName} + Botão Esquerdo        ➜  Mover Janela Flutuante com o Mouse
    󰌌  ${modDisplayName} + Botão Direito         ➜  Redimensionar Janela com o Mouse
    󰌌  ${modDisplayName} + 1..9, 0               ➜  Ir para Área de Trabalho (Workspace) 1 a 10
    󰌌  ${modDisplayName} + Shift + 1..9, 0       ➜  Enviar Janela para Workspace 1 a 10
    󰌌  Print / ${modDisplayName} + Shift + P     ➜  Menu de Captura de Tela (ScreenShoTer)
    󰌌  Shift + Print / ${modDisplayName} + Shift + S ➜  Recorte de Área Interativo
    󰌌  Ctrl + Print                              ➜  Capturar Janela Ativa
    󰌌  Alt + Print                               ➜  Captura com Temporizador (5s)
    󰌌  ${modDisplayName} + P                     ➜  Conta-gotas de Cor (Colorpicker)
    󰌌  ${modDisplayName} + Shift + R             ➜  Recarregar BSPWM e Polybar
    󰌌  ${modDisplayName} + ${
      if mod == "ctrl" then "Super" else "Ctrl"
    } + Q              ➜  Bloquear Sessão do Usuário
    󰌌  Teclas de Volume / Brilho / Mídia ➜  Controle com Feedback Visual OSD"

          CHOICE=$(echo "$KB_LIST" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰌌 Manual de Atalhos (Keybinds) " -theme-str 'window { width: 720px; height: 520px; } listview { columns: 1; lines: 12; }')

          case "$CHOICE" in
            *"Lançador de Aplicativos"*) ${pkgs.rofi}/bin/rofi -show drun ;;
            *"Abrir Terminal"*) ${pkgs.alacritty}/bin/alacritty & ;;
            *"Navegador Web Padrão"*) ${browserLaunchCmd} ;;
            *"Gerenciador de Arquivos"*) ''${fmCmd} ~ & ;;
            *"Painel Quick Settings"*) show_control_center ;;
            *"Alternador de Janelas"*) ${pkgs.rofi}/bin/rofi -show window ;;
            *"Terminal Flutuante"*) ${scratchpadScript} ;;
            *"Fechar / Encerrar Janela"*) bspc node -c ;;
            *"Tela Cheia"*) bspc node -t '~fullscreen' ;;
            *"Janela Flutuante"*) bspc node -t '~floating' ;;
            *"Esconder / Minimizar Janela"*) bspc node -g hidden=on ;;
            *"Restaurar Última Janela"*) bspc node any.hidden.local -g hidden=off -f ;;
            *"Captura de Tela"*) ${screenshotScript} menu & ;;
            *"Recorte de Área"*) ${screenshotScript} area & ;;
            *"Conta-gotas"*) ${colorPickerScript} & ;;
            *"Recarregar BSPWM"*) bspc wm -r ;;
            *"Bloquear Sessão"*) loginctl lock-session ;;
          esac
        }

        show_control_center() {
          OPT_SHOT="󰹑  Captura de Tela & Recorte (ScreenShoTer)"
          OPT_COLOR="󰈊  Conta-gotas de Cor (Colorpicker)"
          OPT_RES="󰍹  Resolução da Tela (Display Resolution)"
          OPT_SOUND="󰕾  Controle de Áudio & Volume (Pavucontrol)"
          OPT_NET="󰖩  Wi-Fi & Conexões (NetworkManager)"
          OPT_THEME="󰔎  Aparência, Ícones & Temas (LXAppearance)"
          OPT_WALL="󰸉  Papel de Parede (Wallpaper)"
          OPT_BROWSER="󰈹  Navegador Web (Firefox / Padrão)"
          OPT_FILES="󰉋  Gerenciador de Arquivos (''${fmName})"
          OPT_TERM="󰞷  Abrir Terminal (Alacritty)"
          OPT_KEYS="󰌌  Manual & Guia de Atalhos (Keybinds)"
          OPT_RELOAD="󰑐  Recarregar BSPWM & Polybar"
          OPT_POWER="󰐥  Menu de Energia & Bloqueio de Sessão"

          CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s" \
            "$OPT_SHOT" \
            "$OPT_COLOR" \
            "$OPT_RES" \
            "$OPT_SOUND" \
            "$OPT_NET" \
            "$OPT_THEME" \
            "$OPT_WALL" \
            "$OPT_BROWSER" \
            "$OPT_FILES" \
            "$OPT_TERM" \
            "$OPT_KEYS" \
            "$OPT_RELOAD" \
            "$OPT_POWER" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󱗼 Quick Settings ")

          case "$CHOICE" in
            "$OPT_SHOT") ${screenshotScript} menu & ;;
            "$OPT_COLOR") ${colorPickerScript} & ;;
            "$OPT_RES")
              R_1080="1920x1080 (Full HD 1080p)"
              R_2K="2560x1440 (Quad HD 2K)"
              R_900="1600x900 (HD+)"
              R_768="1366x768 (HD)"
              R_CUSTOM="⚙ Painel Avançado de Telas (ARandR)"

              RES=$(printf "%s\n%s\n%s\n%s\n%s" "$R_1080" "$R_2K" "$R_900" "$R_768" "$R_CUSTOM" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰍹 Selecionar Resolução ")
              case "$RES" in
                "$R_1080") ${pkgs.xrandr}/bin/xrandr -s 1920x1080 ;;
                "$R_2K")   ${pkgs.xrandr}/bin/xrandr -s 2560x1440 ;;
                "$R_900")  ${pkgs.xrandr}/bin/xrandr -s 1600x900 ;;
                "$R_768")  ${pkgs.xrandr}/bin/xrandr -s 1366x768 ;;
                "$R_CUSTOM") ${pkgs.arandr}/bin/arandr || ${pkgs.xrandr}/bin/xrandr ;;
              esac
              ;;
            "$OPT_SOUND") ${pkgs.pavucontrol}/bin/pavucontrol & ;;
            "$OPT_NET") ${pkgs.networkmanagerapplet}/bin/nm-connection-editor & ;;
            "$OPT_THEME") ${pkgs.lxappearance}/bin/lxappearance & ;;
            "$OPT_WALL") ${pkgs.nitrogen}/bin/nitrogen || ${pkgs.feh}/bin/feh & ;;
            "$OPT_BROWSER")
              if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || ${pkgs.firefox}/bin/firefox & fi
              ;;
            "$OPT_FILES") ''${fmCmd} ~ & ;;
            "$OPT_TERM") ${pkgs.alacritty}/bin/alacritty & ;;
            "$OPT_KEYS") show_manual ;;
            "$OPT_RELOAD")
              bspc wm -r
              ${pkgs.dunst}/bin/dunstify -a "Sistema" -u low -i "view-refresh" -t 2000 "BSPWM e Polybar recarregados com sucesso!"
              ;;
            "$OPT_POWER")
              ${pkgs.rofi}/bin/rofi -show power-menu -modi "power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu" || loginctl lock-session
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
      type = attrs;
      default = { };
      description = "sxhkd keybindings";
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
    # Recarregar automaticamente o sxhkd e polybar ao rodar switch-home (sem reiniciar o bspwm para não derrubar a sessão X11)
    home.activation.reloadSxhkd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -USR1 -x sxhkd 2>/dev/null || true
      $DRY_RUN_CMD ${pkgs.polybar}/bin/polybar-msg cmd restart 2>/dev/null || true
    '';

    services.sxhkd = {
      enable = true;
      package = pkgs.sxhkd;
      keybindings =
        cfg.keybindings
        // {
          # --- Clique no Desktop / Control Center (Estilo Hyprland / SwayNC) ---
          # Botão Direito no Desktop (Apenas na Root Window sem janela ou menu de app sob o cursor)
          "~button3" = "${desktopRightClickScript}";
          "${mod} + button3" = "${quickSettings}";
          "${mod} + comma" = "${quickSettings}"; # Atalho universal de Preferências
          "${mod} + c" = "${quickSettings}"; # Control Center
          "${altMod} + comma" = "${quickSettings}";
          "${altMod} + c" = "${quickSettings}";
          "${mod} + slash" = "${quickSettings} --manual"; # Manual & Cheat-Sheet de Atalhos
          "${mod} + F1" = "${quickSettings} --manual"; # F1 (Ajuda do Sistema)

          # --- Captura de Tela & Conta-gotas (Estilo gh0stzk) ---
          "${mod} + p" = "${colorPickerScript}"; # Conta-gotas de cor (Colorpicker)
          "${altMod} + p" = "${colorPickerScript}";
          "${mod} + shift + p" = "${screenshotScript} menu"; # Menu Rofi ScreenShoTer
          "${altMod} + shift + p" = "${screenshotScript} menu";

          # --- Aplicativos & Launchers (macOS Style) ---
          # Spotlight (Cmd + Space) e Rofi Drun
          "${mod} + space" = "${pkgs.rofi}/bin/rofi -show drun";
          "${mod} + d" = "${pkgs.rofi}/bin/rofi -show drun";
          "${mod} + shift + d" = "${pkgs.rofi}/bin/rofi -show run";

          # Navegador Web Padrão (Cmd + B)
          "${mod} + b" = browserLaunchCmd;

          # Terminal (Cmd + Return, Cmd + T)
          "${mod} + Return" = "${pkgs.alacritty}/bin/alacritty";
          "${mod} + KP_Enter" = "${pkgs.alacritty}/bin/alacritty";
          "${mod} + t" = "${pkgs.alacritty}/bin/alacritty";

          # Finder / Gerenciador de Arquivos (Cmd + Shift + F, Cmd + E)
          "${mod} + e" = fmCmd;
          "${mod} + shift + e" = fmCmd;

          # Alternador de Janelas (Cmd + Tab / Cmd + W)
          "${altMod} + Tab" = "${pkgs.rofi}/bin/rofi -show window";
          "${mod} + w" = "${pkgs.rofi}/bin/rofi -show window";

          # Terminal Scratchpad (Cmd + U / Super + U / Alt + U)
          "${mod} + u" = "${scratchpadScript}";
          "${altMod} + u" = "${scratchpadScript}";

          # --- Janelas (macOS Style: Cmd + Q / Cmd + Opt + Esc) ---
          "${mod} + q" = "bspc node -c";
          "${mod} + ${altMod} + Escape" = "bspc node -k";
          "${mod} + shift + q" = "bspc node -k";

          # --- Estados de Janela (Alternar Flutuante / Tela Cheia / Monocle) ---
          "${mod} + f" = "bspc node -t '~floating'";
          "${mod} + s" = "bspc node -t '~floating'";
          "alt + a" = "bspc node -t '~fullscreen'";
          "${mod} + m" = "bspc desktop -l next";

          # --- Minimizar / Esconder Janelas (Desktop Environment Style) ---
          # Esconder/Minimizar a janela ativa (Cmd + Y ou Cmd + -)
          "${mod} + y" = "bspc node -g hidden=on";
          "${mod} + minus" = "bspc node -g hidden=on";

          # Restaurar/Desocultar a última janela escondida (Cmd + Shift + Y ou Cmd + Shift + -)
          "${mod} + shift + y" = "bspc node any.hidden.local -g hidden=off -f";
          "${mod} + shift + minus" = "bspc node any.hidden.local -g hidden=off -f";

          # Alternar Mostrar Desktop (Minimizar todas / Restaurar todas no workspace ativo)
          "${mod} + shift + m" = "${toggleDesktopScript}";

          # --- Bloqueio & Sessão (macOS Style: Cmd + Ctrl + Q) ---
          "${mod} + ${ctrlMod} + q" = "loginctl lock-session";
          "${mod} + shift + x" = "loginctl lock-session";

          # --- Foco e Movimento em Janelas (Vim + Setas) ---
          "${mod} + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
          "${mod} + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
          "${mod} + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}";
          "${mod} + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";

          # --- Navegação e Envio de Janelas Entre Monitores ---
          "${mod} + bracketleft" = "bspc monitor -f prev";
          "${mod} + bracketright" = "bspc monitor -f next";
          "${mod} + shift + bracketleft" = "bspc node -m prev --follow";
          "${mod} + shift + bracketright" = "bspc node -m next --follow";

          # --- Áreas de Trabalho (Workspaces 1-10, onde 0 = workspace 0/10) ---
          # Focar área de trabalho (compatível tanto com Super quanto com Alt)
          "${mod} + {1-9,0}" = "${desktopFocusScript} {1-9,0}";
          "${altMod} + {1-9,0}" = "${desktopFocusScript} {1-9,0}";

          # Enviar janela para área de trabalho com foco imediato (--follow) (compatível com Super e Alt)
          "${mod} + shift + {1-9,0}" = "${desktopNodeScript} {1-9,0} true";
          "${altMod} + shift + {1-9,0}" = "${desktopNodeScript} {1-9,0} true";

          # Enviar janela para área de trabalho em segundo plano (sem follow) (compatível com Super e Alt)
          "${mod} + ctrl + {1-9,0}" = "${desktopNodeScript} {1-9,0} false";
          "${altMod} + ctrl + {1-9,0}" = "${desktopNodeScript} {1-9,0} false";

          # --- Redimensionar Janelas (Super + Alt + Setas/Vim) ---
          "${mod} + ${altMod} + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
          "${mod} + ${altMod} + {Left,Down,Up,Right}" =
            "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";

          # --- Reiniciar / Recarregar BSPWM, SXHKD e Polybar ---
          "${mod} + shift + r" = "bspc wm -r; ${pkgs.procps}/bin/pkill -USR1 -x sxhkd; ${pkgs.polybar}/bin/polybar-msg cmd restart";
          "${mod} + Escape" = "${pkgs.procps}/bin/pkill -USR1 -x sxhkd";

          # --- Controles de Mídia e Áudio com Dunst OSD (Estilo gh0stzk) ---
          "XF86AudioRaiseVolume" = "${volumeOsd} up";
          "XF86AudioLowerVolume" = "${volumeOsd} down";
          "XF86AudioMute" = "${volumeOsd} mute";
          "XF86AudioPlay" = "${mediaControl} play-pause";
          "XF86AudioNext" = "${mediaControl} next";
          "XF86AudioPrev" = "${mediaControl} prev";
          "XF86AudioStop" = "${mediaControl} stop";

          # --- Controle de Brilho da Tela (MacBook F1 / F2) ---
          "XF86MonBrightnessUp" = "${brightnessOsd} up";
          "XF86MonBrightnessDown" = "${brightnessOsd} down";

          # --- Controle de Iluminação do Teclado (MacBook F5/F6 e Logitech MX Keys F3/F4) ---
          "XF86KbdBrightnessUp" = "${kbdBrightnessOsd} up";
          "XF86KbdBrightnessDown" = "${kbdBrightnessOsd} down";
          "XF86KbdLightOnOff" = "${kbdBrightnessOsd} toggle";

          # MacBook (F5 / F6)
          "${mod} + F6" = "${kbdBrightnessOsd} up";
          "${mod} + F5" = "${kbdBrightnessOsd} down";
          "${mod} + shift + F5" = "${kbdBrightnessOsd} toggle";

          # Logitech MX Keys / Teclados com F3 (down) e F4 (up)
          "${mod} + F4" = "${kbdBrightnessOsd} up";
          "${mod} + F3" = "${kbdBrightnessOsd} down";
          "${mod} + shift + F4" = "${kbdBrightnessOsd} toggle";
        }
        // screenshotBindings
        // lib.optionalAttrs (mod != "super") {
          # Atalhos com Super garantidos mesmo quando mod != "super"
          "super + F4" = "${kbdBrightnessOsd} up";
          "super + F3" = "${kbdBrightnessOsd} down";
          "super + shift + F4" = "${kbdBrightnessOsd} toggle";
          "super + shift + F3" = "${kbdBrightnessOsd} toggle";
          "super + F6" = "${kbdBrightnessOsd} up";
          "super + F5" = "${kbdBrightnessOsd} down";
          "super + shift + F5" = "${kbdBrightnessOsd} toggle";
        };
    };

    # Utilitários de linha de comando para uso interativo e scripts
    home.packages = [
      (pkgs.writeShellScriptBin "bspwm-screenshot" ''exec ${screenshotScript} "$@"'')
      (pkgs.writeShellScriptBin "screenshoter" ''exec ${screenshotScript} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-colorpicker" ''exec ${colorPickerScript} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-media-control" ''exec ${mediaControl} "$@"'')
    ];
  };
}
