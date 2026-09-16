{
  config,
  lib,
  pkgs,
  hostname ? null,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.mangowm;
  isNoctalia = (config.desktop.wayland.shell or "traditional") == "noctalia";
  isApple = (config.home.keyboard.model or "") == "apple" || hostname == "anubis" || hostname == "rocinante";

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
      dev=$(${pkgs.brightnessctl}/bin/brightnessctl --list 2>/dev/null | grep -m1 "kbd_backlight" | cut -d\' -f2)
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
    ${if isNoctalia then ''
      # No Noctalia Shell, o serviço nativo de Brightness detecta a alteração via sysfs
      # e exibe o OSD centralizado nativo automaticamente, sem criar notificações extras.
    '' else ''
      val=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4 | tr -d '%')
      if [ -n "$val" ]; then
        ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "display-brightness" -r 9992 -h int:value:"$val" -t 1500 "Brilho da Tela: $val%"
      fi
    ''}
  '';
in
{
  config = mkIf cfg.enable {
    xdg.configFile."mango/config.conf".text = ''
      # ============================================================================
      # MangoWM Configuration - Rice Catppuccin Mocha
      # ============================================================================

      # --- Efeitos Visuais e Janelas ---
      blur=1
      blur_layer=1
      blur_optimized=1
      blur_params_num_passes=2
      blur_params_radius=5
      blur_params_noise=0.02
      blur_params_brightness=0.9
      blur_params_contrast=0.9
      blur_params_saturation=1.2

      shadows=1
      layer_shadows=0
      shadow_only_floating=1
      shadows_size=10
      shadows_blur=15
      shadowscolor=0x11111b88

      border_radius=10
      no_radius_when_single=0
      focused_opacity=1.0
      unfocused_opacity=0.97

      # --- Animações ---
      animations=1
      layer_animations=1
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
      borderpx=2
      gappih=6
      gappiv=6
      gappoh=12
      gappov=12
      smartgaps=0

      # --- Paleta Catppuccin Mocha ---
      rootcolor=0x1e1e2eff
      bordercolor=0x313244ff
      focuscolor=0x89b4faff
      dropcolor=0x89b4fa55
      splitcolor=0xfab387ff
      maximizescreencolor=0xa6e3a1ff
      urgentcolor=0xf38ba8ff
      scratchpadcolor=0x89b4faff
      globalcolor=0xcba6f7ff
      overlaycolor=0x89dcebff

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
      ov_tab_mode=1
      overviewgappi=6
      overviewgappo=20

      # --- Configuração de Entrada (Teclado e Touchpad) ---
      repeat_rate=30
      repeat_delay=300
      numlockon=0
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
      sloppyfocus=1
      warpcursor=1
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
      axisbind=SUPER,UP,viewtoleft
      axisbind=SUPER,DOWN,viewtoright
      axisbind=SUPER+CTRL,UP,tagtoleft
      axisbind=SUPER+CTRL,DOWN,tagtoright

      # --- Layouts por Tag (1 a 9) ---
      tag_num=9
      tagrule=id:1,layout_name:tile
      tagrule=id:2,layout_name:tile
      tagrule=id:3,layout_name:tile
      tagrule=id:4,layout_name:tile
      tagrule=id:5,layout_name:tile
      tagrule=id:6,layout_name:tile
      tagrule=id:7,layout_name:tile
      tagrule=id:8,layout_name:tile
      tagrule=id:9,layout_name:tile

      # --- Autostart (Serviços e Componentes de Sessão) ---
      ${if isNoctalia then ''
        exec-once=${pkgs.noctalia}/bin/noctalia
      '' else ''
        exec-once=${pkgs.waybar}/bin/waybar
        exec-once=${pkgs.dunst}/bin/dunst
        exec-once=${pkgs.hypridle}/bin/hypridle
        exec-once=${pkgs.hyprpaper}/bin/hyprpaper
      ''}
      exec-once=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      exec-once=${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store
      exec-once=${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store

      # ============================================================================
      # Atalhos de Teclado (Keybindings)
      # ============================================================================

      # Recarregar Configurações (MangoWM + Noctalia / Waybar)
      bind=SUPER,r,spawn,mango-reload
      bind=SUPER+SHIFT,r,spawn,mango-reload --restart
      bind=SUPER+ALT,r,spawn,mango-reload

      # Aplicativos e Utilitários
      bind=SUPER,Return,spawn,${pkgs.alacritty}/bin/alacritty
      bind=SUPER+CTRL,Return,spawn,${pkgs.alacritty}/bin/alacritty --title floating-kitty
      ${if isNoctalia then ''
        bind=SUPER,space,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle launcher
        bind=SUPER,d,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle launcher
        bind=SUPER,v,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle clipboard
        bind=SUPER,p,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle control-center
        bind=SUPER,s,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle control-center
        bind=SUPER,Escape,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle session
        bind=SUPER+SHIFT,e,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle session
        bind=SUPER,comma,spawn,${pkgs.noctalia}/bin/noctalia msg settings-toggle
        bind=SUPER+ALT,w,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle wallpaper

        # Window Switcher (Alt+Tab Overlay nativo do Noctalia)
        bind=ALT,Tab,spawn,${pkgs.noctalia}/bin/noctalia msg window-switcher
        bind=ALT+SHIFT,Tab,spawn,${pkgs.noctalia}/bin/noctalia msg window-switcher

        # Sessão: Lock e Suspend
        bind=SUPER,l,spawn,${pkgs.noctalia}/bin/noctalia msg session lock
        ${if isApple then ''
          bind=SUPER+CTRL,q,spawn,${pkgs.noctalia}/bin/noctalia msg session lock
        '' else ''''}
        bind=SUPER+ALT,s,spawn,${pkgs.noctalia}/bin/noctalia msg session suspend
        bind=NONE,XF86Sleep,spawn,${pkgs.noctalia}/bin/noctalia msg session suspend

        # Night Light e Caffeine
        bind=SUPER+SHIFT,n,spawn,${pkgs.noctalia}/bin/noctalia msg nightlight-toggle
        bind=SUPER+CTRL+SHIFT,n,spawn,${pkgs.noctalia}/bin/noctalia msg nightlight-force-toggle
        bind=SUPER+SHIFT,c,spawn,${pkgs.noctalia}/bin/noctalia msg caffeine-toggle
      '' else ''
        bind=SUPER,space,spawn,${pkgs.rofi}/bin/rofi -show drun
        bind=SUPER,d,spawn,${pkgs.rofi}/bin/rofi -show drun
        bind=SUPER,v,spawn,${cliphistMenu}
        bind=SUPER,Escape,spawn,session-power-menu
        bind=SUPER+SHIFT,e,spawn,session-power-menu
        bind=SUPER,l,spawn,${pkgs.hyprlock}/bin/hyprlock
        ${if isApple then ''
          bind=SUPER+CTRL,q,spawn,${pkgs.hyprlock}/bin/hyprlock
        '' else ''''}
        bind=SUPER+ALT,s,spawn,systemctl suspend
        bind=NONE,XF86Sleep,spawn,systemctl suspend
        bind=ALT,Tab,toggleoverview,
      ''}
      bind=SUPER,e,spawn,${pkgs.thunar}/bin/thunar
      bind=SUPER+SHIFT,q,quit

      # Ajuda e Lista de Atalhos de Teclado (Plugin Keymap)
      ${if isNoctalia then ''
        bind=SUPER,F1,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle blackbartblues/keymap:panel
        bind=SUPER,question,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle blackbartblues/keymap:panel
        bind=SUPER,slash,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle blackbartblues/keymap:panel
      '' else ''
      ''}

      # Gerenciamento de Janelas e Estados
      bind=SUPER,q,killclient,
      bind=SUPER,c,killclient,
      bind=SUPER,w,togglefloating,
      bind=SUPER+SHIFT,space,togglefloating,
      bind=SUPER,backslash,togglefloating,
      ${if isNoctalia then ''
        # Alt+Tab overlay gerenciado via Noctalia
      '' else ''
        bind=ALT,Tab,toggleoverview,
      ''}
      bind=SUPER,Tab,focusstack,next
      bind=ALT,f,togglefullscreen,
      bind=ALT+SHIFT,f,togglefakefullscreen,
      bind=ALT,a,togglemaximizescreen,
      bind=SUPER,i,minimized,
      bind=SUPER+SHIFT,i,restore_minimized
      bind=SUPER+SHIFT,o,toggleoverlay,
      bind=SUPER+SHIFT,g,toggleglobal,
      bind=ALT,z,toggle_scratchpad

      # Redimensionamento de Janelas
      bind=SUPER,equal,resizewin,20,0
      bind=SUPER,minus,resizewin,-20,0
      bind=SUPER+CTRL,equal,resizewin,0,20
      bind=SUPER+CTRL,minus,resizewin,0,-20

      # Layouts e Proporções
      bind=CTRL,space,switch_layout
      bind=SUPER,n,switch_layout
      bind=CTRL+SHIFT,space,spawn,mango-layout-picker
      bind=SUPER+ALT,space,spawn,mango-layout-picker
      bind=SUPER+ALT,f,set_proportion,1.0
      bind=ALT,space,switch_proportion_preset,
      bind=SUPER+c,scroller_stack,left
      bind=SUPER+SHIFT,c,scroller_stack,right

      # Ajustes de Gaps
      bind=ALT+SHIFT,x,incgaps,2
      bind=ALT+SHIFT,z,incgaps,-2
      bind=ALT+SHIFT,r,togglegaps
      bind=SUPER+SHIFT,a,spawn,mango-toggle-outer-gaps

      # Foco Direcional (Setas e Vim Keys)
      bind=SUPER,Left,focusdir,left
      bind=SUPER,Right,focusdir,right
      bind=SUPER,Up,focusdir,up
      bind=SUPER,Down,focusdir,down
      bind=SUPER,h,focusdir,left
      bind=SUPER,l,focusdir,right
      bind=SUPER,k,focusdir,up
      bind=SUPER,j,focusdir,down

      # Trocar Janelas de Posição (Setas e Vim Keys)
      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Right,exchange_client,right
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down
      bind=SUPER+SHIFT,h,exchange_client,left
      bind=SUPER+SHIFT,l,exchange_client,right
      bind=SUPER+SHIFT,k,exchange_client,up
      bind=SUPER+SHIFT,j,exchange_client,down

      # Controle de Tags (1 a 9)
      bind=SUPER,1,view,1
      bind=SUPER,2,view,2
      bind=SUPER,3,view,3
      bind=SUPER,4,view,4
      bind=SUPER,5,view,5
      bind=SUPER,6,view,6
      bind=SUPER,7,view,7
      bind=SUPER,8,view,8
      bind=SUPER,9,view,9

      # Mover Janelas para Tags (1 a 9)
      bind=SUPER+CTRL,1,tag,1,0
      bind=SUPER+CTRL,2,tag,2,0
      bind=SUPER+CTRL,3,tag,3,0
      bind=SUPER+CTRL,4,tag,4,0
      bind=SUPER+CTRL,5,tag,5,0
      bind=SUPER+CTRL,6,tag,6,0
      bind=SUPER+CTRL,7,tag,7,0
      bind=SUPER+CTRL,8,tag,8,0
      bind=SUPER+CTRL,9,tag,9,0

      bind=SUPER+SHIFT,1,tag,1,0
      bind=SUPER+SHIFT,2,tag,2,0
      ${if isApple then ''
        # No hardware Apple, SUPER+SHIFT+3, 4, 5 são atalhos de Captura de Tela estilo macOS (Cmd+Shift+3/4/5)
        # O envio de janelas para as tags 3, 4 e 5 é feito via SUPER+CTRL+3, 4, 5
      '' else ''
        bind=SUPER+SHIFT,3,tag,3,0
        bind=SUPER+SHIFT,4,tag,4,0
        bind=SUPER+SHIFT,5,tag,5,0
      ''}
      bind=SUPER+SHIFT,6,tag,6,0
      bind=SUPER+SHIFT,7,tag,7,0
      bind=SUPER+SHIFT,8,tag,8,0
      bind=SUPER+SHIFT,9,tag,9,0

      # Navegação entre Tags Adjacentes
      bind=SUPER+CTRL,Up,viewtoleft,0
      bind=SUPER+CTRL,Down,viewtoright,0
      bind=SUPER+CTRL+ALT,Up,tagtoleft,0
      bind=SUPER+CTRL+ALT,Down,tagtoright,0

      # Teclas Multimídia e Áudio
      ${if isNoctalia then ''
        bind=NONE,XF86AudioRaiseVolume,spawn,${pkgs.noctalia}/bin/noctalia msg volume-up
        bind=NONE,XF86AudioLowerVolume,spawn,${pkgs.noctalia}/bin/noctalia msg volume-down
        bind=NONE,XF86AudioMute,spawn,${pkgs.noctalia}/bin/noctalia msg volume-mute
        bind=NONE,XF86AudioMicMute,spawn,${pkgs.noctalia}/bin/noctalia msg mic-mute
        bind=NONE,XF86AudioPlay,spawn,${pkgs.noctalia}/bin/noctalia msg media toggle
        bind=NONE,XF86AudioNext,spawn,${pkgs.noctalia}/bin/noctalia msg media next
        bind=NONE,XF86AudioPrev,spawn,${pkgs.noctalia}/bin/noctalia msg media previous

        # Brilho da Tela (Feedback OSD Nativo do Noctalia)
        bind=NONE,XF86MonBrightnessUp,spawn,${pkgs.noctalia}/bin/noctalia msg brightness-up
        bind=NONE,XF86MonBrightnessDown,spawn,${pkgs.noctalia}/bin/noctalia msg brightness-down

        # Iluminação do Teclado (Feedback OSD Nativo do Noctalia)
        bind=NONE,XF86KbdBrightnessUp,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-up
        bind=NONE,XF86KbdBrightnessDown,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-down
        bind=NONE,XF86KbdLightOnOff,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-toggle
        bind=SUPER,F6,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-up
        bind=SUPER,F5,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-down
        bind=SUPER+SHIFT,F5,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-toggle

        # Captura de Tela (Screenshots via Noctalia IPC)
        ${if isApple then ''
          # Mapeamento oficial Apple macOS: Cmd+Shift+3 (Tela inteira), Cmd+Shift+4 (Região), Cmd+Shift+5 (Menu/Seleção)
          bind=SUPER+SHIFT,3,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen
          bind=SUPER+SHIFT,4,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
          bind=SUPER+SHIFT,5,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen pick
          bind=NONE,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen
          bind=SHIFT,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
          bind=SUPER+SHIFT,S,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
        '' else ''
          # Padrão PC
          bind=NONE,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen
          bind=SHIFT,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
          bind=SUPER+SHIFT,S,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
        ''}
      '' else ''
        bind=NONE,XF86AudioRaiseVolume,spawn,${pkgs.pamixer}/bin/pamixer -i 5
        bind=NONE,XF86AudioLowerVolume,spawn,${pkgs.pamixer}/bin/pamixer -d 5
        bind=NONE,XF86AudioMute,spawn,${pkgs.pamixer}/bin/pamixer -t
        bind=NONE,XF86AudioMicMute,spawn,${pkgs.pamixer}/bin/pamixer --default-source -t
        bind=NONE,XF86AudioPlay,spawn,${pkgs.playerctl}/bin/playerctl play-pause
        bind=NONE,XF86AudioNext,spawn,${pkgs.playerctl}/bin/playerctl next
        bind=NONE,XF86AudioPrev,spawn,${pkgs.playerctl}/bin/playerctl previous

        # Brilho da Tela (com Feedback OSD)
        bind=NONE,XF86MonBrightnessUp,spawn,${monBrightnessOsd} up
        bind=NONE,XF86MonBrightnessDown,spawn,${monBrightnessOsd} down

        # Iluminação do Teclado (MacBook / Laptops)
        bind=NONE,XF86KbdBrightnessUp,spawn,${kbdBrightnessOsd} up
        bind=NONE,XF86KbdBrightnessDown,spawn,${kbdBrightnessOsd} down
        bind=NONE,XF86KbdLightOnOff,spawn,${kbdBrightnessOsd} toggle
        bind=SUPER,F6,spawn,${kbdBrightnessOsd} up
        bind=SUPER,F5,spawn,${kbdBrightnessOsd} down
        bind=SUPER+SHIFT,F5,spawn,${kbdBrightnessOsd} toggle

        # Captura de Tela (Screenshots)
        ${if isApple then ''
          # Mapeamento oficial Apple macOS: Cmd+Shift+3 (Tela inteira), Cmd+Shift+4 (Região), Cmd+Shift+5 (Menu/Seleção)
          bind=SUPER+SHIFT,3,spawn,${screenshotFull}
          bind=SUPER+SHIFT,4,spawn,${screenshotArea}
          bind=SUPER+SHIFT,5,spawn,${screenshotPick}
          bind=NONE,Print,spawn,${screenshotFull}
          bind=SHIFT,Print,spawn,${screenshotArea}
          bind=SUPER+SHIFT,S,spawn,${screenshotArea}
        '' else ''
          # Padrão PC
          bind=NONE,Print,spawn,${screenshotFull}
          bind=SHIFT,Print,spawn,${screenshotArea}
          bind=SUPER+SHIFT,S,spawn,${screenshotArea}
        ''}
      ''}

      # Mouse
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_right,moveresize,curresize
      mousebind=NONE,btn_middle,togglemaximizescreen,0

      # Regras de Janela (Window Rules)
      windowrule=isfloating:1,width:850,height:550,title:floating-kitty
      windowrule=isfloating:1,appid:thunar
      windowrule=isfloating:1,appid:pavucontrol
      windowrule=isfloating:1,appid:nm-connection-editor
      windowrule=isfloating:1,appid:blueman-manager
      windowrule=isfloating:1,title:.*Preferences.*
      windowrule=isfloating:1,title:.*Settings.*
      windowrule=isfloating:1,title:.*Choose.*
      windowrule=isfloating:1,title:.*Open.*
      windowrule=isfloating:1,title:.*Save.*
      windowrule=isfloating:1,title:.*Confirm.*
      windowrule=idleinhibit_when_focus:1,appid:steam

      # Regras de Camada (Layer Rules)
      layerrule=animation_type_open:zoom,layer_name:rofi
      layerrule=animation_type_close:zoom,layer_name:rofi
      layerrule=blur:1,layer_name:waybar
      layerrule=blur:1,layer_name:rofi
    '';
  };
}
