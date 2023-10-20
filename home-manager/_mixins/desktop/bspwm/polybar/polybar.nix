{ pkgs, ... }: {
  imports = [
    ./scripts.nix
  ];
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybarFull;
      # package = pkgs.override.polybar {
      # Extra Packages
      # alsaSupport = true;
      # pulseSupport = true;
      # };
      script = "polybar desk &";
      settings = {
        "colors" = {
          background = "#282A2E";
          background-alt = "#373B41";
          foreground = "#C5C8C6";
          primary = "#F0C674";
          secondary = "#8ABEB7";
          alert = "#A54242";
          disabled = "#707880";
        };
        "bar/desk" = {
          width = "100%";
          height = "24pt";
          padding-left = 0;
          padding-right = 1;
          padding-bottom = 1;
          radius = 6;

          # dpi = 96;

          background = "\${colors.background}";
          foreground = "\${colors.foreground}";
          bottom = false;
          line-size = "3pt";
          border-top-size = 0;
          border-bottom-size = 0;
          border-size = "1.2pt";
          border-color = "#00000000";

          module-margin = 1;

          separator = "|";
          separator-foreground = "\${colors.disabled}";

          font-0 = "FiraCode Nerd Font:style=Bold:pixelsize=12;2";

          modules-left = "xworkspaces polywins";
          modules-right = "filesystem pulseaudio xkeyboard memory cpu wlan eth date powermenu";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
          enable-ipc = true;
          # ; tray-position = right

          # ; wm-restack = generic
          wm-restack = "bspwm";
          # ; wm-restack = i3

          override-redirect = true;
        };
        "module/xworkspaces" = {
          type = "internal/xworkspaces";

          label-active = "%name%";
          label-active-background = "\${colors.background-alt}";
          label-active-underline = "\${colors.primary}";
          label-active-padding = 1;

          label-occupied = "%name%";
          label-occupied-padding = 1;

          label-urgent = "%name%";
          label-urgent-background = "\${colors.alert}";
          label-urgent-padding = 1;

          label-empty = "%name%";
          label-empty-foreground = "\${colors.disabled}";
          label-empty-padding = 1;
        };
        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:60:...%";
        };
        "bar" = {
          fill = "";
          empty = "";
          indicator = "⏽";
        };
        "module/filesystem" = {
          type = "internal/fs";

          mount-0 = "/";
          interval = 30;
          fixed-values = false;
          format-mounted = "<bar-used> <label-mounted>";
          format-mounted-prefix = " ";

          format-unmounted = "<label-unmounted>";
          format-unmounted-prefix = " ";

          label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%";
          # label-mounted = "%used%/%total%";

          label-unmounted = "%mountpoint% not mounted";
          label-unmounted-foreground = "\${colors.disabled}";

          bar-used-width = 10;
          bar-used-gradient = false;

          bar-used-indicator = "\${bar.indicator}";
          bar-used-indicator-foreground = "\${color.foreground}";

          bar-used-fill = "\${bar.fill}";
          bar-used-foreground-0 = "\${color.foreground}";
          bar-used-foreground-1 = "\${color.foreground}";
          bar-used-foreground-2 = "\${color.foreground}";

          bar-used-empty = "\${bar.empty}";
          bar-used-empty-foreground = "\${color.foreground}";
        };
        "module/pulseaudio" = {
          type = "internal/pulseaudio";

          format-volume-prefix = "VOL ";
          format-volume-prefix-foreground = "\${colors.primary}";
          format-volume = "<label-volume>";

          label-volume = "%percentage%%";

          label-muted = "muted";
          label-muted-foreground = "\${colors.disabled}";
        };
        "module/xkeyboard" = {
          type = "internal/xkeyboard";
          blacklist-0 = "num lock";

          label-layout = "%layout%";
          label-layout-foreground = "\${colors.primary}";

          label-indicator-padding = 2;
          label-indicator-margin = 1;
          label-indicator-foreground = "\${colors.background}";
          label-indicator-background = "\${colors.secondary}";
        };
        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format-prefix = "RAM ";
          format-prefix-foreground = "\${colors.primary}";
          label = "%percentage_used:2%%";
        };
        "module/cpu" = {
          type = "internal/cpu";
          interval = 0.5;
          format-prefix = "CPU ";
          format-prefix-foreground = "\${colors.primary}";
          label = "%percentage:2%%";
        };
        "network-base" = {
          type = "internal/network";
          interval = 5;
          format-connected = "<label-connected>";
          format-disconnected = "<label-disconnected>";
          label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
        };
        "module/wlan" = {
          "inherit" = "network-base";
          interface-type = "wireless";
          label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
        };
        "module/eth" = {
          "inherit" = "network-base";
          interface-type = "wired";
          label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
        };
        "module/date" = {
          type = "internal/date";
          interval = 1;

          date = "%H:%M";
          date-alt = "%Y-%m-%d %H:%M:%S";

          label = "%date%";
          label-foreground = "\${colors.primary}";
        };
        "module/powermenu" = {
          type = "custom/text";
          content = "";
          icon = "";
          content-padding = 0.5;
          click-left = "bash /home/junior/.config/rofi/powermenu/powermenu.sh";
          content-foreground = "#f25287";
        };
        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = true;
        };
        "module/polywins" = {
          type = "custom/script";
          exec = "~/.config/polybar/scripts/polywins 2>/dev/null";
          format = "<label>";
          format-background = "#2a2e36";
          label = "%output%";
          label-padding = 0;
          tail = true;
        };
      };
    };
  };
}
