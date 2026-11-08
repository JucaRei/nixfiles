{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.mangowm;
  themeLib = config.desktop.theme.lib;
  c = config.desktop.theme.colors;
  isNoctalia = (config.desktop.wayland.shell or "traditional") == "noctalia";
  isApple = (config.home.keyboard.model or "") == "apple";

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
      "ALT"
    else if normMod == "Ctrl" then
      "CTRL"
    else
      "SUPER";

  altMod = if mod == "ALT" then "SUPER" else "ALT";
  ctrlMod = if mod == "CTRL" then "SUPER" else "CTRL";

  # Scripts de Captura de Tela
  screenshotFull = pkgs.writeShellScript "mango-screenshot-full" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
    ${pkgs.grim}/bin/grim "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    ${pkgs.libnotify}/bin/notify-send -i "$file" "Captura de Tela" "Captura completa salva em Pictures/Screenshots e copiada."
  '';

  screenshotArea = pkgs.writeShellScript "mango-screenshot-area" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
    geometry="$(${pkgs.slurp}/bin/slurp)"
    [ -z "$geometry" ] && exit 0
    ${pkgs.grim}/bin/grim -g "$geometry" "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    ${pkgs.libnotify}/bin/notify-send -i "$file" "Captura de Tela" "Recorte salvo em Pictures/Screenshots e copiado."
  '';

  screenshotPick = pkgs.writeShellScript "mango-screenshot-pick" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
    geometry="$(${pkgs.slurp}/bin/slurp -o)"
    [ -z "$geometry" ] && exit 0
    ${pkgs.grim}/bin/grim -g "$geometry" "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    ${pkgs.libnotify}/bin/notify-send -i "$file" "Captura de Tela" "Monitor capturado salvo em Pictures/Screenshots e copiado."
  '';

  cliphistMenu = pkgs.writeShellScript "mango-cliphist" ''
    ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰅍 Clipboard " | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  # Controle de Iluminação do Teclado com OSD Dunst
  kbdBrightnessOsd = pkgs.writeShellScript "mango-kbd-brightness-osd" ''
    dev="smc::kbd_backlight"
    if ! ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" info >/dev/null 2>&1; then
      dev=$(${pkgs.brightnessctl}/bin/brightnessctl --list 2>/dev/null | grep -E -m1 "kbd_backlight|keyboard" | cut -d\' -f2 || true)
    fi

    if [ -n "$dev" ]; then
      case "$1" in
        up)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +2% >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          fi
          ;;
        down)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 2%- >/dev/null 2>&1
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
        notif_file="/tmp/mango_kbd_notif_id"
        last_id=0
        if [ -f "$notif_file" ]; then
          last_id=$(cat "$notif_file" 2>/dev/null || echo 0)
        fi
        case "$last_id" in
          '''|*[!0-9]*) last_id=0 ;;
        esac
        new_id=$(${pkgs.libnotify}/bin/notify-send -p -r "$last_id" -a "OSD" -u low -i "input-keyboard" -h int:value:"$val" -t 1200 "Luz do Teclado: $val%")
        if [ -n "$new_id" ]; then
          echo "$new_id" > "$notif_file"
        fi
      fi
    else
      # Teclados externos (Logitech MX Keys / sem interface direta em /sys/class/leds)
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
            ${pkgs.libnotify}/bin/notify-send -a "OSD" -u low -i "input-keyboard" -t 1500 "Luz do Teclado (MX Keys): Aumentar / Ativada"
            ;;
          down)
            "$SOLAAR_CMD" config "MX Keys" backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight false 2>/dev/null || true
            ${pkgs.libnotify}/bin/notify-send -a "OSD" -u low -i "input-keyboard" -t 1500 "Luz do Teclado (MX Keys): Diminuir / Desativada"
            ;;
        esac
      else
        case "$1" in
          up)   ${pkgs.libnotify}/bin/notify-send -a "OSD" -u low -i "input-keyboard" -t 1500 "Luz do Teclado (F4 / MX Keys): Aumentar" ;;
          down) ${pkgs.libnotify}/bin/notify-send -a "OSD" -u low -i "input-keyboard" -t 1500 "Luz do Teclado (F3 / MX Keys): Diminuir" ;;
          toggle) ${pkgs.libnotify}/bin/notify-send -a "OSD" -u low -i "input-keyboard" -t 1500 "Luz do Teclado (MX Keys): Alternar" ;;
        esac
      fi
    fi
  '';

  # Controle de Brilho da Tela (passos de 2% com OSD dedicado)
  monBrightnessOsd = pkgs.writeShellScript "mango-mon-brightness-osd" ''
    case "$1" in
      up)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl set +2% >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set +1 >/dev/null 2>&1
        fi
        ;;
      down)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl set 2%- >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set 1- >/dev/null 2>&1
        fi
        ;;
    esac
    ${
      if isNoctalia then
        ''
          # No Noctalia Shell, o serviço nativo de Brightness detecta a alteração via sysfs
          # e exibe o OSD centralizado nativo automaticamente, sem criar notificações extras.
        ''
      else
        ''
          val=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4 | tr -d '%')
          if [ -n "$val" ]; then
            ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "display-brightness" -r 9992 -h int:value:"$val" -t 1500 "Brilho da Tela: $val%"
          fi
        ''
    }
  '';
in
{
  config = mkIf cfg.enable {
    xdg.configFile."mango/config.conf".text = ''
      # ============================================================================
      # MangoWM Configuration - Rice Catppuccin Mocha
      # ============================================================================

      # --- Configuração de Monitor (Resolução Nativa 1:1) ---
      ${lib.concatMapStringsSep "\n" (r: "monitor_rule=${r}") (cfg.monitorRules or [ ])}

      # --- Efeitos Visuais e Janelas ---
      blur=1
      blur_layer=0
      blur_optimized=1
      blur_params_num_passes=2
      blur_params_radius=5
      blur_params_noise=0.02
      blur_params_brightness=0.9
      blur_params_contrast=0.9
      blur_params_saturation=1.0

      shadows=1
      layer_shadows=0
      shadow_only_floating=0
      shadows_size=4
      shadows_blur=12
      shadows_position_x=2
      shadows_position_y=2
      shadows_color=0x000000ff

      border_radius=10
      no_radius_when_single=0
      focused_opacity=1.0
      unfocused_opacity=0.97

      # --- Animações ---
      animations=1
      layer_animations=0
      animation_type_open=slide
      animation_type_close=slide
      animation_fade_in=1
      animation_fade_out=1
      tag_animation_direction=1
      animation_duration_move=400
      animation_duration_open=350
      animation_duration_tag=300
      animation_duration_close=400

      # --- Dimensões e Gaps ---
      border_px=2
      gap_inner_horizontal=6
      gap_inner_vertical=6
      gap_outer_horizontal=12
      gap_outer_vertical=12
      smart_gaps=0

      # --- Paleta Dinâmica (desktop.theme) ---
      root_color=${themeLib.hexTo0x c.bg "ff"}
      border_color=${themeLib.hexTo0x c.surfaceAlt "ff"}
      focus_color=${themeLib.hexTo0x c.accent "ff"}
      drop_color=${themeLib.hexTo0x c.accent "55"}
      split_color=${themeLib.hexTo0x c.orange "ff"}
      maximized_screen_color=${themeLib.hexTo0x c.green "ff"}
      urgent_color=${themeLib.hexTo0x c.red "ff"}
      scratchpad_color=${themeLib.hexTo0x c.accent "ff"}
      global_color=${themeLib.hexTo0x c.purple "ff"}
      overlay_color=${themeLib.hexTo0x c.cyan "ff"}

      # --- Layout Scroller & Overview ---
      scroller_structs=450
      scroller_default_proportion=0.5
      scroller_focus_center=0
      scroller_prefer_center=0
      edge_scroller_pointer_focus=0
      scroller_ignore_proportion_single=0
      scroller_default_proportion_single=0.75
      scroller_proportion_preset=0.5,0.7,1.0

      hotarea_size=10
      enable_hotarea=0
      overview_gap_inner=6
      overview_gap_outer=20

      # --- Configuração de Entrada (Teclado e Touchpad) ---
      repeat_rate=30
      repeat_delay=300
      numlock_on=0
      xkb_rules_layout=${config.home.keyboard.layout}
      xkb_rules_variant=${config.home.keyboard.variant}
      xkb_rules_model=${config.home.keyboard.model}

      disable_trackpad=0
      tap_to_click=1
      tap_and_drag=1
      drag_lock=1
      trackpad_natural_scrolling=1
      trackpad_disable_while_typing=1

      # --- Comportamento ---
      focus_on_activate=1
      sloppy_focus=1
      warp_cursor=1
      cursor_size=24

      # --- Gestos de Touchpad (Swipe de Workspaces com 3 dedos) ---
      gesturebind=none,left,3,viewtoright,0
      gesturebind=none,right,3,viewtoleft,0
      gesturebind=none,up,3,toggleoverview,0
      gesturebind=none,down,3,toggleoverview,0

      # Gestos de 4 dedos para foco de janelas
      gesturebind=none,left,4,focusdir,left
      gesturebind=none,right,4,focusdir,right
      gesturebind=none,up,4,focusdir,up
      gesturebind=none,down,4,focusdir,down

      # --- Roda do Mouse (Axisbind) ---
      axisbind=${mod},UP,viewtoleft
      axisbind=${mod},DOWN,viewtoright
      axisbind=${mod}+${ctrlMod},UP,tagtoleft
      axisbind=${mod}+${ctrlMod},DOWN,tagtoright

      # --- Layouts por Tag (1 a 9) ---
      tag_num=9
      tag_rule=id:1,layout_name:tile
      tag_rule=id:2,layout_name:tile
      tag_rule=id:3,layout_name:tile
      tag_rule=id:4,layout_name:tile
      tag_rule=id:5,layout_name:tile
      tag_rule=id:6,layout_name:tile
      tag_rule=id:7,layout_name:tile
      tag_rule=id:8,layout_name:tile
      tag_rule=id:9,layout_name:tile

      # --- Autostart (Serviços e Componentes de Sessão) ---
      ${
        if isNoctalia then
          ''
            exec_once=${pkgs.noctalia}/bin/noctalia
          ''
        else
          ''
            exec_once=${pkgs.waybar}/bin/waybar
            exec_once=${pkgs.dunst}/bin/dunst
            exec_once=${pkgs.hypridle}/bin/hypridle
            exec_once=${pkgs.hyprpaper}/bin/hyprpaper
          ''
      }
      exec_once=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      exec_once=${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store
      exec_once=${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store

      ${import ./_mango-binds.nix {
        inherit
          config
          pkgs
          mod
          altMod
          ctrlMod
          isNoctalia
          isApple
          screenshotFull
          screenshotArea
          screenshotPick
          cliphistMenu
          kbdBrightnessOsd
          monBrightnessOsd
          ;
      }}

      # Regras de Janela (Window Rules)
      window_rule=is_floating:1,width:850,height:550,title:floating-kitty
      window_rule=is_floating:1,app_id:thunar
      window_rule=is_floating:1,app_id:org.gnome.NautilusPreviewer
      window_rule=is_floating:1,app_id:org.gnome.FileRoller
      window_rule=is_floating:1,app_id:nemo
      window_rule=is_floating:1,app_id:pcmanfm
      window_rule=is_floating:1,app_id:pavucontrol
      window_rule=is_floating:1,app_id:nm-connection-editor
      window_rule=is_floating:1,app_id:blueman-manager
      window_rule=is_floating:1,app_id:mpv
      window_rule=is_floating:1,app_id:.*[sS]crcpy.*
      window_rule=is_floating:1,app_id:.scrcpywrap
      window_rule=is_floating:1,app_id:scrcpy-wrapped
      window_rule=is_floating:1,app_id:.scrcpy-wrapped
      window_rule=is_floating:1,title:.*[sS]crcpy.*
      window_rule=is_floating:1,title:.*Preferences.*
      window_rule=is_floating:1,title:.*Settings.*
      window_rule=is_floating:1,title:.*Choose.*
      window_rule=is_floating:1,title:.*Open.*
      window_rule=is_floating:1,title:.*Save.*
      window_rule=is_floating:1,title:.*Confirm.*
      window_rule=is_floating:1,title:.*(Sign in|Fazer login|Log in|Login|Contas do Google|Google Accounts|OAuth|Authorize|Autorizar|Authentication|Autenticação|Bitwarden).*
      window_rule=idle_inhibit_when_focus:1,app_id:steam

      # Regras de Camada (Layer Rules)
      layer_rule=animation_type_open:zoom,layer_name:rofi
      layer_rule=animation_type_close:zoom,layer_name:rofi
    '';
  };
}
