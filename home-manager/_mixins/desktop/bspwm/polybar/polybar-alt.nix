{ pkgs, ... }: {
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybar;
      script = "";
      settings = {
        # https://github.com/gh0stzk/dotfiles By z0mbi3

        # Colors.ini
        "color" = {
          # ;; Dark Add FC at the beginning #FC1E1F29 for 99 transparency
          bg = "#1b1a27";
          fg = "#F1F1F1";
          mb = "#26233a";

          trans = "#00000000";
          white = "#FFFFFF";
          black = "#000000";

          # ;; Colors

          red = "#eb6f92";
          purple = "#583794";
          blue = "#7aa2f7";
          cyan = "#4DD0E1";
          teal = "#00B19F";
          green = "#9ece6a";
          lime = "#B9C244";
          yellow = "#e0af68";
          amber = "#f6c177";
          orange = "#E57C46";
          brown = "#AC8476";
          grey = "#8C8C8C";
          indigo = "#6C77BB";
          blue-gray = "#6D8895";
        };
        # Config.ini
        "global/wm" = {

          margin-bottom = 0;
          margin-top = 0;
        };
        "bar/mybar" = {

          monitor-strict = false;

          override-redirect = false;

          bottom = false;
          fixed-center = true;

          width = "90%";
          height = 30;
          offset-x = "5%";
          offset-y = "1.25%";

          background = "\${color.bg}";
          foreground = "\${color.fg}";

          radius = 4.0;

          line-size = 2;
          line-color = "\${color.blue}";

          border-size = "8px";
          border-color = "\${color.bg}";

          padding = 1;

          module-margin-left = 0;
          module-margin-right = 0;

          # Text
          font-0 = "Maple Mono NF:size=11;2";
          # Icons
          font-1 = "Font Awesome 6 Pro Solid:size=11;3";
          font-2 = "Material Design Icons Desktop:size=12;3";
          font-3 = "Material Design Icons Desktop:size=15;3";
          # Glyphs
          font-4 = "MesloLGS NF:style=Regular:size=15;4";
          # Chinese
          font-5 = "Maple Mono SC NF:size=11;2";
          dpi = 96;

          modules-left = "powermenu blank separator blank bi bspwm bd";
          modules-center = "date";
          modules-right = "bi cpu_bar bd blank bi memory_bar bd blank bi pulseaudio bd blank bi network bd";

          spacing = 0;
          separator = "";
          dim-value = 1.0;

          # ;
          # ;locale = pt_BR.UTF-8

          tray-position = "right";
          tray-detached = false;
          tray-maxsize = 16;
          tray-background = "\${color.bg}";
          tray-offset-x = 0;
          tray-offset-y = 0;
          tray-padding = 0;
          tray-scale = 1.0;

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "pointer";
          cursor-scroll = "";

        };
        "settings" = {

          screenchange-reload = false;

          compositing-background = "source";
          compositing-foreground = "over";
          compositing-overline = "over";
          compositing-underline = "over";
          compositing-border = "over";

          pseudo-transparency = false;
        };
        # ; modified https://github.com/gh0stzk/dotfiles
        # Modules.ini
        "module/bi" = {
          type = "custom/text";
          content = "%{T5}%{T-}";
          content-foreground = "\${color.mb}";
          content-background = "\${color.bg}";
        };
        "module/bd" = {
          type = "custom/text";
          content = "%{T5}%{T-}";
          content-foreground = "\${color.mb}";
          content-background = "\${color.bg}";
        };
        ######################################################

        "module/date" = {
          type = "internal/date";

          interval = 1.0;

          time = "%H:%M";
          format-background = "\${color.bg}";
          format-foreground = "\${color.fg}";
          date-alt = " %A, %d %B %Y";

          format = "<label>";
          format-prefix = "";
          format-prefix-background = "\${color.bg}";
          format-prefix-foreground = "\${color.blue-gray}";

          label = "%date% %time%";

        };
        "module/network" = {
          type = "internal/network";
          interface = "wlp0s20f0u1";

          interval = 3.0;
          accumulate-stats = true;
          unknown-as-up = true;

          format-connected = "<label-connected>";
          format-connected-prefix = "󰖩";
          format-connected-background = "\${color.mb}";
          format-connected-foreground = "\${color.green}";

          speed-unit = "";
          label-connected = " %netspeed%";
          label-connected-background = "\${color.mb}";
          label-connected-foreground = "\${color.amber}";

          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "󰖪";

          format-disconnected-background = "\${color.mb}";
          format-disconnected-foreground = "\${color.red}";

          label-disconnected = "not connected";
          label-disconnected-foreground = "\${color.red}";
        };
        ######################################################

        "module/pulseaudio" = {
          type = "internal/pulseaudio";

          use-ui-max = true;
          interval = 2;

          format-volume = "<ramp-volume><label-volume>";
          format-volume-prefix = "";
          format-volume-background = "\${color.mb}";
          format-volume-foreground = "\${color.indigo}";

          label-volume = " %percentage% ";
          label-volume-background = "\${color.mb}";
          label-volume-foreground = "\${color.fg}";

          format-muted = "<label-muted>";
          format-muted-prefix = "󰆪";
          format-muted-foreground = "\${color.red}";
          format-muted-background = "\${color.mb}";
          label-muted = " Muted";
          label-muted-foreground = "\${color.red}";
          label-muted-background = "\${color.mb}";

          ramp-volume-0 = "󰕿";
          ramp-volume-1 = "󰖀";
          ramp-volume-2 = "󰕾";
          ramp-volume-3 = "󰕾";
          ramp-volume-4 = "󱄡";
          ramp-volume-font = 4;

          click-right = "bspc rule -a Pavucontrol -o state=floating follow=on center=true && pavucontrol";
        };
        ######################################################

        "module/bspwm" = {
          type = "internal/bspwm";

          enable-click = true;
          enable-scroll = true;
          reverse-scroll = true;
          pin-workspaces = true;
          occupied-scroll = false;


          format = "<label-state>";

          label-focused = "";
          label-focused-background = "\${color.mb}";
          label-focused-padding = 1;
          label-focused-foreground = "\${color.amber}";

          label-occupied = "";
          label-occupied-padding = 1;
          label-occupied-background = "\${color.mb}";
          label-occupied-foreground = "\${color.blue}";

          label-urgent = "%icon%";
          label-urgent-padding = 0;

          label-empty = "";
          label-empty-foreground = "\${color.purple}";
          label-empty-padding = 1;
          label-empty-background = "\${color.mb}";
        };
        ######################################################

        "module/powermenu" = {
          type = "custom/text";

          content = "⏻";
          content-foreground = "\${color.red}";
          content-font = 4;

          click-left = "~/dotfiles/rofi/powermenu/powermenu";
          click-right = " ~/dotfiles/rofi/powermenu/powermenu";
        };
        ######################################################

        "module/blank" = {
          type = "custom/text";
          content = " ";
          content-foreground = "\${color.bg}";
        };
        ######################################################

        "module/separator" = {
          type = "custom/text";
          content = "|";
          content-foreground = "\${color.grey}";
        };
        ######################################################

        "module/cpu_bar" = {
          type = "internal/cpu";

          interval = 0.5;

          format = "<label>";
          format-prefix = " ";
          format-prefix-background = "\${color.mb}";
          format-prefix-foreground = "\${color.red}";

          label = "%percentage%%";
          label-background = "\${color.mb}";
        };
        ######################################################

        "module/memory_bar" = {
          type = "internal/memory";

          interval = 3;

          format = "<label>";
          format-prefix = "󰀹 ";
          format-prefix-background = "\${color.mb}";
          format-prefix-foreground = "\${color.cyan}";

          label = "%used%";
          label-background = "\${color.mb}";
        };
      };
    };
  };
}
