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

  # --- Script de Notificação de Volume (Dunst OSD) ---
  volumeOsd = pkgs.writeShellScript "volume-osd" ''
    case "$1" in
      up)   ${pkgs.pamixer}/bin/pamixer -i 5 ;;
      down) ${pkgs.pamixer}/bin/pamixer -d 5 ;;
      mute) ${pkgs.pamixer}/bin/pamixer -t ;;
    esac

    vol=$(${pkgs.pamixer}/bin/pamixer --get-volume 2>/dev/null || echo "0")
    is_muted=$(${pkgs.pamixer}/bin/pamixer --get-mute 2>/dev/null || echo "false")

    if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "audio-volume-muted" -r 9991 -h int:value:0 -t 1500 "Volume: Mudo"
    else
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "audio-volume-high" -r 9991 -h int:value:"$vol" -t 1500 "Volume: $vol%"
    fi
  '';

  # --- Script de Notificação de Brilho da Tela (Dunst OSD) ---
  brightnessOsd = pkgs.writeShellScript "brightness-osd" ''
    case "$1" in
      up)   ${pkgs.brightnessctl}/bin/brightnessctl set +2% ;;
      down) ${pkgs.brightnessctl}/bin/brightnessctl set 2%- ;;
    esac

    val=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4 | tr -d '%')
    ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "display-brightness" -r 9992 -h int:value:"$val" -t 1500 "Brilho da Tela: $val%"
  '';

  # --- Script de Controle e Notificação de Luz do Teclado (MacBook kbd_backlight) ---
  kbdBrightnessOsd = pkgs.writeShellScript "kbd-brightness-osd" ''
    # Identificar dispositivo de iluminação de teclado
    dev="smc::kbd_backlight"
    if ! ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" info >/dev/null 2>&1; then
      dev=$(${pkgs.brightnessctl}/bin/brightnessctl --list | grep -m1 "kbd_backlight" | cut -d\' -f2)
    fi

    if [ -n "$dev" ]; then
      case "$1" in
        up)     ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +10% ;;
        down)   ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 10%- ;;
        toggle)
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m | cut -d, -f4 | tr -d '%')
          if [ "$curr" -gt 0 ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 0%
          else
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 50%
          fi
          ;;
      esac

      val=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m | cut -d, -f4 | tr -d '%')
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -h int:value:"$val" -t 1500 "Luz do Teclado: $val%"
    fi
  '';

  # --- Dashboard Unificado: Quick Settings + Manual de Atalhos (Estilo Hyprland) ---
  quickSettings = pkgs.writeShellScript "quick-settings" ''
    show_manual() {
      KB_LIST="󰌌  Super + Space / Super + D     ➜  Lançador de Aplicativos (Rofi)
󰌌  Super + Enter / Super + T     ➜  Abrir Terminal (Alacritty)
󰌌  Super + E / Super + Shift + E ➜  Gerenciador de Arquivos (Thunar)
󰌌  Super + , / Super + C / Botão Dir. ➜ Painel Quick Settings / Preferências
󰌌  Super + / ou Super + F1       ➜  Manual e Guia de Atalhos (Cheat-Sheet)
󰌌  Alt + Tab / Super + W         ➜  Alternador de Janelas Abertas
󰌌  Super + U                     ➜  Terminal Flutuante Rápido (Scratchpad)
󰌌  Super + Q / Super + Shift + Q ➜  Fechar / Encerrar Janela
󰌌  Super + Alt + Esc             ➜  Forçar Fechamento de Janela Travada
󰌌  Super + Ctrl + F              ➜  Alternar Tela Cheia (Fullscreen)
󰌌  Super + S                     ➜  Alternar Janela Flutuante (Floating/Tiling)
󰌌  Super + M                     ➜  Modo Monocle (Foco em Janela Única)
󰌌  Super + {H,J,K,L} ou Setas    ➜  Navegar Foco Entre Janelas (Vim/Setas)
󰌌  Super + Shift + {H,J,K,L}     ➜  Mover / Trocar Posição da Janela
󰌌  Super + Alt + {H,J,K,L}/Setas ➜  Redimensionar Tamanho da Janela
󰌌  Super + Botão Esquerdo        ➜  Mover Janela Flutuante com o Mouse
󰌌  Super + Botão Direito         ➜  Redimensionar Janela com o Mouse
󰌌  Super + 1..9, 0               ➜  Ir para Área de Trabalho (Workspace) 1 a 10
󰌌  Super + Shift + 1..9, 0       ➜  Enviar Janela para Workspace 1 a 10
󰌌  Super + Shift + 3 / Shift+Prt ➜  Captura de Tela Inteira (salva em ~/Pictures)
󰌌  Super + Shift + 4 / Print     ➜  Seleção de Área para Captura (Flameshot)
󰌌  Super + Shift + 5             ➜  Interface Gráfica de Capturas
󰌌  Super + Shift + R             ➜  Recarregar BSPWM e Polybar
󰌌  Super + Ctrl + Q              ➜  Bloquear Sessão do Usuário
󰌌  Teclas de Volume / Brilho     ➜  Controle com Feedback Visual OSD"

      CHOICE=$(echo "$KB_LIST" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰌌 Manual de Atalhos (Keybinds) " -theme-str 'window { width: 720px; height: 520px; } listview { columns: 1; lines: 12; }')

      case "$CHOICE" in
        *"Lançador de Aplicativos"*) ${pkgs.rofi}/bin/rofi -show drun ;;
        *"Abrir Terminal"*) ${pkgs.alacritty}/bin/alacritty & ;;
        *"Gerenciador de Arquivos"*) ${pkgs.xfce.thunar}/bin/thunar ~ & ;;
        *"Painel Quick Settings"*) show_control_center ;;
        *"Alternador de Janelas"*) ${pkgs.rofi}/bin/rofi -show window ;;
        *"Terminal Flutuante"*) ${pkgs.tdrop}/bin/tdrop -am -w 80% -h 40% -x 10% -y 10% ${pkgs.alacritty}/bin/alacritty ;;
        *"Fechar / Encerrar Janela"*) bspc node -c ;;
        *"Tela Cheia"*) bspc node -t ~fullscreen ;;
        *"Janela Flutuante"*) bspc node -t ~floating ;;
        *"Captura de Tela Inteira"*) ${pkgs.flameshot}/bin/flameshot full -p ~/Pictures/ ;;
        *"Seleção de Área"*) ${pkgs.flameshot}/bin/flameshot gui ;;
        *"Recarregar BSPWM"*) bspc wm -r ;;
        *"Bloquear Sessão"*) loginctl lock-session ;;
      esac
    }

    show_control_center() {
      OPT_RES="󰍹  Resolução da Tela (Display Resolution)"
      OPT_SOUND="󰕾  Controle de Áudio & Volume (Pavucontrol)"
      OPT_NET="󰖩  Wi-Fi & Conexões (NetworkManager)"
      OPT_THEME="󰔎  Aparência, Ícones & Temas (LXAppearance)"
      OPT_WALL="󰸉  Papel de Parede (Wallpaper)"
      OPT_FILES="󰉋  Gerenciador de Arquivos (Thunar)"
      OPT_TERM="󰞷  Abrir Terminal (Alacritty)"
      OPT_KEYS="󰌌  Manual & Guia de Atalhos (Keybinds)"
      OPT_RELOAD="󰑐  Recarregar BSPWM & Polybar"
      OPT_POWER="󰐥  Menu de Energia & Bloqueio de Sessão"

      CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s" \
        "$OPT_RES" \
        "$OPT_SOUND" \
        "$OPT_NET" \
        "$OPT_THEME" \
        "$OPT_WALL" \
        "$OPT_FILES" \
        "$OPT_TERM" \
        "$OPT_KEYS" \
        "$OPT_RELOAD" \
        "$OPT_POWER" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󱗼 Quick Settings ")

      case "$CHOICE" in
        "$OPT_RES")
          R_1080="1920x1080 (Full HD 1080p)"
          R_2K="2560x1440 (Quad HD 2K)"
          R_900="1600x900 (HD+)"
          R_768="1366x768 (HD)"
          R_CUSTOM="⚙ Painel Avançado de Telas (ARandR)"

          RES=$(printf "%s\n%s\n%s\n%s\n%s" "$R_1080" "$R_2K" "$R_900" "$R_768" "$R_CUSTOM" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰍹 Selecionar Resolução ")
          case "$RES" in
            "$R_1080") ${pkgs.xorg.xrandr}/bin/xrandr -s 1920x1080 ;;
            "$R_2K")   ${pkgs.xorg.xrandr}/bin/xrandr -s 2560x1440 ;;
            "$R_900")  ${pkgs.xorg.xrandr}/bin/xrandr -s 1600x900 ;;
            "$R_768")  ${pkgs.xorg.xrandr}/bin/xrandr -s 1366x768 ;;
            "$R_CUSTOM") ${pkgs.arandr}/bin/arandr || ${pkgs.xorg.xrandr}/bin/xrandr ;;
          esac
          ;;
        "$OPT_SOUND") ${pkgs.pavucontrol}/bin/pavucontrol & ;;
        "$OPT_NET") ${pkgs.networkmanagerapplet}/bin/nm-connection-editor & ;;
        "$OPT_THEME") ${pkgs.lxappearance}/bin/lxappearance & ;;
        "$OPT_WALL") ${pkgs.nitrogen}/bin/nitrogen || ${pkgs.feh}/bin/feh & ;;
        "$OPT_FILES") ${pkgs.xfce.thunar}/bin/thunar ~ & ;;
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
in
{
  options.desktop.bspwm.sxhkd = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable sxhkd keybindings for bspwm";
    };

    keybindings = mkOption {
      type = attrs;
      default = { };
      description = "sxhkd keybindings";
    };
  };

  config = mkIf cfg.enable {
    services.sxhkd = {
      enable = true;
      package = pkgs.sxhkd;
      keybindings = cfg.keybindings // {
        # --- Clique no Desktop / Control Center (Estilo Hyprland / SwayNC) ---
        # Botão Direito no Desktop (Root Window sem janela)
        "~button3" = "if [ -z \"$(bspc query -N -n pointed.window 2>/dev/null)\" ]; then ${quickSettings}; fi";
        "super + button3" = "${quickSettings}";
        "super + comma" = "${quickSettings}"; # Cmd + , (Atalho universal de Preferências)
        "super + p" = "${quickSettings}";
        "super + c" = "${quickSettings}"; # Control Center
        "super + slash" = "${quickSettings} --manual"; # Cmd + / (Manual & Cheat-Sheet de Atalhos)
        "super + F1" = "${quickSettings} --manual"; # F1 (Ajuda do Sistema)

        # --- Aplicativos & Launchers (macOS Style) ---
        # Spotlight (Cmd + Space) e Rofi Drun
        "super + space" = "${pkgs.rofi}/bin/rofi -show drun";
        "super + d" = "${pkgs.rofi}/bin/rofi -show drun";
        "super + shift + d" = "${pkgs.rofi}/bin/rofi -show run";

        # Terminal (Cmd + Return, Cmd + T)
        "super + Return" = "${pkgs.alacritty}/bin/alacritty";
        "super + KP_Enter" = "${pkgs.alacritty}/bin/alacritty";
        "super + t" = "${pkgs.alacritty}/bin/alacritty";

        # Finder / Gerenciador de Arquivos (Cmd + Shift + F, Cmd + E)
        "super + e" = "${pkgs.thunar}/bin/thunar";
        "super + shift + e" = "${pkgs.thunar}/bin/thunar";

        # Alternador de Janelas (Cmd + Tab / Cmd + W)
        "alt + Tab" = "${pkgs.rofi}/bin/rofi -show window";
        "super + w" = "${pkgs.rofi}/bin/rofi -show window";

        # Terminal Scratchpad (Cmd + U)
        "super + u" = "${pkgs.tdrop}/bin/tdrop -am -w 80% -h 40% -x 10% -y 10% ${pkgs.alacritty}/bin/alacritty";

        # --- Janelas (macOS Style: Cmd + Q / Cmd + Opt + Esc) ---
        "super + q" = "bspc node -c";
        "super + alt + Escape" = "bspc node -k";
        "super + shift + q" = "bspc node -k";

        # --- Estados de Janela (macOS Style: Cmd + Ctrl + F Fullscreen) ---
        "super + ctrl + f" = "bspc node -t ~fullscreen";
        "super + s" = "bspc node -t ~floating";
        "super + m" = "bspc desktop -l next";

        # --- Screenshots (macOS Style: Cmd + Shift + 3 / 4 / 5) ---
        # Cmd + Shift + 3: Captura de tela inteira salva em ~/Pictures
        "super + shift + 3" = "${pkgs.flameshot}/bin/flameshot full -p ~/Pictures/";
        # Cmd + Shift + 4: Seleção interativa de área
        "super + shift + 4" = "${pkgs.flameshot}/bin/flameshot gui";
        # Cmd + Shift + 5: Ferramenta GUI de captura
        "super + shift + 5" = "${pkgs.flameshot}/bin/flameshot gui";
        # Atalhos padrão PrintScreen (fallback)
        "Print" = "${pkgs.flameshot}/bin/flameshot gui";
        "shift + Print" = "${pkgs.flameshot}/bin/flameshot full -p ~/Pictures/";

        # --- Bloqueio & Sessão (macOS Style: Cmd + Ctrl + Q) ---
        "super + ctrl + q" = "loginctl lock-session";
        "super + shift + x" = "loginctl lock-session";

        # --- Foco e Movimento em Janelas (Vim + Setas) ---
        "super + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
        "super + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
        "super + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}";
        "super + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";

        # --- Áreas de Trabalho (Workspaces 1-10) ---
        "super + {1-9,0}" = "bspc desktop -f '^{1-9,10}'";
        "super + shift + {1-9,0}" = "bspc node -d '^{1-9,10}'";

        # --- Redimensionar Janelas (Super + Alt + Setas/Vim) ---
        "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
        "super + alt + {Left,Down,Up,Right}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";

        # --- Reiniciar / Recarregar BSPWM e SXHKD ---
        "super + shift + r" = "bspc wm -r";
        "super + Escape" = "pkill -USR1 -x sxhkd";

        # --- Controles de Mídia e Áudio com Dunst OSD ---
        "XF86AudioRaiseVolume" = "${volumeOsd} up";
        "XF86AudioLowerVolume" = "${volumeOsd} down";
        "XF86AudioMute" = "${volumeOsd} mute";
        "XF86AudioPlay" = "${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "${pkgs.playerctl}/bin/playerctl previous";

        # --- Controle de Brilho da Tela (MacBook F1 / F2) ---
        "XF86MonBrightnessUp" = "${brightnessOsd} up";
        "XF86MonBrightnessDown" = "${brightnessOsd} down";

        # --- Controle de Iluminação do Teclado (MacBook F5 / F6) ---
        "XF86KbdBrightnessUp" = "${kbdBrightnessOsd} up";
        "XF86KbdBrightnessDown" = "${kbdBrightnessOsd} down";
        "XF86KbdLightOnOff" = "${kbdBrightnessOsd} toggle";
        "super + F6" = "${kbdBrightnessOsd} up";
        "super + F5" = "${kbdBrightnessOsd} down";
        "super + shift + F5" = "${kbdBrightnessOsd} toggle";
      };
    };
  };
}
