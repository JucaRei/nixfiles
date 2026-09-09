{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.mangowm;

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
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +5% >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          fi
          ;;
        down)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 5%- >/dev/null 2>&1
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
    fi
  '';

  # Controle de Brilho da Tela com OSD Dunst
  monBrightnessOsd = pkgs.writeShellScript "mango-mon-brightness-osd" ''
    case "$1" in
      up) ${pkgs.brightnessctl}/bin/brightnessctl set 5%+ ;;
      down) ${pkgs.brightnessctl}/bin/brightnessctl set 5%- ;;
    esac
    val=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4 | tr -d '%')
    if [ -n "$val" ]; then
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "display-brightness" -r 9992 -h int:value:"$val" -t 1500 "Brilho da Tela: $val%"
    fi
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
      exec-once=${pkgs.waybar}/bin/waybar
      exec-once=${pkgs.dunst}/bin/dunst
      exec-once=${pkgs.hypridle}/bin/hypridle
      exec-once=${pkgs.hyprpaper}/bin/hyprpaper
      exec-once=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      exec-once=${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store
      exec-once=${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store

      # ============================================================================
      # Atalhos de Teclado (Keybindings)
      # ============================================================================

      # Recarregar Configuração
      bind=SUPER,r,reload_config

      # Aplicativos e Utilitários
      bind=SUPER,Return,spawn,${pkgs.alacritty}/bin/alacritty
      bind=SUPER,space,spawn,${pkgs.rofi}/bin/rofi -show drun
      bind=SUPER,d,spawn,${pkgs.rofi}/bin/rofi -show drun
      bind=SUPER,e,spawn,${pkgs.thunar}/bin/thunar
      bind=SUPER,v,spawn,${cliphistMenu}
      bind=SUPER,l,spawn,${pkgs.hyprlock}/bin/hyprlock
      bind=SUPER,Escape,spawn,session-power-menu
      bind=SUPER+SHIFT,e,spawn,session-power-menu
      bind=SUPER+SHIFT,q,quit

      # Gerenciamento de Janelas
      bind=SUPER,q,killclient,
      bind=SUPER,c,killclient,
      bind=SUPER,f,togglefullscreen,
      bind=SUPER+SHIFT,space,togglefloating,
      bind=SUPER,n,switch_layout
      bind=SUPER,Tab,focusstack,next
      bind=SUPER,backslash,togglefloating,

      # Foco Direcional
      bind=SUPER,Left,focusdir,left
      bind=SUPER,Right,focusdir,right
      bind=SUPER,Up,focusdir,up
      bind=SUPER,Down,focusdir,down

      # Trocar Janelas de Posição
      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Right,exchange_client,right
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down

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

      bind=SUPER+SHIFT,1,tag,1,0
      bind=SUPER+SHIFT,2,tag,2,0
      bind=SUPER+SHIFT,3,tag,3,0
      bind=SUPER+SHIFT,4,tag,4,0
      bind=SUPER+SHIFT,5,tag,5,0
      bind=SUPER+SHIFT,6,tag,6,0
      bind=SUPER+SHIFT,7,tag,7,0
      bind=SUPER+SHIFT,8,tag,8,0
      bind=SUPER+SHIFT,9,tag,9,0

      # Teclas Multimídia e Áudio
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
      bind=NONE,Print,spawn,${screenshotFull}
      bind=SUPER+SHIFT,S,spawn,${screenshotArea}

      # Mouse
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_right,moveresize,curresize
      mousebind=NONE,btn_middle,togglemaximizescreen,0

      # Regras de Camada (Layer Rules)
      layerrule=animation_type_open:zoom,layer_name:rofi
      layerrule=animation_type_close:zoom,layer_name:rofi
    '';
  };
}
