{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool attrs;
  cfg = config.desktop.bspwm.sxhkd;
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

        # --- Controles de Mídia e Áudio ---
        "XF86AudioRaiseVolume" = "${pkgs.pamixer}/bin/pamixer -i 5";
        "XF86AudioLowerVolume" = "${pkgs.pamixer}/bin/pamixer -d 5";
        "XF86AudioMute" = "${pkgs.pamixer}/bin/pamixer -t";
        "XF86AudioPlay" = "${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "${pkgs.playerctl}/bin/playerctl previous";

        # --- Controle de Brilho (MacBook) ---
        "XF86MonBrightnessUp" = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86MonBrightnessDown" = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };
    };
  };
}
