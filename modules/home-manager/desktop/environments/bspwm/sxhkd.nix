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

        # Preferências do Sistema (Cmd + ,)
        "super + comma" = "${pkgs.lxappearance}/bin/lxappearance";

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
