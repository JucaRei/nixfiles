#
#  Bar
#

{ config, lib, pkgs, ... }:

let
  polybar = pkgs.polybar.override {
    # Extra Packages
    alsaSupport = true;
    pulseSupport = true;
  };
in
{
  services = {
    polybar = {
      enable = true;
      script = ''
        killall -q polybar &
        while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
        polybar main &
        #polybar sec &
      ''; # Run Polybar on Startup
      package = polybar;
      config = {
        "default" = {
          module-foreground = "#0A0E14";
          module-background = "#C7C7C7";
          triangle-right = "%{T2}█%{T-}";
          triangle-left = "%{T2}█%{T-}";
          #triangle-right = %{T2}%{T-}
          #triangle-left = %{T2}%{T-}

          #triangle-right = %{T2} %{T-}
          #triangle-left = %{T2} %{T-}

          #triangle-right = %{T2}%{T-}
          #triangle-left = %{T2}%{T-}

          #triangle-right = %{T2}█ %{T-}
          #triangle-left = %{T2} █%{T-}

          #triangle-right = %{T2} %{T-}
          #triangle-left = %{T2} %{T-}

          #triangle-right = %{T2}%{T-}
          #triangle-left = %{T2}%{T-}

          #triangle-right = %{T2}█%{T-}
          #triangle-left = %{T2}%{T-}

          #triangle-right = %{T2}%{T-}
          #triangle-left = %{T2}%{T-}
        };
        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = true;
        };
        "bar/main" = {
          # Bar "main"
          # monitor = mainMonitor;
          monitor = "Virtual-1";
          width = "100%";
          height = 20;

          background = "#2E3440";
          foreground = "#2E3440";

          border-size = 8;
          border-color = "#0A0E14";

          separater = " ";

          offset-x = 0;
          offset-y = 0;
          dpi = 96;
          radius = 0;
          # padding-right = 2;
          module-margin-left = 1;

          font-0 = "Hack Nerd Font:size:22;2";
          font-1 = "Hack Nerd font:size=22;4";
          font-2 = "Hack Nerd font:size=22;4";
          font-3 = "Hack Nerd font:size=8;2";

          # modules-left = "logo bspwm";
          # modules-right = "backlight pad memory cpu pad sink volume pad battery date";
          modules-left = "bspwm launchpad date";
          modules-center = "xwindow";
          modules-right = "memory wlan eth battery pulseaudio backlight color-picker power-menu";
          cursor-click = "pointer";
          cursor-scroll = "ns-resize";

          tray-position = "center";

          # tray-position = "right";
          # tray-detached = "false";

          enable-ipc = true;
          wm-restack = "bspwm";
        };
        # "bar/sec" = {
        #   # Bar "sec"
        #   monitor = "${secondMonitor}";
        #   width = "100%";
        #   height = 15;
        #   background = "#00000000";
        #   foreground = "#ccffffff";

        #   offset-y = 2;
        #   spacing = "1.5";
        #   padding-right = 2;
        #   module-margin-left = 1;

        #   font-0 = "SourceCodePro:size=10";
        #   font-1 = "FontAwesome6Free:style=Solid:size=8";
        #   font-2 = "FontAwesome6Free:style=Regular:size=8";
        #   font-3 = "FontAwesome6Brands:style=Regular:size=8";
        #   font-4 = "FiraCodeNerdFont:size=10";
        #   modules-left = "logo bspwm";
        #   modules-right = "sink volume pad date";

        #   wm-restack = "bspwm";
        # };
        "module/memory" = {
          # RAM
          type = "internal/memory";
          format = "<label>";
          format-foreground = "#999";
          label = "  %percentage_used%%";
        };
        "module/cpu" = {
          # CPU
          type = "internal/cpu";
          interval = 1;
          format = "<label>";
          format-foreground = "#999";
          label = " %percentage%%";
        };
        "module/volume" = {
          # Volume
          type = "internal/pulseaudio";
          interval = 2;
          use-ui-max = "false";
          format-volume = "<ramp-volume>  <label-volume>";
          label-muted = "  muted";
          label-muted-foreground = "#66";

          ramp-volume-0 = "";
          ramp-volume-1 = "";
          ramp-volume-2 = "";

          click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
        "module/backlight" = {
          # Brightness (xbacklight)
          type = "internal/backlight";
          card = "intel_backlight";
          format = "<ramp> <bar>";

          ramp-0 = "";
          ramp-1 = "";
          ramp-2 = "";

          bar-width = 10;
          bar-indicator = "|";
          bar-indicator-font = 3;
          bar-indicator-foreground = "#ff";
          bar-fill = "─";
          bar-fill-font = 3;
          bar-fill-foreground = "#ff";
          bar-empty = "─";
          bar-empty-font = 3;
          bar-empty-foreground = "#44";
        };
        "module/battery" = {
          # Battery
          type = "internal/battery";
          full-at = 98;

          label-full = "%percentage%%";
          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";

          format-charging = "<animation-charging> <label-charging>    ";
          format-discharging = "<ramp-capacity> <label-discharging>    ";
          format-full = "<ramp-capacity> <label-full>    ";

          ramp-capacity-0 = "";
          ramp-capacity-0-foreground = "#f53c3c";
          ramp-capacity-1 = "";
          ramp-capacity-1-foreground = "#ffa900";
          ramp-capacity-2 = "";
          ramp-capacity-3 = "";
          ramp-capacity-4 = "";

          bar-capacity-width = 10;
          bar-capacity-format = "%{+u}%{+o}%fill%%empty%%{-u}%{-o}";
          bar-capacity-fill = "█";
          bar-capacity-fill-foreground = "#ddffffff";
          bar-capacity-fill-font = 3;
          bar-capacity-empty = "█";
          bar-capacity-empty-font = 3;
          bar-capacity-empty-foreground = "#44ffffff";

          animation-charging-0 = "";
          animation-charging-1 = "";
          animation-charging-2 = "";
          animation-charging-3 = "";
          animation-charging-4 = "";
          animation-charging-framerate = 750;
        };
        "module/date" = {
          # Time/Date  Day-Month-Year Hour:Minute
          type = "internal/date";
          date = "  %%{F#999}%d-%m-%Y%%{F-} %%{F#fff}%H:%M%%{F-}";
        };
        "module/bspwm" = {
          type = "internal/bspwm";

          background = "#707880";

          pin-workspaces = true;
          occupied-scroll = true;

          #format = %{T4}<label-state>%{T-} <label-mode>
          format = "%{T4}<label-state>%{T-}";
          format-background = "#0A0E14";

          format-prefix = "";
          format-prefix-foreground = "#0A0E14";
          format-prefix-background = "#0A0E14";

          format-suffix = "";
          format-suffix-background = "#0A0E14";
          format-suffix-foreground = "#0A0E14";

          ws-icon-0 = "1;󰈹";
          ws-icon-1 = "2;󰅬";
          ws-icon-2 = "3;";
          ws-icon-3 = "4;󰨞";
          ws-icon-4 = "5;";
          #ws-icon-default = 
          ws-icon-default = "■";


          #label-active = %icon%
          #label-active = ████
          label-active = "██████";
          #label-active = ■■■■■■
          label-active-foreground = "#0A0E14";
          #label-active-underline= ${colors.red}
          label-active-padding = 1;

          #label-occupied = %icon%
          #label-occupied = 
          label-occupied = "■";
          label-occupied-foreground = "#0A0E14";
          label-occupied-padding = 1;

          label-urgent = "%name%";
          label-urgent-background = "#EA6C73";
          label-urgent-padding = 1;

          #label-empty = %icon%
          #label-empty = 
          label-empty = "□";
          label-empty-foreground = "#0A0E14";
          label-empty-padding = 1;

          label-monocle = "m";
          label-monocle-foreground = "#0A0E14";

          label-tiled = "t";
          label-tiled-foreground = "#0A0E14";

          label-fullscreen = "f";
          label-fullscreen-foreground = "#0A0E14";

          label-floating = "y";
          label-floating-foreground = "#0A0E14";

          label-pseudotiled = "P";
          label-pseudotiled-foreground = "#0A0E14";

          label-locked = "l";
          label-locked-foreground = "#0A0E14";

          label-sticky = "s";
          label-sticky-foreground = "#0A0E14";

          label-private = "p";
          label-private-foreground = "#0A0E14";

          label-marked = "M";
          label-marked-foreground = "#0A0E14";

        };
        "module/title" = {
          # Window Title
          type = "internal/xwindow";
          format = "<label>";
          format-background = "#00000000";
          format-foreground = "#ccffffff";
          label = "%title%";
          label-maxlen = 75;
          label-empty = "";
          label-empty-foreground = "#ccffffff";
        };

        # CUSTOM
        "module/pad" = {
          # Padding
          type = "custom/text";
          content = "    ";
        };
        "module/mic" = {
          # Microphone
          type = "custom/script";
          interval = 1;
          tail = "true";
          exec = "~/.config/polybar/script/mic.sh status";
          click-left = "~/.config/polybar/script/mic.sh toggle";
        };
        "module/sink" = {
          # Sink
          type = "custom/script";
          interval = 1;
          tail = "true";
          exec = "~/.config/polybar/script/sink.sh status";
          click-left = "~/.config/polybar/script/sink.sh toggle";
        };
        "module/logo" = {
          # Menu
          type = "custom/menu";
          expand-right = true;

          label-open = " %{F#a7c7e7} ";
          label-close = " %{F#a7c7e7} ";
          label-separator = "|";
          format-spacing = "1";

          menu-0-0 = "";
          menu-0-0-exec = "menu-open-1";
          menu-0-1 = "";
          menu-0-1-exec = "menu-open-2";

          menu-1-0 = "";
          menu-1-0-exec = "sleep 0.5; bspc quit";
          menu-1-1 = "";
          menu-1-1-exec = "sleep 0.5; xset dpms force standby";
          menu-1-2 = "";
          menu-1-2-exec = "sleep 0.5; systemctl suspend";
          menu-1-3 = "";
          menu-1-3-exec = "sleep 0.5; systemctl poweroff";
          menu-1-4 = "";
          menu-1-4-exec = "sleep 0.5; systemctl reboot";

          menu-2-0 = "";
          menu-2-0-exec = "alacritty &";
          menu-2-1 = "";
          menu-2-1-exec = "firefox &";
          menu-2-2 = "";
          menu-2-2-exec = "emacs &";
          menu-2-3 = "";
          menu-2-3-exec = "plexmediaplayer &";
          menu-2-4 = "";
          menu-2-4-exec = "flatpak run com.obsproject.Studio &";
          menu-2-5 = "";
          menu-2-5-exec = "lutris &";
          menu-2-6 = "";
          menu-2-6-exec = "steam &";
        };
        "module/bluetooth" = {
          # Bluetooth
          type = "custom/text";
          content = "";
          click-left = "${pkgs.blueman}/bin/blueman-manager";
        };
      };
    };
  };
  home.file.".config/polybar/script/mic.sh" = {
    text = ''
      #!/bin/sh

      case $1 in
          "status")
          #MUTED=$(pacmd list-sources | awk '/\*/,EOF {print}' | awk '/muted/ {print $2; exit}')
          #if [[ $MUTED = "no" ]]; then
          MUTED=$(awk -F"[][]" '/Left:/ { print $4 }' <(amixer sget Capture))
          if [[ $MUTED = "on" ]]; then
              echo ''
          else
              echo ''
          fi
          ;;
          "toggle")
          #ID=$(pacmd list-sources | grep "*\ index:" | cut -d' ' -f5)
          #pactl set-source-mute $ID toggle
          ${pkgs.alsa-utils}/bin/amixer set Capture toggle
          ;;
      esac
    '';
    executable = true;
  };
  home.file.".config/polybar/script/sink.sh" = {
    text = ''
      #!/bin/sh

      ID1=$(awk '/ Built-in Audio Analog Stereo/ {sub(/.$/,"",$2); print $2 }' <(${pkgs.wireplumber}/bin/wpctl status) | head -n 1)
      ID2=$(awk '/ S10 Bluetooth Speaker/ {sub(/.$/,"",$2); print $2 }' <(${pkgs.wireplumber}/bin/wpctl status) | sed -n 2p)

      HEAD=$(awk '/ Built-in Audio Analog Stereo/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | sed -n 2p)
      SPEAK=$(awk '/ S10 Bluetooth Speaker/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | head -n 1)

      case $1 in
          "status")
          if [[ $HEAD = "*" ]]; then
              echo ''
          elif [[ $SPEAK = "*" ]]; then
              echo '蓼'
          fi
          ;;
          "toggle")
          if [[ $HEAD = "*" ]]; then
              ${pkgs.wireplumber}/bin/wpctl set-default $ID2
          elif [[ $SPEAK = "*" ]]; then
              ${pkgs.wireplumber}/bin/wpctl set-default $ID1
          fi
          ;;
      esac
    '';
    executable = true;
  };
}
