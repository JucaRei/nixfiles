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
      script = "polybar tokyodark &";

      # script = ''
      #   #!/usr/bin/env bash

      #   killall -q polybar && sleep 2

      #   echo "---" | tee -a /tmp/polybar1.log

      #   polybar tokyodark 2>&1 | tee -a /tmp/polybar1.log &
      #   disown

      #   echo "Bar launched..."
      # '';
      settings = {
        ### config.ini
        "colors" = {
          background = "#11121D";
          background-alt = "#A0A8CD";
          content-background = "#2b2f37";
          blue = "#7199EE";
          cyan = "#38A89D";
          green = "#A0E8A2";
          orange = "#d19a66";
          red = "#e06c75";
          yellow = "#D4B261";
          purple = "#A485DD";
          light-gray = "#565c64";
        };
        "bar/tokyodark" = {
          tray-position = "right";
          monitor = "\${env:MONITOR:}";
          width = "100%";
          height = "20";
          radius = 6;
          fixed-center = true;
          dpi-x = 96;
          dpi-y = 96;
          module-margin = 0;

          # offset-x = "0.2%";
          # offset-y = "2%";
          bottom = false;

          background = "\${colors.background}";
          foreground = "\${colors.foreground}";


          border-top-size = 7;
          border-bottom-size = 7;
          border-top-color = "\${colors.background}";
          border-bottom-color = "\${colors.background}";
          line-size = 3;
          enable-ipc = true;

          padding-left = 1;
          padding-right = 1;

          font-0 = "Hack Nerd Font:style=Bold:pixelsize=13;3";
          font-1 = "JetBrainsMono Nerd Font:size=18;5";
          font-2 = "Material Design Icons:style=Bold:size=13;3";
          font-3 = "unifont:fontformat=truetype:size=13:antialias=true;";

          modules-left = "round-left bspwm round-right";
          # modules-center = "spotify-prev spotify spotify-next";
          modules-center = "cpu";
          # modules-right = "pomo ping pacman filesystem backlight alsa temperature cpu mem wlan bluetooth mic mic_ipc battery tray round-left time round-right powermenu";
          modules-right = "ping filesystem backlight alsa temperature cpu mem wlan bluetooth mic mic_ipc battery tray round-left time round-right powermenu";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };
        "module/bspwm" = {
          type = "internal/bspwm";
          pin-workspace = true;
          inline-mode = true;
          enable-click = true;
          enable-scroll = true;
          reverse-scroll = false;
          format = "<label-state>";

          ws-icon-0 = "1;%{F#ff9b93}";
          ws-icon-1 = "2;%{F#4BB1A7}";
          ws-icon-2 = "3;%{F#4BB1A7}";
          ws-icon-3 = "4;%{F#4BB1A7}";
          ws-icon-4 = "5;%{F#A3BE8C}阮";
          ws-icon-5 = "6;%{F#81A1C1}ﭮ";
          ws-icon-6 = "7;%{F#72C7D1}金";
          ws-icon-7 = "8;%{F#B888E2}";
          ws-icon-8 = "9;%{F#C7C18B}";
          ws-icon-9 = "0;%{F#AE8785}";

          label-separator = "";
          label-separator-background = "\${colors.content-background}";
          label-focused = "%icon% %name%";
          label-focused-foreground = "\${colors.foreground}";
          label-focused-underline = "\${colors.light-gray}";
          label-focused-padding = 1;
          label-focused-background = "\${colors.content-background}";
          label-occupied = "%icon% %name%";
          label-occupied-foreground = "\${colors.light-gray}";
          label-occupied-background = "\${colors.content-background}";
          label-occupied-padding = 1;
          label-empty = "";
          label-empty-foreground = "\${colors.foreground}";
          label-empty-padding = 1;
          label-empty-background = "\${colors.content-background}";
          label-urgent = "%icon% %name%";
          label-urgent-foreground = "\${colors.cyan}";
          label-urgent-background = "\${colors.content-background}";
          label-urgent-padding = 1;
        };
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          format-volume = "<ramp-volume> <label-volume>";
          format-muted = "<label-muted>";
          label-volume = "%percentage%%";
          label-muted = " ";
          label-volume-foreground = "\${colors.foreground}";
          format-muted-foreground = "\${colors.foreground}";
          format-muted-padding = 1;
          format-muted-background = "\${colors.content-background}";
          ramp-volume-0 = "";
          ramp-volume-1 = "";
          ramp-volume-2 = "";
          ramp-volume-foreground = "\${colors.cyan}";
          ramp-headphones-0 = "";
          ramp-headphones-foreground = "\${colors.cyan}";
          format-padding = 1;
        };
        "module/time" = {
          type = "internal/date";
          interval = 60;
          format = "<label>";
          format-background = "\${colors.content-background}";
          date = "%{F#888e96}󰥔 %H:%M%{F-}";
          time-alt = "%{F#7199EE}󰃭 %a, %b %d%{F-}";
          label = "%date%%time%";
          format-padding = 1;
        };
        "module/bluetooth" = {
          type = "custom/script";
          exec = "/home/juca/.config/polybar/scripts/bluetooth_battery.sh";
          format = "<label>";
          interval = 20;
          format-prefix = " ";
          label = "%output%% ";
          format-prefix-foreground = "\${colors.blue}";
          format-padding = 0;
        };
        "module/mem" = {
          type = "custom/script";
          exec = ''printf "%.1f\n" $(echo $(free -m | sed -n 's/^Mem:\s\+[0-9]\+\s\+\([0-9]\+\)\s.\+/\1/p')/1024 | bc -l)'';
          format = "<label>";
          format-prefix = " ";
          label = "%output%GB";
          format-prefix-foreground = "\${colors.orange}";
          format-padding = 1;
        };
        "module/pacman" = {
          type = "custom/script";
          exec = "checkupdates 2>&- | wc -l | sed -E 's/^0$//g'";
          interval = 600;
          label = "%output%";
          format-foreground = "\${colors.foreground}";
          format-background = "\${colors.background}";
          format-prefix = " ";
          format-prefix-foreground = "\${colors.red}";
          format-padding = 1;
        };
        "module/cpu" = {
          type = "internal/cpu";
          interval = 5;
          format = "<label>";
          format-prefix = " ";
          label = "%percentage:02%%";
          format-prefix-foreground = "\${colors.purple}";
          format-padding = 0;
        };
        "module/powermenu" = {
          type = "custom/text";
          content = "";
          content-padding = 1;
          click-left = "bspc quit &";
          content-foreground = "\${colors.red}";
        };
        "module/wlan" = {
          type = "internal/network";
          interface = "enp1s0";
          interval = "10.0";
          format-connected = "<label-connected>";
          label-connected = "󰤪 ";
          label-connected-foreground = "\${colors.green}";
          format-padding = 1;
        };
        "module/ping" = {
          type = "custom/script";
          interval = 10;
          exec = "ping -W 5 -c 1 8.8.8.8 | tail -1 | cut -d ' ' -f4 | cut -d '/' -f2 | cut -d '.' -f1";
          format = "<label>";
          format-prefix = "龍 ";
          format-prefix-foreground = "\${colors.green}";
          label = "%output%ms";
          format-padding = 1;
        };
        "module/uptime" = {
          type = "custom/script";
          interval = 10;
          exec = "$(uptime --pretty | sed -e 's/up //g' -e 's/ days/d/g' -e 's/ day/d/g' -e 's/ hours/h/g' -e 's/ hour/h/g' -e 's/ minutes/m/g' -e 's/, / /g')";
          format = "<label>";
          format-prefix = "";
          format-prefix-foreground = "\${colors.purple}";
          label = "%output%";
          format-padding = 1;
        };
        "module/battery" = {
          type = "internal/battery";
          battery = "BAT1";
          adapter = "ADP1";
          full-at = 96;
          format-charging = "<ramp-capacity> <label-charging>";
          label-charging = "%percentage:2%%";
          format-charging-padding = 1;
          format-charging-foreground = "\${colors.foreground}";
          format-discharging = "<ramp-capacity> <label-discharging>";
          label-discharging = "%percentage%%";
          format-discharging-foreground = "\${colors.foreground}";
          format-full-prefix = "  ";
          label-full = "";
          format-full-prefix-foreground = "\${colors.green}";
          format-foreground = "\${colors.foreground}";
          format-background = "\${colors.content-background}";
          label-discharging-foreground = "\${colors.foreground}";
          ramp-capacity-foreground = "\${colors.green}";
          label-charging-foreground = "\${colors.foreground}";
          ramp-capacity-0 = " ";
          ramp-capacity-1 = " ";
          ramp-capacity-2 = " ";
          ramp-capacity-3 = " ";
          ramp-capacity-4 = " ";
          animation-charging-0 = " ";
          animation-charging-1 = " ";
          animation-charging-2 = " ";
          animation-charging-3 = " ";
          animation-charging-4 = " ";
          animation-charging-foreground = "\${colors.red}";
          animation-charging-framerate = 910;
          format-discharging-padding = 1;
        };
        "module/spotify" = {
          type = "custom/script";
          interval = 10;
          format-prefix = "♪ ";
          format = "<label>";
          exec = "/home/juca/.config/polybar/scripts/spotify.sh";
          click-left = "/home/juca/.config/polybar/scripts/spotify.sh  --toggle";
        };
        "module/mic_ipc" = {
          type = "custom/ipc";
          hook-0 = "/home/juca/.config/polybar/scripts/mic.sh";
          click-left = "amixer set Capture toggle > /dev/null && polybar-msg hook mic_ipc 1";
          format-prefix = " ";
          format-prefix-foreground = "\${colors.red}";
        };
        "module/mic" = {
          type = "custom/script";
          interval = 10;
          exec = "polybar-msg action "; #"mic_ipc.hook.0" > /dev/null
        };
        "module/tray" = {
          type = "internal/tray";
          format-padding = 1;
        };
        "module/spotify-prev" = {
          type = "custom/script";
          interval = 10;
          exec = "if pgrep -x spotify > /dev/null 2>&1"; #then echo '   '; else echo ''; fi";
          format = "<label>";
          click-left = "/home/juca/.config/polybar/scripts/spotify.sh  --prev";
        };
        "module/spotify-next" = {
          type = "custom/script";
          interval = 10;
          exec = "if pgrep -x spotify > /dev/null 2>&1"; #; then echo "   "; else echo ""; fi
          format = "<label>";
          click-left = "/home/juca/.config/polybar/scripts/spotify.sh  --next";
        };
        "module/pomo" = {
          type = "custom/script";
          interval = 1;
          format-prefix = " ";
          format-prefix-foreground = "\${colors.red}";
          exec = "pomo status | sed -E 's/[?].*//g' | sed -E 's/ -$//g'";
        };
        "module/backlight" = {
          type = "internal/backlight";
          card = "intel_backlight";
          format = "<label>";
          format-prefix = " ";
          label = "%percentage:2%%";
          format-prefix-foreground = "\${colors.yellow}";
          format-padding = 1;
        };
      };
    };
  };
}
