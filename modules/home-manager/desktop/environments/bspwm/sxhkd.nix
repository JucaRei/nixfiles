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
      default = true;
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
      keybindings = cfg.keybindings // {
        # Window management
        "super + Return" = "alacritty";
        "super + d" = "rofi -show drun";
        "super + shift + d" = "rofi -show run";

        # Close window
        "super + shift + q" = "bspc node -c";

        # Focus nodes
        "super + {_,shift + }{h,j,k,l}" = ''
          bspc node -{f,s} {west,south,north,east}
        '';

        # Focus desktops (workspaces)
        "super + {_,shift + }{1-9,0}" = ''
          bspc {desktop -f,node -d} '^{1-9,10}'
        '';

        # Resize floating nodes
        "super + alt + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

        # Toggle floating
        "super + t" = "bspc node -t ~floating";
        "super + shift + t" = "bspc node -t ~fullscreen";

        # Rotate desktop
        "super + r" = "bspc desktop -R 90";
        "super + shift + r" = "bspc wm -r";

        # Gap controls
        "super + g" = "bspc config window_gap 0";
        "super + shift + g" = "bspc config window_gap 10";

        # Volume controls (common shortcuts)
        "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioPlay" = "playerctl play-pause";
        "XF86AudioNext" = "playerctl next";
        "XF86AudioPrev" = "playerctl previous";

        # Brightness (laptops)
        "XF86MonBrightnessUp" = "brightnessctl set +5%";
        "XF86MonBrightnessDown" = "brightnessctl set 5%-";

        # Screenshot
        "Print" = "flameshot gui";
        "shift + Print" = "flameshot full -p ~/Pictures/";
      };
    };
  };
}
