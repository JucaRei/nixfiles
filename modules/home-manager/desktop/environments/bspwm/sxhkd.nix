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
        # --- Aplicativos & Launchers ---
        "super + Return" = "${pkgs.alacritty}/bin/alacritty";
        "super + KP_Enter" = "${pkgs.alacritty}/bin/alacritty";
        "super + t" = "${pkgs.alacritty}/bin/alacritty";
        "super + space" = "${pkgs.rofi}/bin/rofi -show drun";
        "super + d" = "${pkgs.rofi}/bin/rofi -show drun";
        "super + shift + d" = "${pkgs.rofi}/bin/rofi -show run";
        "super + w" = "${pkgs.rofi}/bin/rofi -show window";
        "super + e" = "${pkgs.thunar}/bin/thunar";
        "super + f" = "${pkgs.thunar}/bin/thunar";

        # --- Janelas (Fechar / Matar) ---
        "super + q" = "bspc node -c";
        "super + shift + q" = "bspc node -k";

        # --- Alternar Estados (Floating / Fullscreen / Monocle) ---
        "super + s" = "bspc node -t ~floating";
        "super + shift + f" = "bspc node -t ~fullscreen";
        "super + m" = "bspc desktop -l next";

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

        # --- Screenshots (Flameshot) ---
        "Print" = "${pkgs.flameshot}/bin/flameshot gui";
        "shift + Print" = "${pkgs.flameshot}/bin/flameshot full -p ~/Pictures/";

        # --- Bloquear Sessão ---
        "super + shift + x" = "${pkgs.libnotify}/bin/notify-send 'Locking screen...'";
      };
    };
  };
}
