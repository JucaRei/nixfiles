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
          # background = "#282A2E";
          # background-alt = "#373B41";
          # foreground = "#C5C8C6";
          # primary = "#F0C674";
          # secondary = "#8ABEB7";
          # alert = "#A54242";
          # disabled = "#707880";

          background = "#21252A";
          foreground = "#C8CCD4";

          color0 = "#21252A";
          color1 = "#e06c75";
          color3 = "#98c379";
          color4 = "#61afef";
          color5 = "#c678dd";
          color6 = "#56b6c2";
          color7 = "#abb2bf";
          color8 = "#545862";
          color9 = "#e06c75";
          color10 = "#9bdead";
          color11 = "#f4d67a";
          color12 = "#6cb5ed";
          color13 = "#ce89df";
          color14 = "#67cbe7";
          color15 = "#bdc3c2";
          color16 = "#EB721E";
          color22 = "#c8ccd4";
          dark-light = "#272A2B";
          active-light = "#313435";
          alpha = "#0000ffff";
          bg = "#960000";
          bg1 = "#141a21";
          bg2 = "#081F2D";
          fg = "#D3EBE9";
          fg1 = "#D3EBE9";
          # ;; for 50% transparent
          trans1 = "#80000000";
          # ;; 100% transparent
          trans2 = "#00";

          black = "#0A0F14";
          red = "#C33027";
          green = "#26A98B";
          yellow = "#EDB54B";
          blue = "#33859D";
          purple = "#888BA5";
          indigo = "#093748";
          indigolight = "#195465";
          teal = "#599CAA";
          gray = "#4E5165";
          MAGENTA = "#B48EAD";
          CYAN = "#88C0D0";
          WHITE = "#E5E9F0";
          ALTBLACK = "#4C566A";
          ALTRED = "#BF616A";
          ALTGREEN = "#A3BE8C";
          ALTYELLOW = "#EBCB8B";
          ALTBLUE = "#81A1C1";
          ALTMAGENTA = "#B48EAD";
          ALTCYAN = "#8FBCBB";
          ALTWHITE = "#ECEFF4";
        };
        "bar/desk" = {
          width = "100%";
          height = "24pt";
          padding-left = 0;
          padding-right = 1;
          padding-bottom = 1;
          radius = 4;

          # dpi = 96;

          background = "\${colors.background}";
          foreground = "\${colors.foreground}";
          bottom = false;
          line-size = "3pt";
          border-top-size = 0;
          border-bottom-size = 0;
          border-size = "1.5pt";
          border-color = "#00000000";
          border-top-color = "\${colors.background}";
          border-bottom-color = "\${colors.background}";

          module-margin = 1;

          separator = "|";
          separator-foreground = "\${colors.disabled}";

          # ;; FONTS
          font-0 = "JetBrainsMono Nerd Font:style=Bold:pixelsize=11;1";
          font-1 = "JetBrainsMono Nerd Font:size=14;4";
          font-2 = "Material Design Icons:style=Bold:size=9;3";
          # ;font-3 = "unifont:fontformat=truetype:size=9;3";
          font-3 = "Font Awesome 5 Free:style=Solid:size=9;2";
          font-4 = "Font Awesome 5 Free:style=Regular:size=9;2";
          font-5 = "Font Awesome 5 Brands:style=Regular:size=9;2";
          font-6 = "Hack Nerd Font Mono:style=Regular:size=12;2";
          font-7 = "Weather Icons:size=9;1";
          font-8 = "Font Awesome 5 Pro:style=Regular:pixelsize=8;4";
          font-9 = "Hack Nerd Font:style=Regular:pixelsize=8:antialias=true;9";
          font-10 = "icomoon-feather:antialias=false:pixelsize=9;1";
          font-11 = "CascadiaCode:style=Medidum:antialias=false:pixelsize=8;2";
          font-13 = "Iosevka Nerd Font:style=Medium:size=13;2";
          font-14 = "Material Icons:style=Bold:size=10;4";


          # modules-left = "xworkspaces polywins";
          # modules-right = "filesystem pulseaudio round-letft xkeyboard memory cpu tempeature wlan eth round-left date round-right empty-space powermenu";

          modules-left = "xworkspaces polywins";
          modules-center = "title";
          modules-right = "filesystem pulseaudio xkeyboard memory cpu tempeature wlan eth date powermenu";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
          enable-ipc = true;
          # ; tray-position = right

          # ; wm-restack = generic
          # wm-restack = "bspwm";
          # ; wm-restack = i3

          override-redirect = true;
        };
        "module/sep" = {
          type = "custom/text";
          content = "|";
          content-background = "\${colors.background}";
        };
        "module/empty-space" = {
          type = "custom/text";
          content = " ";
        };
        "module/title" = {
          type = "internal/xwindow";

          format = "<label>";
          format-foreground = "#99CEF0";

          label = "  %title%";
          label-maxlen = "15 ...";
        };
        "module/now-playing" = {
          type = "custom/script";
          tail = true;
          # ;format-prefix = "";
          format = "<label>";
          exec = "~/.config/polybar/scripts/polybar-now-playing";
          click-right = "kill -USR1 $(pgrep --oldest --parent %pid%)";
        };
        "module/bspwm" = {
          type = "internal/bspwm";

          pin-workspaces = true;
          inline-mode = true;
          enable-click = true;
          enable-scroll = true;
          reverse-scroll = false;

          fuzzy-match = true;

          format = "<label-state>";

          ws-icon-0 = "I;%{F#e3a5f5}";
          ws-icon-1 = "II;%{F#F9DE8F}";
          ws-icon-2 = "III;%{F#ff9b93}";
          #     﫽ﮛ ﮛ ﱨ
          ws-icon-3 = "IV;%{F#95e1d3}﬏";
          ws-icon-4 = "V;%{F#f77102}";
          ws-icon-5 = "VI;%{F#A3BE8C}";
          ws-icon-6 = "VII;%{F#E4BF7B}";
          ws-icon-7 = "VIII;%{F#d49f24}嗢";

          label-separator = " ";
          label-separator-background = "#2a2e36";

          # ;label-focused =  %icon%
          label-focused = "%icon%";
          label-focused-foreground = "\${colors.foreground}";
          label-focused-padding = 1;
          # ;label-focused-background = "#464a52";
          label-focused-background = "#2a2e36";
          label-focused-margin = 0;

          label-top-padding = 1;

          label-occupied = "%icon%";
          # ;label-occupied-foreground = "#646870";
          label-occupied-foreground = "#900000";
          label-occupied-background = "#2a2e36";
          label-occupied-padding = 1;
          label-occupied-margin = 0;

          label-empty = "%icon%";
          label-empty-foreground = "\${colors.foreground}";
          label-empty-padding = 1;
          label-empty-background = "#2a2e36";
          label-empty-margin = 0;

          label-urgent = "%icon%";
          label-urgent-foreground = "#88C0D0";
          label-urgent-background = "#2a2e36";
          label-urgent-padding = 1;
        };
        "module/round-left" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-foreground = "#2a2e36";
        };
        "module/round-right" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-foreground = "#2a2e36";
        };
        "module/temperature" = {
          type = "internal/temperature";
          thermal-zone = 0;
          warn-temperature = 60;

          format = "<ramp> <label>";
          format-underline = "\${colors.primary}";
          format-warn = "<ramp> <label-warn>";
          format-warn-underline = "\${colors.red}";

          label = "%temperature-c%";
          label-warn = "%temperature-c%";
          label-warn-foreground = "\${colors.red}";

          ramp-0 = " ";
          ramp-1 = " ";
          ramp-2 = " ";
          ramp-foreground = "\${colors.foreground-alt}";
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
        "module/battery" = {
          type = "internal/battery";
          battery = "BAT1";
          adapter = "AC0";
          full-at = 98;

          format-charging = "<animation-charging> <label-charging>";
          label-charging = "%percentage%%";
          format-charging-foreground = "\${colors.color4}";
          format-charging-background = "\${colors.background}";

          format-discharging = "<ramp-capacity> <label-discharging>";
          label-discharging = "%percentage%%";
          format-discharging-foreground = "\${colors.foreground}";
          format-discharging-background = "\${colors.background}";

          format-full-prefix = "  ";
          format-full-prefix-foreground = "#A0E8A2";
          format-foreground = "\${colors.color4}";
          format-background = "\${colors.background}";

          label-discharging-foreground = "\${colors.foreground}";
          ramp-capacity-foreground = "#A0E8A2";
          label-charging-foreground = "\${colors.foreground}";

          label-padding = 1;

          ramp-capacity-0 = "  ";
          ramp-capacity-1 = "  ";
          ramp-capacity-2 = "  ";
          ramp-capacity-3 = "  ";
          ramp-capacity-4 = "  ";

          animation-charging-0 = "  ";
          animation-charging-1 = "  ";
          animation-charging-2 = "  ";
          animation-charging-3 = "  ";
          animation-charging-4 = "  ";

          animation-charging-foreground = "#DF8890";
          animation-charging-framerate = 750;

          format-charging-padding = 1;
          format-discharging-padding = 1;
        };
        "module/filesystem" = {
          type = "internal/fs";

          mount-0 = "/";
          interval = 30;
          fixed-values = false;
          format-mounted = "<bar-used> <label-mounted>";
          format-mounted-prefix = " ";

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

          exec = ''pulseaudio-control --icons-volume "," --icon-muted "" --sink-nicknames-from "device.description" --sink-nickname "alsa_output.pci-0000_00_1b.0.analog-stereo:  Speakers" --sink-nickname "alsa_output.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo:  Headphones" listen'';
          click-right = "exec pavucontrol &";
          click-left = "pulseaudio-control togmute";
          click-middle = ''pulseaudio-control --sink-blacklist "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2" next-sink'';
          scroll-up = "pulseaudio-control - -volume-max 200 up";
          scroll-down = "pulseaudio-control --volume-max 200 down";


          label-volume = "%percentage%%";
          label-padding = 2;
          label-muted = "🔇 muted";
          label-foreground = "\${colors.foreground}";
          label-maxlen = 14;
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
          format-prefix = " ";
          format-prefix-foreground = "\${colors.color16}";
          label = "%percentage_used:2%%";
        };
        "module/cpu" = {
          type = "internal/cpu";
          interval = 0.5;
          format-prefix = "CPU ";
          format-prefix-foreground = "\${colors.primary}";
          label = "%percentage:2%%";
        };
        "module/xbacklight" = {
          type = "internal/xbacklight";
          format = "<label>";
          format-prefix = "  ";
          label = "%percentage%";
          format-prefix-foreground = "#61afef";
          label-foreground = "#D8DEE9";
          format-padding = 1;
        };
        "module/backlight" = {
          type = "custom/script";
          interval = 0.2;
          exec = ''echo "$(light | cut -d. -f1)"'';

          # scroll-up = sudo light -A 5
          # scroll-down = sudo light -U 5
          scroll-up = "light -A 5";
          scroll-down = "light -U 5";

          format-prefix = "%{F#FFFF00} ";

          label = "%output%";
          label-foreground = "\${color9}";
          format-padding = 1;
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
          interval = 3.0;
          unknown-as-up = true;
          interface-type = "wireless";
          format-connected-background = "\${colors.background}";
          format-connected-foreground = "\${colors.foreground}";
          format-connected-padding = 1;
          label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
          format-disconnected-background = "\${colors.background}";
          format-disconnected-foreground = "\${colors.foreground}";
          format-disconnected-padding = 1;
          label-disconnected = "";
          ramp-signal-0 = "󰤯";
          ramp-signal-1 = "󰤟";
          ramp-signal-2 = "󰤢";
          ramp-signal-3 = "󰤥";
          ramp-signal-4 = "󰤨";
          ramp-signal-foreground = "\${colors.color16}";
        };
        "module/eth" = {
          "inherit" = "network-base";
          interface-type = "wired";
          interval = 1;
          # label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
          label-connected = "%{F#16ACE0}  %{F#2DFF02}%downspeed% %{F#F04F4C}%upspeed%";
          format-connected-background = "\${colors.background}";
          format-connected-foreground = "\${colors.foreground}";
          format-connected-padding = 1;
          format-connected-prefix-foreground = "#960000";
          # format-connected-underline = "#8E39E5";
          format-disconnected-background = "\${colors.background}";
          format-disconnected-foreground = "\${colors.foreground-alt}";
          label-disconnected = "󰌺";
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
