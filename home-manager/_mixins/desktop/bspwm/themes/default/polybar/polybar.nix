{pkgs, ...}: {
  imports = [./scripts.nix];
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybarFull;
      script = "";
      settings = {
        "colors" = {
          foreground = "#c8ccd4";
          background = "#1e222a";
          disabled = "#707880";

          color0 = "#282c34";
          color1 = "#e06c75";
          color2 = "#98c379";
          color3 = "#e5c07b";
          color4 = "#61afef";
          color5 = "#c678dd";
          color6 = "#56b6c2";
          color7 = "#abb2bf";
          color8 = "#545862";
          color9 = "#e06c75";
          color10 = "#98c379";
          color11 = "#e5c07b";
          color12 = "#61afef";
          color13 = "#c678dd";
          color14 = "#56b6c2";
          color15 = "#c8ccd4";
          dark-light = "#272A2B";
          active-light = "#313435";
        };
        "bar/main" = {
          tray-position = "right";
          # monitor = "eDP1";
          monitor = "eDP-1";
          # monitor = "Virtual-1";
          width = "100%";
          height = 18;
          padding-left = 1;
          padding-right = 0;

          background = "\${colors.background}";
          foreground = "\${colors.foreground}";
          bottom = false;
          border-top-size = 5;
          border-bottom-size = 5;
          border-top-color = "\${colors.background}";
          border-bottom-color = "\${colors.background}";

          line-size = 1;
          wm-restack = "bspwm";

          modules-left = "menu sep round-left bspwm round-right empty-space round-left polywins round-right";
          modules-center = "nowplaying title";
          # modules-right = "disks temperature round-left cpu round-right mem xbacklight alsa pulseaudio bluetooth wlan eth updates round-left time round-right powermenu";
          modules-right = "disks round-left cpu round-right mem pulseaudio wlan eth round-left time round-right battery powermenu";
          font-0 = "JetBrainsMono Nerd Font:style=Bold:pixelsize=9;3";
          font-1 = "JetBrainsMono Nerd Font:size=14;4";
          font-2 = "Material Design Icons:style=Bold:size=9;3";
          font-3 = "unifont:fontformat=truetype:size=9;3";
        };
        # "bar/tray" = {
        #   monitor-strict = false;
        #   width = 30;
        #   height = 30;
        #   radius = 8;
        #   offset-x = "98%";
        #   offset-y = "35%";
        #   override-redirect = true;
        #   fixed-center = true;
        #   background = "\${colors.background}";
        #   line-size = 0;
        #   line-color = "#f00";
        #   padding-left = 0;
        #   padding-right = 1;
        #   module-margin-left = 0;
        #   module-margin-right = 0;
        # };
        "module/sep" = {
          type = "custom/text";
          content = "  ";
          content-background = "\${colors.background}";
          content-foreground = "\${colors.background}";
        };
        "module/disks" = {
          type = "custom/script";
          interval = 300;
          format-prefix = " 󰋊";
          format = "<label>";
          label-padding = 1;
          exec = "~/.local/polybar/scripts/disks";
        };
        "module/bluetooth" = {
          type = "custom/script";
          exec = "~/.local/polybar/scripts/bluetooth";
          format = "<label>";
          format-font = 0;
          interval = 1;

          click-right = "~/.local/polybar/scripts/toggle_bluetooth.sh &";
          click-left = "blueberry &";
        };
        # "module/bluetooth" = {
        #   type = "custom/script";
        #   exec = ''"bluetoothctl paired-devices | cut -d' ' -f2 | xargs -i -n1 bash -c "bluetoothctl info {} | grep -q 'Connected: yes' && bluetoothctl info {} | grep -o 'Alias: .*'" | awk -vORS=', ' '{sub($1 OFS,"")}1' | sed -e 's/, $//'" '';
        #   exec-if = ''"$(bluetoothctl show | grep 'Powered: yes' | wc -l) -gt 0 ] && [ $(bluetoothctl show | grep 'Connected: yes' | wc -l) -gt 0 ]" '';
        #   interval = 1;
        #   # ;click-right = "blueman-manager &";
        #   click-right = "blueberry &";
        #   click-middle = "~/.local/polybar/scripts/toggle_bluetooth.sh &";
        #   label = "";
        #   # ;format-prefix = " ";
        #   format-underline = "#2193ff";
        # };
        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = true;
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
        # "module/now-playing" = {
        #   type = "custom/script";
        #   tail = true;
        #   # ;format-prefix = "";
        #   format = "<label>";
        #   exec = "~/.local/polybar/scripts/polybar-now-playing";
        #   click-right = "kill -USR1 $(pgrep --oldest --parent %pid%)";
        # };
        "module/nowplaying" = {
          type = "custom/script";
          tail = true;
          interval = 1;
          format = "󰫔 <label> "; # 󰷞 󰽴 󰽱 󱂵
          exec = ''playerctl metadata --format "{{ artist }} - {{ title }}"'';
          label-maxlen = "20..";
        };
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          use-ui-max = false;
          # #6c7086
          # #f9e2af

          format-volume = "<label-volume>";
          format-volume-prefix = "%{T4}󰕾%{T-}";
          # format-volume-prefix-foreground = "\${colors.yellow}";
          format-volume-prefix-foreground = "#f9e2af";
          label-volume = "%{T1}%percentage%%%{T-}";
          label-volume-padding = 1;

          format-muted = "<label-muted>";
          format-muted-prefix = "󰕿";
          # format-muted-prefix-foreground = "\${colors.overlay0}";
          format-muted-prefix-foreground = "#6c7086";
          label-muted = "%{T1}%percentage%%%{T-}";
          label-muted-foreground = "#6c7086";
          label-muted-padding = 1;

          click-right = "pavucontrol&";
        };
        "module/polywins" = {
          type = "custom/script";
          # exec = "~/.local/polybar/scripts/polywins 2>/dev/null";
          exec = "~/.local/polybar/scripts/polywins.sh 2>/dev/null";
          format = "<label>";
          format-background = "#2a2e36";
          label = "%output%";
          label-padding = 0;
          tail = true;
        };
        "module/empty-space" = {
          type = "custom/text";
          content = "  ";
        };
        "module/round-left" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          # content = "%{T3}%{T-}";
          content-foreground = "#2a2e36";
        };
        "module/round-right" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          # content = "%{T3}%{T-}";
          content-foreground = "#2a2e36";
        };
        "module/roundd-left" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-foreground = "#a3be8c";
        };
        "module/roundd-right" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-foreground = "#a3be8c";
        };
        "module/temperature" = {
          type = "internal/temperature";

          interval = 1;

          thermal-zone = 0;
          warn-temperature = 80;

          format = "<ramp> <label>";
          format-warn = "<ramp> <label-warn>";
          format-padding = 1;
          label = "%temperature%";
          label-warn = "%temperature%";
          ramp-0 = "󰜗";
          ramp-font = 3;
          ramp-foreground = "#a4ebf3";
          #
        };
        "module/menu" = {
          type = "custom/text";

          content = "";
          content-font = 12;
          content-background = "\${colors.background}";
          content-foreground = "\${colors.color4}";
          content-padding = 0;

          click-left = "~/.config/bspwm/scripts/rofi_launcher";
          click-right = "~/.config/bspwm/scripts/rofi_runner";
        };
        "module/bspwm" = {
          type = "internal/bspwm";

          pin-workspaces = true;
          inline-mode = true;
          enable-click = true;
          enable-scroll = true;
          reverse-scroll = false;

          format = "<label-state>";

          ws-icon-0 = "1;%{F#a4ebf3}";
          ws-icon-1 = "2;%{F#ff9b93}";
          ws-icon-2 = "3;%{F#95e1d3}󱂵";
          ws-icon-3 = "4;%{F#81A1C1}";
          ws-icon-4 = "5;%{F#A3BE8C}"; #    󰇩 󰌔  
          ws-icon-5 = "6;%{F#EB721E}";
          ws-icon-6 = "7;%{F#6cb5ed}";
          ws-icon-7 = "8;%{F#545862}";
          # 󰂱 󰂳 󰂰 󰂯 󰑍 󰕼 󰚀 󰡨

          label-separator = " ";
          label-separator-background = "#2a2e36";

          label-focused = "%icon%";
          label-focused-foreground = "\${colors.foreground}";
          label-focused-padding = 1;
          label-focused-background = "#464a52";
          label-focused-margin = 0;

          label-occupied = " %icon%";
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
        "module/alsa" = {
          type = "internal/alsa";
          format-volume = "<label-volume> <bar-volume>";
          label-volume = " ";
          label-volume-foreground = "\${colors.foreground}";
          format-muted-foreground = "\${colors.foreground}";
          label-muted = "󰚙";

          format-muted-padding = 1;

          bar-volume-width = 10;
          bar-volume-foreground-0 = "#61afef";
          bar-volume-foreground-1 = "#61afef";
          bar-volume-foreground-2 = "#61afef";
          bar-volume-foreground-3 = "#61afef";
          bar-volume-foreground-4 = "#61afef";
          bar-volume-foreground-5 = "#61afef";
          bar-volume-foreground-6 = "#61afef";
          bar-volume-gradient = false;
          bar-volume-indicator = "";
          bar-volume-indicator-foreground = "#61afef";
          bar-volume-indicator-font = 2;
          bar-volume-fill = "━";
          bar-volume-fill-foreground = "#61afef";
          bar-volume-fill-font = 2;
          bar-volume-empty = "━";
          bar-volume-empty-font = 2;
          bar-volume-empty-foreground = "#565c64";
          format-volume-padding = 2;
        };
        "module/time" = {
          type = "internal/date";
          interval = 60;

          format = "<label>";
          format-background = "#2a2e36";
          format-foreground = "#82868e";

          date = "󰥔 %H:%M%{F-}";
          time-alt = "󰃭 %a, %b %d%{F-}";

          label = "%date%%time%";
        };
        "module/mem" = {
          type = "custom/script";
          # type = "internal/memory";
          # exec = "~/.local/polybar/scripts/mem.sh";
          exec = ''
            free -m | sed -n 's/^Mem:\s\+[0-9]\+\s\+\([0-9]\+\)\s.\+/\1/p'
          '';
          format = "<label>";
          interval = 2;
          format-prefix = " ";
          label = "%output%MB";
          label-padding = 1;
          format-prefix-foreground = "#F4E8C1";
        };
        "module/updates" = {
          type = "custom/script";
          # exec = "doas xbps-install -S > /dev/null 2>&1; xbps-updates";
          exec = "~/.local/polybar/scripts/nix-updates 2>/dev/null";
          format = "<label>";
          interval = 4600;
          label = "  %output%";
          label-padding = 2;
          label-foreground = "#BF616A";
        };
        "module/powermenu" = {
          type = "custom/text";
          content = " ";
          content-padding = 2;
          # click-left = "doas zzz &";
          click-left = "/home/juca/.config/rofi/bin/powermenu.sh";
          content-foreground = "#f25287";
        };
        "network-base" = {
          type = "internal/network";
          interval = 5;
          exec = "";
          # format-connected = "<label-connected>";
          format-connected = "%{A1:$HOME/.config/rofi/bin/rofi-wifi.sh:}<ramp-signal> <label-connected>%{A}";
          format-disconnected = "<label-disconnected>";
          label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
          # click-left = "~/.config/rofi/bin/rofi-wifi-menu.sh";
          # click-left = "~/.config/rofi/bin/rofi-wifi.sh";
        };
        "module/eth" = {
          "inherit" = "network-base";
          interface-type = "wired";
          interval = 1;
          # label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
          label-connected = "%{F#16ACE0} %{F#713ABE}%local_ip% %{F#2DFF02}%downspeed% %{F#F04F4C}%upspeed%";
          format-connected-background = "\${colors.background}";
          format-connected-foreground = "\${colors.foreground}";
          format-connected-padding = 1;
          format-connected-prefix-foreground = "#960000";
          # format-connected-underline = "#8E39E5";
          format-disconnected-background = "\${colors.background}";
          format-disconnected-foreground = "\${colors.foreground-alt}";
          label-disconnected = "󰌺";
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
          format-connected = "";
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
        # "module/wlan" = {
        #   type = "internal/network";
        #   interface = "wlp2s0";
        #   interval = 3.0;
        #   format-connected = "<label-connected>";
        #   label-connected = "󰤪  ";
        #   label-connected-foreground = "#A3BE8C";
        # };
        "module/battery" = {
          type = "internal/battery";
          battery = "BAT0";
          adapter = "ADP1";
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
        "module/volume" = {
          type = "custom/script";
          exec = "amixer get Master | awk '$0~/%/{print $4}' | tr -d '[]'";
          format = "<label>";
          internal = 5.0;
          label = " %output%";
          label-foreground = "#BF616A";
          label-padding = 1;
        };
        "module/xbacklight" = {
          type = "internal/xbacklight";
          format = "<label>";
          format-prefix = " ";
          label = "%p@ercentage%";
          format-prefix-foreground = "#61afef";
          label-foreground = "#D8DEE9";
          format-padding = 1;
        };
        "module/brightness" = {
          type = "internal/backlight";
          ## ; Use the following command to list available cards:
          ## ; $ ls -1 /sys/class/backlight/
          # card = "intel_backlight";

          # ; Available tags:
          # ;   <label> (default)
          # ;   <ramp>
          # ;   <bar>
          format = "<ramp> <bar>";

          # ; Available tokens:
          # ;   %percentage% (default)
          label = "%percentage%%";

          # ; Only applies if <ramp> is used
          ramp-0 = "󰃜";
          ramp-1 = "󰃛";
          ramp-2 = "󰃝";
          ramp-3 = "󰃟";
          ramp-4 = "󰃠";
          ramp-5 = "󰃚";

          # ; Only applies if <bar> is used
          bar-width = 10;
          bar-gradient = false;

          bar-indicator = "\${bar.indicator}";
          bar-indicator-foreground = "\${color.foreground}";

          bar-fill = "\${bar.fill}";
          bar-foreground-0 = "\${color.foreground}";
          bar-foreground-1 = "\${color.foreground}";
          bar-foreground-2 = "\${color.foreground}";

          bar-empty = "\${bar.empty}";
          bar-empty-foreground = "\${color.foreground}";

          # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
        };
        "module/cpu" = {
          type = "internal/cpu";
          interval = 2.0;

          format-prefix = " ";
          format = "<label>";

          # label = "CPU %percentage%%";
          label = "%percentage%%";
          format-background = "#2a2e36";
          format-foreground = "#989cff";
        };
        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:30:...";
        };
        "module/title" = {
          type = "internal/xwindow";

          format = "<label>";
          format-foreground = "#99CEF0";

          label = "  %title%";
          label-maxlen = "18 ...";
        };
      };
    };
  };
}
