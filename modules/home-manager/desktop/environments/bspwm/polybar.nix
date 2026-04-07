{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool str;
  cfg = config.desktop.bspwm.polybar;
in
{
  options.desktop.bspwm.polybar = {
    enable = mkOption {
      type = bool;
      default = true;
      description = "Enable polybar for bspwm";
    };

    theme = mkOption {
      type = str;
      default = "default";
      description = "Polybar theme name";
    };
  };

  config = mkIf cfg.enable {
    services.polybar = {
      enable = true;
      package = pkgs.polybar;
      script = ''
        #!/usr/bin/env bash

        # Kill existing bars
        polybar-msg cmd quit 2>/dev/null

        # Launch polybar on all monitors
        if type xrandr >/dev/null 2>&1; then
          for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload main &
          done
        else
          polybar --reload main &
        fi
      '';
      config = {
        "bar/main" = {
          monitor = "";
          monitor-fallback = "";
          width = "100%";
          height = "24";
          offset-x = "0";
          offset-y = "0";
          fixed-center = true;

          background = "#222222";
          foreground = "#ffffff";

          line-size = "2";
          line-color = "#5577aa";

          border-size = "0";
          border-color = "#000000";

          padding-left = "1";
          padding-right = "1";
          module-margin-left = "1";
          module-margin-right = "1";

          font-0 = "monospace:size=10;2";
          font-1 = "FontAwesome:size=10;2";
          font-2 = "NotoColorEmoji:size=10;2";

          modules-left = "bspwm";
          modules-center = "";
          modules-right = "cpu memory filesystem pulseaudio battery date";

          tray-position = "right";
          tray-padding = "2";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };

        "module/bspwm" = {
          type = "internal/bspwm";
          format = "<label-state> <label-mode>";
          label-focused = "";
          label-focused-background = "#333333";
          label-focused-underline = "#5577aa";
          label-focused-padding = "2";
          label-occupied = "";
          label-occupied-padding = "2";
          label-urgent = "";
          label-urgent-background = "#aa3333";
          label-urgent-padding = "2";
          label-empty = "";
          label-empty-foreground = "#666666";
          label-empty-padding = "2";
          label-monocle = "M";
          label-tiled = "T";
          label-floating = " |";
          label-pseudotiled = "P";
          label-fullscreen = " F";
          label-locked = " ";
          label-sticky = " ";
          label-private = " ";
        };

        "module/cpu" = {
          type = "internal/cpu";
          interval = "2";
          format = "<label> <ramp-coreload>";
          label = "CPU";
          ramp-coreload-0 = "▁";
          ramp-coreload-1 = "▂";
          ramp-coreload-2 = "▃";
          ramp-coreload-3 = "▄";
          ramp-coreload-4 = "▅";
          ramp-coreload-5 = "▆";
          ramp-coreload-6 = "▇";
          ramp-coreload-7 = "█";
        };

        "module/memory" = {
          type = "internal/memory";
          interval = "3";
          format = "<label>";
          label = "MEM %percentage_used%%";
        };

        "module/filesystem" = {
          type = "internal/fs";
          interval = "30";
          mount-0 = "/";
          label-mounted = "%{F#5577aa}%mountpoint%%{F-}: %percentage_used%%";
          label-unmounted = "%mountpoint%: not mounted";
        };

        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          format-volume = "<label-volume> <bar-volume>";
          label-volume = "VOL";
          label-muted = "MUTED";
          label-muted-foreground = "#666666";
          bar-volume-width = "10";
          bar-volume-0 = "▁";
          bar-volume-1 = "▂";
          bar-volume-2 = "▃";
          bar-volume-3 = "▄";
          bar-volume-4 = "▅";
          bar-volume-5 = "▆";
          bar-volume-6 = "▇";
          bar-volume-7 = "█";
          bar-volume-gradient = false;
          bar-volume-indicator = "|";
          bar-volume-fill = "-";
          bar-volume-empty = "-";
          bar-volume-empty-foreground = "#666666";
          click-right = "pavucontrol";
        };

        "module/battery" = {
          type = "internal/battery";
          battery = "BAT0";
          adapter = "AC";
          full-at = "98";
          format-charging = "<animation-charging> <label-charging>";
          format-discharging = "<ramp-capacity> <label-discharging>";
          format-full = "<label-full>";
          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";
          label-full = "Full";
          ramp-capacity-0 = "";
          ramp-capacity-1 = "";
          ramp-capacity-2 = "";
          ramp-capacity-3 = "";
          ramp-capacity-4 = "";
          animation-charging-0 = "";
          animation-charging-1 = "";
          animation-charging-2 = "";
          animation-charging-3 = "";
          animation-charging-4 = "";
          animation-charging-framerate = "750";
        };

        "module/date" = {
          type = "internal/date";
          interval = "1";
          date = "%Y-%m-%d";
          time = "%H:%M";
          label = "%date% %time%";
        };

        "settings" = {
          screenchange-reload = "true";
          pseudo-transparency = "true";
        };
      };
    };
  };
}
