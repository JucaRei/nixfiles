{ pkgs, ... }: {
  imports = [
    ../default/polybar/scripts.nix
  ];
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybar;
      script = "";
      settings = {
        # Config.ini
        "global/wm" = {
          margin-bottom = 0;
          margin-top = 0;
        };
        "bar/bar" = {
          monitor-strict = false;
          override-redirect = false;
          bottom = false;
          fixed-center = true;
          width = "98%";
          height = 26;
          offset-x = "1%";
          offset-y = "1%";
          background = "\${color.bg}";
          foreground = "\${color.fg}";
          radius = 4.0;
          line-size = 2;
          line-color = "\${color.blue}";
          border-size = "1px";
          border-color = "\${color.bg}";
          padding = 1;
          module-margin-left = 0;
          module-margin-right = 0;

          # Text
          font-0 = "Maple Mono:size=11;2";
          # Icons
          font-1 = "Font Awesome 6 Free Solid:size=11;3";
          font-2 = "Material Design Icons Desktop:size=12;3";
          font-3 = "Material Design Icons Desktop:size=15;3";
          # ; Glyphs
          font-4 = "MesloLGS NF:style=Regular:size=15;4";
          font-6 = "Sarasa Mono CL Nerd Font:size=2;4";
          # ; Chinese
          font-5 = "Maple Mono SC NF:size=11;2";
          # dpi = 96;

          modules-left = "launcher blok bspwm LD polywins RRD";
          modules-center = "";
          modules-right = "sep network blok2 audio blok memory_bar blok bi cpu_bar bd blok date blok powermenu";

          spacing = 0;
          separator = "";
          dim-value = 1.0;

          # locale = "pt_BR.UTF-8";

          tray-position = "none";
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

          pseudo-transparency = true;
        };

        ### System.ini
        # ; When some modules in the polybar doesn't show up.
        # ; Look for battery/adapter: "ls -l /sys/class/power_supply"
        # ; Look for backlight: "ls -l /sys/class/backlight"
        # ; Look for network: "ls -l /sys/class/net"
        "system" = {
          adapter = "ACAD";
          battery = "BAT0";
          # graphics_card = "amdgpu_bl0";
          # network_interface = "wlan0";
        };

        ### Decor.ini
        "module/spacing" = {
          type = "custom/text";
          content = " ";
          content-background = "\${color.background}";
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
        "module/sep" = {
          type = "custom/text";
          # ;content = "";
          content = " ";

          content-font = 5;
          content-background = "\${color.background}";
          content-foreground = "\${color.altblack}";
          content-padding = 2;

          # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
        };
        "module/LD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-background = "\${color.background}";
          content-foreground = "\${color.blue}";
        };
        "module/RD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-background = "\${color.black}";
          content-foreground = "\${color.blue}";
        };
        "module/RLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.red}";
        };
        "module/BRLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.red}";
        };
        "module/RRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.red}";
        };
        "module/BRRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.red}";
        };
        "module/WLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.white}";
        };
        "module/WRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.white}";
        };
        "module/CLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.aqua}";
        };
        "module/CRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.aqua}";
        };
        "module/MLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.purple}";
        };
        "module/MRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.purple}";
        };
        "module/BMLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.purple}";
        };
        "module/BMRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.purple}";
        };
        "module/YLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.yellow}";
        };
        "module/YRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.yellow}";
        };
        "module/OLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.orange}";
        };
        "module/BOLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.orange}";
        };
        "module/ORD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.orange}";
        };
        "module/BORD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.orange}";
        };
        "module/PLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.pink}";
        };
        "module/BPLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.pink}";
        };
        "module/PRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.pink}";
        };
        "module/BPRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.pink}";
        };
        "module/GLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.green}";
        };
        "module/BGLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.green}";
        };
        "module/GRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.green}";
        };
        "module/BGRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.green}";
        };
        "module/BLD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.black}";
        };
        "module/BRD" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.background}";
          content-foreground = "\${color.black}";
        };
        "module/YPL" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.black}";
        };
        "module/CPL" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.black}";
        };
        "module/GPL" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.black}";
          content-foreground = "\${color.black}";
        };
        "module/RPL" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.red}";
          content-foreground = "\${color.red}";
        };
        "module/MPL" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.green}";
          content-foreground = "\${color.red}";
        };
        "module/GMPL" = {
          type = "custom/text";
          content = "%{T3}%{T-}";
          content-font = 3;
          content-background = "\${color.red}";
          content-foreground = "\${color.green}";
        };

        ### Modules.ini
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
        "module/gpu" = {
          type = "custom/script";
          exec = "~/.config/polybar/scripts/gpu";
          format = "<label>";
          format-prefix = "󰌪 ";
          format-prefix-background = "\${color.mb}";
          format-prefix-foreground = "\${color.yellow}";
          label = "%output%";
          format-background = "\${color.mb}";
        };
        "module/battery" = {
          type = "internal/battery";

          full-at = 100;

          battery = "\${system.battery}";
          adapter = "\${system.adapter}";

          poll-interval = 2;
          time-format = "%H:%M";

          format-charging = "<animation-charging><label-charging>";
          format-charging-prefix = "";

          format-discharging = "<ramp-capacity><label-discharging>";

          format-full = "<label-full>";
          format-full-prefix = " ";
          format-full-prefix-font = 2;
          format-full-prefix-foreground = "\${color.fg}";
          format-full-prefix-background = "\${color.mb}";

          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";
          label-full = "%percentage%%";

          label-charging-background = "\${color.mb}";
          label-discharging-background = "\${color.mb}";
          label-full-background = "\${color.mb}";

          label-charging-foreground = "\${color.fg}";
          label-discharging-foreground = "\${color.fg}";
          label-full-foreground = "\${color.fg}";

          ramp-capacity-0 = " ";
          ramp-capacity-1 = " ";
          ramp-capacity-2 = " ";
          ramp-capacity-3 = " ";
          ramp-capacity-4 = " ";
          ramp-capacity-font = 2;
          ramp-capacity-foreground = "\${color.green}";
          ramp-capacity-background = "\${color.mb}";

          animation-charging-0 = " ";
          animation-charging-1 = " ";
          animation-charging-2 = " ";
          animation-charging-3 = " ";
          animation-charging-4 = " ";
          animation-charging-font = 2;
          animation-charging-foreground = "\${color.orange}";
          animation-charging-background = "\${color.mb}";
          animation-charging-framerate = 750;
        };
        "module/date" = {
          type = "internal/date";

          interval = 1.0;

          time = "%H:%M";
          format-background = "\${color.mb}";
          format-foreground = "\${color.fg}";
          date-alt = " %A, %d %B %Y";

          format = "<label>";
          format-prefix = "";
          format-prefix-background = "\${color.mb}";
          format-prefix-foreground = "\${color.purple}";

          label = "%date% %time%";
        };
        "module/filesystem" = {
          type = "internal/fs";

          mount-0 = "/";
          interval = 60;
          fixed-values = true;

          format-mounted = "<label-mounted>";
          format-mounted-prefix = " ";
          format-mounted-prefix-background = "\${color.mb}";
          format-mounted-prefix-foreground = "\${color.yellow}";

          format-unmounted = "<label-unmounted>";
          format-unmounted-prefix = " ";

          label-mounted = "%used%";
          label-mounted-background = "\${color.mb}";

          label-unmounted = "%mountpoint%: not mounted";
        };
        "module/network" = {
          type = "internal/network";
          interface = "wlan0";

          interval = 3.0;
          accumulate-stats = true;
          unknown-as-up = true;

          format-connected = "<label-connected>";
          format-connected-prefix = "直";
          format-connected-background = "\${color.mb}";
          format-connected-foreground = "\${color.green}";

          speed-unit = "";
          #label-connected = " %netspeed%"
          label-connected = " %{A1:def-nmdmenu &:}%essid%%{A}";
          label-connected-background = "\${color.mb}";
          label-connected-foreground = "\${color.fg}";

          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "睊";

          format-disconnected-background = "\${color.mb}";
          format-disconnected-foreground = "\${color.red}";

          label-disconnected = " not connected";
          label-disconnected-foreground = "\${color.red}";
        };
        "module/audio" = {
          type = "internal/alsa";
          use-ui-max = true;
          interval = 2;

          format-volume = "<ramp-volume><label-volume>";
          format-volume-prefix = "";
          format-volume-background = "\${color.mb}";
          format-volume-foreground = "\${color.purple}";

          label-volume = " %percentage% ";
          label-volume-background = "\${color.mb}";
          label-volume-foreground = "\${color.fg}";

          format-muted = "<label-muted>";
          format-muted-prefix = "";
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
        "module/bspwm" = {
          type = "internal/bspwm";

          enable-click = true;
          enable-scroll = true;
          reverse-scroll = true;
          pin-workspaces = true;
          occupied-scroll = false;


          format = "<label-state>";

          label-focused = "󰮯";
          label-focused-background = "\${color.mb}";
          label-focused-padding = 1;
          label-focused-foreground = "\${color.yellow}";

          label-occupied = "󰊠";
          label-occupied-padding = 1;
          label-occupied-background = "\${color.mb}";
          label-occupied-foreground = "\${color.blue}";

          label-urgent = "%icon%";
          label-urgent-padding = 0;

          label-empty = "󰑊";
          label-empty-foreground = "\${color.purple}";
          label-empty-padding = 1;
          label-empty-background = "\${color.mb}";
        };
        "module/launcher" = {
          type = "custom/text";

          content = "";
          #content = 󰣇
          content-foreground = "\${color.blue-arch}";
          content-font = 4;
          #bylo 4

          click-left = "rofi -no-lazy-grab -show drun";
        };
        "module/blok2" = {
          type = "custom/text";
          content = " |";
          content-foreground = "\${color.fg}";
          content-background = "\${color.bg}";
        };
        "module/blok" = {
          type = "custom/text";
          content = " | ";
          content-foreground = "\${color.fg}";
          content-background = "\${color.bg}";
        };
        "module/dots" = {
          type = "custom/text";
          content = " 󰇙 ";
          content-foreground = "\${color.purple}";
        };
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
        "module/memory_bar" = {
          type = "internal/memory";

          interval = 3;

          format = "<label>";
          format-prefix = " ";
          format-prefix-background = "\${color.mb}";
          format-prefix-foreground = "\${color.aqua}";

          label = "%used%";
          label-background = "\${color.mb}";
        };
        "module/mpd_control" = {
          type = "internal/mpd";
          host = "127.0.0.1";
          port = 6600;
          interval = 2;
          format-online = "<icon-prev><toggle><icon-next>";
          format-offline = "<label-offline>";
          label-offline = "󰝛 No music";
          icon-play = " %{T3} ";
          icon-pause = " %{T3} ";
          icon-stop = " %{T3} ";
          icon-prev = "%{T3} ";
          icon-next = " %{T3}";

          format-offline-background = "\${color.mb}";
          format-offline-foreground = "\${color.grey}";
          icon-play-background = "\${color.mb}";
          icon-pause-background = "\${color.mb}";
          icon-stop-background = "\${color.mb}";
          icon-prev-background = "\${color.mb}";
          icon-next-background = "\${color.mb}";
          icon-repeat-background = "\${color.mb}";
          icon-play-foreground = "\${color.green}";
          icon-pause-foreground = "\${color.green}";
          icon-stop-foreground = "\${color.green}";
          icon-prev-foreground = "\${color.sky}";
          icon-next-foreground = "\${color.sky}";
          toggle-on-foreground = "\${color.green}";
          toggle-off-foreground = "\${color.red}";
        };
        "module/mpd" = {
          type = "internal/mpd";
          host = "127.0.0.1";
          port = 6600;
          interval = 2;
          format-online = ''<icon-repeat> %{F#9ece6a}[%{F-} %{A1:bspc rule -a org.wezfurlong.wezterm -o state=floating follow=on center=true && wezterm start -- " ncmpcpp ":}<label-song>%{A} %{F#9ece6a}]%{F-}'';
          format-offline = "";
          label-song = "%title%";
          label-song-maxlen = 21;
          icon-repeat = "";

          icon-repeat-background = "\${color.bg}";
          toggle-on-foreground = "\${color.green}";
          toggle-off-foreground = "\${color.red}";
        };
        "module/powermenu" = {
          type = "custom/text";

          content = "⏻";
          content-background = "\${color.mb}";
          content-foreground = "\${color.red}";

          click-left = "~/.config/polybar/scripts/powermenu";
          click-right = "~/.config/polybar/scripts/powermenu";
        };
        "module/weather" = {
          type = "custom/script";
          exec = "~/.config/polybar/scripts/weather-plugin.sh";
          tail = false;
          interval = 960;
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
        # ; https://github.com/gh0stzk/dotfiles By z0mbi3

        "color" = {

          # ;; Dark Add FC at the beginning #FC1E1F29 for 99 transparency
          # ;bg = #1A1B26
          # ;fg = #F1F1F1
          # ;mb = #282A36

          # ;bg = #1e1e2e
          # ;fg = #cdd6f4
          # ;mb = #313244

          bg = "#2D353B";
          fg = "#d3c6aa";
          mb = "#2D353B";
          #mb = "#343F44";

          trans = "#00000000";
          white = "#FFFFFF";
          black = "#000000";

          # ;; Colors

          # ;red = #f7768e
          # ;pink = #FF0677
          # ;purple = #583794
          # ;blue = #7aa2f7
          blue-arch = "#0A9CF5";
          # ;cyan = #4DD0E1
          # ;teal = #00B19F
          # ;green = #9ece6a
          # ;lime = #B9C244
          # ;yellow = #e0af68
          # ;amber = #FBC02D
          # ;orange = #E57C46
          # ;brown = #AC8476
          # ;grey = #8C8C8C
          # ;indigo = #6C77BB
          # ;blue-gray = #6D8895


          # ;rosewater= #f5e0dc
          # ;flamingo = #f2cdcd
          # ;pink = #f5c2e7
          # ;mauve = #cba6f7
          # ;red = #f38ba8
          # ;maroon = #eba0ac
          # ;orange = #fab387
          # ;yellow = #f9e2af
          # ;green = #a6e3a1
          # ;teal = #94e2d5
          # ;sky = #89dceb
          # ;sapphire = #74c7ec
          # ;blue = #89b4fa
          # ;lavender = #b4befe

          red = "#E67E80";
          orange = "#E69875";
          yellow = "#DBBC7F";
          green = "#A7C080";
          aqua = "#83C092";
          blue = "#7FBBB3";
          purple = "#D699B6";
        };
      };
    };
  };
  home = {
    file = {
      ".config/polybar/scripts/powermenu" = {
        executable = true;
        text = ''
          #!/bin/sh

          #Script from ericmurphy's video

          #rofi -show p -modi p:rofi-power-menu \
          #  -theme Paper \
          #  -font "JetBrains Mono NF 16" \
          #  -width 20 \
          #  -lines 6
          chosen=$(printf "  Power Off\n  Restart\n  Lock" | rofi -dmenu -i)

          case "$chosen" in
              "  Power Off") poweroff ;;
              "Sleep") sleep ;;
              "  Restart") reboot ;;
              "  Lock") slock ;;
              *) exit 1 ;;
          esac

        '';
      };
      "./config/polybar/scripts/weather-plugin.sh" = {
        executable = true;
        text = ''
          #!/bin/bash

          # SETTINGS vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

          # API settings ________________________________________________________________

          APIKEY=`cat $HOME/.owm-key`
          # if you leave these empty location will be picked based on your ip-adres
          CITY_NAME='Warsaw'
          COUNTRY_CODE='PL'
          # Desired output language
          LANG="en"
          # UNITS can be "metric", "imperial" or "kelvin". Set KNOTS to "yes" if you
          # want the wind in knots:

          #          | temperature | wind
          # -----------------------------------
          # metric   | Celsius     | km/h
          # imperial | Fahrenheit  | miles/hour
          # kelvin   | Kelvin      | km/h

          UNITS="metric"

          # Color Settings ______________________________________________________________

          COLOR_CLOUD="#606060"
          COLOR_THUNDER="#d3b987"
          COLOR_LIGHT_RAIN="#73cef4"
          COLOR_HEAVY_RAIN="#b3deef"
          COLOR_SNOW="#FFFFFF"
          COLOR_FOG="#606060"
          COLOR_TORNADO="#d3b987"
          COLOR_SUN="#ffc24b"
          COLOR_MOON="#FFFFFF"
          COLOR_ERR="#f43753"
          COLOR_WIND="#73cef4"
          COLOR_COLD="#b3deef"
          COLOR_HOT="#f43753"
          COLOR_NORMAL_TEMP="#FFFFFF"

          # Leave "" if you want the default polybar color
          COLOR_TEXT=""
          # Polybar settings ____________________________________________________________

          # Font for the weather icons
          WEATHER_FONT_CODE=2

          # Font for the thermometer icon
          TEMP_FONT_CODE=6

          # Wind settings _______________________________________________________________

          # Display info about the wind or not. yes/no
          DISPLAY_WIND="no"

          # Show beaufort level in windicon
          BEAUFORTICON="no"

          # Display in knots. yes/no
          KNOTS="no"

          # How many decimals after the floating point
          DECIMALS=0

          # Min. wind force required to display wind info (it depends on what
          # measurement unit you have set: knots, m/s or mph). Set to 0 if you always
          # want to display wind info. It's ignored if DISPLAY_WIND is false.

          MIN_WIND=11

          # Display the numeric wind force or not. If not, only the wind icon will
          # appear. yes/no

          DISPLAY_FORCE="no"

          # Display the wind unit if wind force is displayed. yes/no
          DISPLAY_WIND_UNIT="no"

          # Thermometer settings ________________________________________________________

          # When the thermometer icon turns red
          HOT_TEMP=30

          # When the thermometer icon turns blue
          COLD_TEMP=0

          # Other settings ______________________________________________________________

          # Display the weather description. yes/no
          DISPLAY_LABEL="yes"

          # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

          if [ "$COLOR_TEXT" != "" ]; then
              COLOR_TEXT_BEGIN="%{F$COLOR_TEXT}"
              COLOR_TEXT_END="%{F-}"
          fi
          if [ -z "$CITY_NAME" ]; then
              IP=`curl -s ifconfig.me`  # == ip
              IPCURL=$(curl -s https://ipinfo.io/$IP)
              CITY_NAME=$(echo $IPCURL | jq -r ".city")
              COUNTRY_CODE=$(echo $IPCURL | jq -r ".country")
          fi

          RESPONSE=""
          ERROR=0
          ERR_MSG=""
          if [ $UNITS = "kelvin" ]; then
              UNIT_URL=""
          else
              UNIT_URL="&units=$UNITS"
          fi
          URL="api.openweathermap.org/data/2.5/weather?appid=$APIKEY$UNIT_URL&lang=$LANG&q=$(echo $CITY_NAME| sed 's/ /%20/g'),$\{COUNTRY_CODE}"

          function getData {
              ERROR=0
              # For logging purposes
              # echo " " >> "$HOME/.weather.log"
              # echo `date`" ################################" >> "$HOME/.weather.log"
              RESPONSE=`curl -s $URL`
              CODE="$?"
              if [ "$1" = "-d" ]; then
                  echo $RESPONSE
                  echo ""
              fi
              # echo "Response: $RESPONSE" >> "$HOME/.weather.log"
              RESPONSECODE=0
              if [ $CODE -eq 0 ]; then
                  RESPONSECODE=`echo $RESPONSE | jq .cod`
              fi
              if [ $CODE -ne 0 ] || [ ${RESPONSECODE:=429} -ne 200 ]; then
                  if [ $CODE -ne 0 ]; then
                      ERR_MSG="curl Error $CODE"
                      # echo "curl Error $CODE" >> "$HOME/.weather.log"
                  else
                      ERR_MSG="Conn. Err. $RESPONSECODE"
                      # echo "API Error $RESPONSECODE" >> "$HOME/.weather.log"
                  fi
                  ERROR=1
              # else
              #     echo "$RESPONSE" > "$HOME/.weather-last"
              #     echo `date +%s` >> "$HOME/.weather-last"
              fi
          }
          function setIcons {
              if [ $WID -le 232 ]; then
                  #Thunderstorm
                  ICON_COLOR=$COLOR_THUNDER
                  if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
                      ICON=""
                  else
                      ICON=""
                  fi
              elif [ $WID -le 311 ]; then
                  #Light drizzle
                  ICON_COLOR=$COLOR_LIGHT_RAIN
                  if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
                      ICON=""
                  else
                      ICON=""
                  fi
              elif [ $WID -le 321 ]; then
                  #Heavy drizzle
                  ICON_COLOR=$COLOR_HEAVY_RAIN
                  if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
                      ICON=""
                  else
                      ICON=""
                  fi
              elif [ $WID -le 531 ]; then
                  #Rain
                  ICON_COLOR=$COLOR_HEAVY_RAIN
                  if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
                      ICON=""
                  else
                      ICON=""
                  fi
              elif [ $WID -le 622 ]; then
                  #Snow
                  ICON_COLOR=$COLOR_SNOW
                  ICON=""
              elif [ $WID -le 771 ]; then
                  #Fog
                  ICON_COLOR=$COLOR_FOG
                  ICON=""
              elif [ $WID -eq 781 ]; then
                  #Tornado
                  ICON_COLOR=$COLOR_TORNADO
                  ICON=""
              elif [ $WID -eq 800 ]; then
                  #Clear sky
                  if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
                      ICON_COLOR=$COLOR_SUN
                      ICON=""
                  else
                      ICON_COLOR=$COLOR_MOON
                      ICON=""
                  fi
              elif [ $WID -eq 801 ]; then
                  # Few clouds
                  if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
                      ICON_COLOR=$COLOR_SUN
                      ICON=""
                  else
                      ICON_COLOR=$COLOR_MOON
                      ICON=""
                  fi
              elif [ $WID -le 804 ]; then
                  # Overcast
                  ICON_COLOR=$COLOR_CLOUD
                  ICON=""
              else
                  ICON_COLOR=$COLOR_ERR
                  ICON=""
              fi
              WIND=""
              WINDFORCE=`echo "$RESPONSE" | jq .wind.speed`
              WINDICON=""
              if [ $BEAUFORTICON == "yes" ];then
                  WINDFORCE2=`echo "scale=$DECIMALS;$WINDFORCE * 3.6 / 1" | bc`
                  if [ $WINDFORCE2 -le 1 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 1 ] && [ $WINDFORCE2 -le 5 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 5 ] && [ $WINDFORCE2 -le 11 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 11 ] && [ $WINDFORCE2 -le 19 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 19 ] && [ $WINDFORCE2 -le 28 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 28 ] && [ $WINDFORCE2 -le 38 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 38 ] && [ $WINDFORCE2 -le 49 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 49 ] && [ $WINDFORCE2 -le 61 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 61 ] && [ $WINDFORCE2 -le 74 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 74 ] && [ $WINDFORCE2 -le 88 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 88 ] && [ $WINDFORCE2 -le 102 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 102 ] && [ $WINDFORCE2 -le 117 ]; then
                      WINDICON=""
                  elif [ $WINDFORCE2 -gt 117 ]; then
                      WINDICON=""
                  fi
              fi
              if [ $KNOTS = "yes" ]; then
                  case $UNITS in
                      "imperial")
                          # The division by one is necessary because scale works only for divisions. bc is stupid.
                          WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE * 0.8689762419 / 1" | bc`
                          ;;
                      *)
                          WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE * 1.943844 / 1" | bc`
                          ;;
                  esac
              else
                  if [ $UNITS != "imperial" ]; then
                      # Conversion from m/s to km/h
                      WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE * 3.6 / 1" | bc`
                  else
                      WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE / 1" | bc`
                  fi
              fi
              if [ "$DISPLAY_WIND" = "yes" ] && [ `echo "$WINDFORCE >= $MIN_WIND" |bc -l` -eq 1 ]; then
                  WIND="%{T$WEATHER_FONT_CODE}%{F$COLOR_WIND}$WINDICON%{F-}%{T-}"
                  if [ $DISPLAY_FORCE = "yes" ]; then
                      WIND="$WIND $COLOR_TEXT_BEGIN$WINDFORCE$COLOR_TEXT_END"
                      if [ $DISPLAY_WIND_UNIT = "yes" ]; then
                          if [ $KNOTS = "yes" ]; then
                              WIND="$WIND $\{COLOR_TEXT_BEGIN}kn$COLOR_TEXT_END"
                          elif [ $UNITS = "imperial" ]; then
                              WIND="$WIND $\{COLOR_TEXT_BEGIN}mph$COLOR_TEXT_END"
                          else
                              WIND="$WIND $\{COLOR_TEXT_BEGIN}km/h$COLOR_TEXT_END"
                          fi
                      fi
                  fi
                  WIND="$WIND |"
              fi
              if [ "$UNITS" = "metric" ]; then
                  TEMP_ICON="󰔄"
              elif [ "$UNITS" = "imperial" ]; then
                  TEMP_ICON="󰔅"
              else
                  TEMP_ICON="󰔆"
              fi

              TEMP=`echo "$TEMP" | cut -d "." -f 1`

              if [ "$TEMP" -le $COLD_TEMP ]; then
                  TEMP="%{F$COLOR_COLD}%{T$TEMP_FONT_CODE}%{T-}%{F-} $COLOR_TEXT_BEGIN$TEMP%{T$TEMP_FONT_CODE}$TEMP_ICON%{T-}$COLOR_TEXT_END"
              elif [ `echo "$TEMP >= $HOT_TEMP" | bc` -eq 1 ]; then
                  TEMP="%{F$COLOR_HOT}%{T$TEMP_FONT_CODE}%{T-}%{F-} $COLOR_TEXT_BEGIN$TEMP%{T$TEMP_FONT_CODE}$TEMP_ICON%{T-}$COLOR_TEXT_END"
              else
                  TEMP="%{F$COLOR_NORMAL_TEMP}%{T$TEMP_FONT_CODE}%{T-}%{F-} $COLOR_TEXT_BEGIN$TEMP%{T$TEMP_FONT_CODE}$TEMP_ICON%{T-}$COLOR_TEXT_END"
              fi
          }

          function outputCompact {
              OUTPUT="$WIND %{T$WEATHER_FONT_CODE}%{F$ICON_COLOR}$ICON%{F-}%{T-} $ERR_MSG$COLOR_TEXT_BEGIN$DESCRIPTION$COLOR_TEXT_END| $TEMP"
              # echo "Output: $OUTPUT" >> "$HOME/.weather.log"
              echo "$OUTPUT"
          }

          getData $1
          if [ $ERROR -eq 0 ]; then
              MAIN=`echo $RESPONSE | jq .weather[0].main`
              WID=`echo $RESPONSE | jq .weather[0].id`
              DESC=`echo $RESPONSE | jq .weather[0].description`
              SUNRISE=`echo $RESPONSE | jq .sys.sunrise`
              SUNSET=`echo $RESPONSE | jq .sys.sunset`
              DATE=`date +%s`
              WIND=""
              TEMP=`echo $RESPONSE | jq .main.temp`
              if [ $DISPLAY_LABEL = "yes" ]; then
                  DESCRIPTION=`echo "$RESPONSE" | jq .weather[0].description | tr -d '"' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'`" "
              else
                  DESCRIPTION=""
              fi
              PRESSURE=`echo $RESPONSE | jq .main.pressure`
              HUMIDITY=`echo $RESPONSE | jq .main.humidity`
              setIcons
              outputCompact
          else
              echo "gówno nie działa"
          fi
        '';
      };
    };
  };
}
