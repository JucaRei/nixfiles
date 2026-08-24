{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.polybar;
in
{
  options.desktop.bspwm.polybar = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable polybar for bspwm";
    };
  };

  config = mkIf cfg.enable {
    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        pulseSupport = true;
        i3Support = false;
      };
      script = ''
        polybar-msg cmd quit 2>/dev/null || true
        pkill -x polybar || true
        while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

        if type xrandr >/dev/null 2>&1; then
          for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload main &
          done
        else
          polybar --reload main &
        fi
      '';
      config = {
        "colors" = {
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
          surface0 = "#313244";
          surface1 = "#45475a";
          text = "#cdd6f4";
          subtext0 = "#a6adc8";
          blue = "#89b4fa";
          lavender = "#b4befe";
          sapphire = "#74c7ec";
          sky = "#89dceb";
          teal = "#94e2d5";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          peach = "#fab387";
          maroon = "#eba0ac";
          red = "#f38ba8";
          mauve = "#cba6f7";
          flamingo = "#f2cdcd";
          rosewater = "#f5e0dc";
          transparent = "#00000000";
        };

        "bar/main" = {
          width = "100%";
          height = "26";
          radius = 0;
          fixed-center = true;

          background = "\${colors.base}";
          foreground = "\${colors.text}";

          line-size = 2;
          line-color = "\${colors.blue}";

          border-size = 0;
          padding-left = 1;
          padding-right = 2;
          module-margin = 1;

          font-0 = "Inter:size=10;2";
          font-1 = "Symbols Nerd Font:size=11;2";
          font-2 = "JetBrainsMono Nerd Font:size=10;2";

          modules-left = "bspwm xwindow";
          modules-center = "";
          modules-right = "pulseaudio backlight battery cpu memory date";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";

          enable-ipc = true;
          wm-restack = "bspwm";
        };

        "module/bspwm" = {
          type = "internal/bspwm";
          pin-workspaces = true;
          enable-click = true;
          enable-scroll = true;
          reverse-scroll = false;

          format = "<label-state> <label-mode>";

          label-focused = "%name%";
          label-focused-foreground = "\${colors.base}";
          label-focused-background = "\${colors.blue}";
          label-focused-padding = 2;
          label-focused-margin = 0;

          label-occupied = "%name%";
          label-occupied-foreground = "\${colors.text}";
          label-occupied-background = "\${colors.surface0}";
          label-occupied-padding = 2;
          label-occupied-margin = 0;

          label-urgent = "%name%";
          label-urgent-foreground = "\${colors.base}";
          label-urgent-background = "\${colors.red}";
          label-urgent-padding = 2;
          label-urgent-margin = 0;

          label-empty = "%name%";
          label-empty-foreground = "\${colors.subtext0}";
          label-empty-background = "\${colors.mantle}";
          label-empty-padding = 2;
          label-empty-margin = 0;

          label-monocle = " [M]";
          label-monocle-foreground = "\${colors.yellow}";
          label-floating = " [F]";
          label-floating-foreground = "\${colors.peach}";
          label-fullscreen = " [MAX]";
          label-fullscreen-foreground = "\${colors.mauve}";
        };

        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:45:...%";
          label-foreground = "\${colors.subtext0}";
          label-padding = 1;
        };

        "module/cpu" = {
          type = "internal/cpu";
          interval = 2;
          format-prefix = "󰍛 ";
          format-prefix-foreground = "\${colors.teal}";
          label = "%percentage:2%%";
          label-foreground = "\${colors.text}";
        };

        "module/memory" = {
          type = "internal/memory";
          interval = 3;
          format-prefix = "󰘚 ";
          format-prefix-foreground = "\${colors.mauve}";
          label = "%percentage_used:2%%";
          label-foreground = "\${colors.text}";
        };

        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          use-ui-max = true;
          interval = 5;

          format-volume = "<ramp-volume> <label-volume>";
          label-volume = "%percentage%%";
          label-volume-foreground = "\${colors.text}";

          ramp-volume-0 = "󰕿";
          ramp-volume-1 = "󰖀";
          ramp-volume-2 = "󰕾";
          ramp-volume-foreground = "\${colors.blue}";

          format-muted = "<label-muted>";
          format-muted-prefix = "󰝟 ";
          format-muted-prefix-foreground = "\${colors.red}";
          label-muted = "mute";
          label-muted-foreground = "\${colors.subtext0}";

          click-right = "pavucontrol";
        };

        "module/backlight" = {
          type = "internal/backlight";
          card = "nv_backlight";
          use-actual-brightness = true;
          enable-scroll = true;

          format = "<ramp> <label>";
          label = "%percentage%%";
          label-foreground = "\${colors.text}";

          ramp-0 = "󰃞";
          ramp-1 = "󰃝";
          ramp-2 = "󰃟";
          ramp-3 = "󰃠";
          ramp-foreground = "\${colors.yellow}";
        };

        "module/battery" = {
          type = "internal/battery";
          full-at = 98;
          low-at = 15;
          battery = "BAT0";
          adapter = "ADP1";
          poll-interval = 5;

          format-charging = "<animation-charging> <label-charging>";
          format-discharging = "<ramp-capacity> <label-discharging>";
          format-full = "<ramp-capacity> <label-full>";

          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";
          label-full = "100%";

          ramp-capacity-0 = "󰂎";
          ramp-capacity-1 = "󰁺";
          ramp-capacity-2 = "󰁻";
          ramp-capacity-3 = "󰁼";
          ramp-capacity-4 = "󰁽";
          ramp-capacity-5 = "󰁾";
          ramp-capacity-6 = "󰁿";
          ramp-capacity-7 = "󰂀";
          ramp-capacity-8 = "󰂁";
          ramp-capacity-9 = "󰂂";
          ramp-capacity-10 = "󰁹";
          ramp-capacity-foreground = "\${colors.green}";

          animation-charging-0 = "󰂆";
          animation-charging-1 = "󰂇";
          animation-charging-2 = "󰂈";
          animation-charging-3 = "󰂉";
          animation-charging-4 = "󰂊";
          animation-charging-5 = "󰂋";
          animation-charging-6 = "󰂅";
          animation-charging-foreground = "\${colors.green}";
          animation-charging-framerate = 750;
        };

        "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%d/%m";
          time = "%H:%M";
          date-alt = "%A, %d %B %Y";
          time-alt = "%H:%M:%S";

          format = "<label>";
          format-prefix = "󰥔 ";
          format-prefix-foreground = "\${colors.sapphire}";
          label = "%date% %time%";
          label-foreground = "\${colors.text}";
        };

        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = false;
        };
      };
    };
  };
}
