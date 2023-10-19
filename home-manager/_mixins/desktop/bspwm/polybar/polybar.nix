{ pkgs, ... }: {
  services = {
    polybar = {
      enable = true;
      package = pkgs.override.polybarFull {
        # Extra Packages
        alsaSupport = true;
        pulseSupport = true;
      };
      script = "polybar &";
      settings = {
        ### config.ini
        "colors" = {
          background = "#1a1b26";
          background-alt = "#24283b";
          foreground = "#c0caf5";
          primary = "#e0af68";
          secondary = "#9ece6a";
          alert = "#db4b4b";
          disabled = "#414868";
          blue = "#7aa2f7";
        };
        "bar/bar" = {
          width = "1884px";
          height = "33pt";
          radius = 6;
          fixed-center = true;
          dpi = 96;
          offset-x = 18;
          offset-y = 10;

          background = "\${colors.background}";
          foreground = "\${colors.foreground}";

          line-size = "3pt";

          border-size = "7pt";
          border-color = "\${colors.background}";
          border-radius = 15;

          padding-left = 0;
          padding-right = 1;

          font-0 = "Sofia Pro:style=Bold:size=20;3";
          font-1 = "Material Design Icons Desktop:size=16;3";
          font-2 = "Material Design Icons Desktop:size=20;5";
          font-3 = "JetBrainsMono Nerd Font:size=27;6";
          font-4 = "JetBrainsMono Nerd Font:size=17;5";
          font-5 = "JetBrainsMono Nerd Font:size=16;4";
          font-6 = "Material Design Icons Desktop:size=16;4";
          font-7 = "Sofia Pro:style=Bold:size=18;0";
          font-8 = "Material Design Icons Desktop:size=18;4";
          font-9 = "Feather:style=Bold:size=18;6";
          font-10 = "Material Design Icons Desktop:size=20:style=bold;5";
          font-11 = "Sofia Pro:style=Bold:size=14;3";
          font-12 = "Material Design Icons Desktop:size=14;3";
          font-13 = "JetBrainsMono Nerd Font:size=14;4";
          font-14 = "Grid Styles:size=18;4";

          modules-left = "launcher left1 xworkspaces right1 seperator left3 updates spotify gamemode right3";
          modules-center = "date";
          modules-right = "bspwm tray left2 battery network bluetooth microphone pulseaudio right2 github powermenu";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };

        ### gylphs.ini

        "glyph" = {
          gright = "";
          gleft = "";
        };
        "module/left1" = {
          type = custom/text;
          content-background = "\${colors.background}";
          content-foreground = "\${colors.background-alt}";
          content = "\${glyph.gleft}";
          content-font = 4;
        };
        "module/right1" = {
          type = custom/text;
          content-background = "\${colors.background}";
          content-foreground = "\${colors.background-alt}";
          content = "$\{glyph.gright}";
          content-font = 4;
        };
        "module/left2" = {
          type = custom/text;
          content-background = "\${colors.background}";
          content-foreground = "\${colors.background-alt}";
          content = "\${glyph.gleft}";
          content-font = 4;
        };
        "module/right2" = {
          type = custom/text;
          content-background = "\${colors.background}";
          content-foreground = "\${colors.background-alt}";
          content = "\${glyph.gright}";
          content-font = 4;
        };
        "module/left3" = {
          type = custom/text;
          content-background = "\${colors.background}";
          content-foreground = "\${colors.background-alt}";
          content = "\${glyph.gleft}";
          content-font = 4;
        };
        "module/right3" = {
          type = custom/text;
          content-background = "\${colors.background}";
          content-foreground = "\${colors.background-alt}";
          content = "\${glyph.gright}";
          content-font = 4;
        };

        ## modules.ini
        "modules/xworkspaces" = {
          type = internal/xworkspaces;

          label-active = "󰝥";
          label-active-foreground = "\${colors.blue}";
          label-active-background = "\${colors.background-alt}";
          label-active-padding = 2;

          label-occupied = "󰝥";
          label-occupied-foreground = "\${colors.primary}";
          label-occupied-background = "\${colors.background-alt}";
          label-occupied-padding = 2;

          label-urgent = "󰝥";
          label-urgent-foreground = "\${colors.alert}";
          label-urgent-background = "\${colors.background-alt}";
          label-urgent-padding = 2;

          label-empty = "󰝥";
          label-empty-foreground = "\${colors.disabled}";
          label-empty-background = "\${colors.background-alt}";
          label-empty-padding = 2;
          "module/bspwm" = {
            type = custom/script;
            exec = "cat $HOME/.config/bspwm/scripts/current-layout";
            click-left = "$HOME/.config/bspwm/scripts/switch-layouts";
            interval = 1;
            format = <label>;
            label = "   %output%";
            label-font = 15;
            format-foreground = "\${colors.blue}";
            format-padding = 0;
          };
          "module/launcher" = {
            type = custom/text;
            content = "󱓞";
            content-foreground = "\${colors.blue}";
            click-left = "rofi -show drun";
            content-padding = 3;
            content-font = 3;
          };
          "module/powermenu" = {
            type = custom/text;
            content = "   ";
            content-foreground = "\${colors.alert}";
            click-left = "eww open-many --toggle background-closer powermenu";
            content-padding = 0;
            content-font = 5;
          };
          "module/tray" = {
            type = custom/script;
            exec = "tail -F $HOME/.config/polybar/scripts/tray-status 2> /dev/null";
            click-left = "$HOME/.config/polybar/scripts/tray --toggle";
            tail = true;
            label-font = 10;
            label-padding = 3;
          };
          "module/date" = {
            type = internal/date;
            interval = 1;

            date = "%I:%M %p";
            date-alt = "%a,  %B %d";

            label = "%{A1:eww open-many --toggle background-closer main:}%date%%{A}";
            label-foreground = "\${colors.foreground}";
          };
          "module/network" = {
            type = internal/network;
            # ; Name of the network interface to display. You can get the names of the
            # ; interfaces on your machine with `ip link`
            # ; Wireless interfaces often start with `wl` and ethernet interface with `eno` or `eth`
            interface = "wlan0";

            # ; If no interface is specified, polybar can detect an interface of the given type.
            # ; If multiple are found, it will prefer running interfaces and otherwise just
            # ; use the first one found.
            # ; Either 'wired' or 'wireless'
            # ; New in version 3.6.0
            interface-type = "wireless";

            # ; Seconds to sleep between updates
            # ; Default: 1
            interval = "3.0";

            # ; Test connectivity every Nth update
            # ; A value of 0 disables the feature
            # ; NOTE: Experimental (needs more testing)
            # ; Default: 0
            # ;ping-interval = 3

            # ; @deprecated: Define min width using token specifiers (%downspeed:min% and %upspeed:min%)
            # ; Minimum output width of upload/download rate
            # ; Default: 3
            udspeed-minwidth = 5;

            # ; Accumulate values from all interfaces
            # ; when querying for up/downspeed rate
            # ; Default: false
            accumulate-stats = true;

            # ; Consider an `UNKNOWN` interface state as up.
            # ; Some devices like USB network adapters have
            # ; an unknown state, even when they're running
            # ; Default: false
            unknown-as-up = true;

            # ; Available tags:
            # ;   <label-connected> (default)
            # ;   <ramp-signal>
            format-connected = "%{A1:$HOME/.config/eww/System-Menu/launch:}<ramp-signal>%{A}";

            # ; Available tags:
            # ;   <label-disconnected> (default)
            format-disconnected = <label-disconnected>;

            # ; Default: (none)
            label-disconnected = "%{A1:$HOME/.config/eww/System-Menu/launch:}󰤭%{A}";
            label-disconnected-foreground = "\${colors.alert}";
            label-disconnected-background = "\${colors.background-alt}";
            label-disconnected-font = 7;
            label-disconnected-padding = 1;

            # ; Only applies if <ramp-signal> is used
            ramp-signal-0 = "󰤯";
            ramp-signal-1 = "󰤟";
            ramp-signal-2 = "󰤢";
            ramp-signal-3 = "󰤥";
            ramp-signal-4 = "󰤨";
            ramp-signal-foreground = "\${colors.foreground}";
            ramp-signal-background = "\${colors.background-alt}";
            ramp-signal-font = 7;
            ramp-signal-padding = 1;
          };
          "module/battery" = {
            type = internal/battery;

            # ; This is useful in case the battery never reports 100% charge
            # ; Default: 100
            full-at = 100;

            # ; format-low once this charge percentage is reached
            # ; Default: 10
            # ; New in version 3.6.0
            low-at = 20;

            # ; Use the following command to list batteries and adapters:
            # ; $ ls -1 /sys/class/power_supply/
            battery = "BAT1";
            adapter = "ACAD";

            # ; If an inotify event haven't been reported in this many
            # ; seconds, manually poll for new values.
            # ;
            # ; Needed as a fallback for systems that don't report events
            # ; on sysfs/procfs.
            # ;
            # ; Disable polling by setting the interval to 0.
            # ;
            # ; Default: 5
            poll-interval = 5;

            # ; Available tags:
            # ;   <label-charging> (default)
            # ;   <bar-capacity>
            # ;   <ramp-capacity>
            # ;   <animation-charging>
            format-charging = "%{A1:$HOME/.config/eww/System-Menu/launch:}<animation-charging>%{A}";

            # ; Available tags:
            # ;   <label-discharging> (default)
            # ;   <bar-capacity>
            # ;   <ramp-capacity>
            # ;   <animation-discharging>
            format-discharging = "%{A1:$HOME/.config/eww/System-Menu/launch:}<ramp-capacity>%{A}";

            # ; Format used when battery level drops to low-at
            # ; If not defined, format-discharging is used instead.
            # ; Available tags:
            # ;   <label-low>
            # ;   <animation-low>
            # ;   <bar-capacity>
            # ;   <ramp-capacity>
            # ; New in version 3.6.0
            format-low = "%{A1:$HOME/.config/eww/System-Menu/launch:}<animation-low>%{A}";
            format-full = "%{A1:$HOME/.config/eww/System-Menu/launch:}<ramp-capacity>%{A}";

            # ; Available tokens:
            # ;   %percentage% (default) - is set to 100 if full-at is reached
            # ;   %percentage_raw%
            # ;   %time%
            # ;   %consumption% (shows current charge rate in watts)
            label-charging = "%percentage%%";
            label-charging-padding = 1;

            # ; Available tokens:
            # ;   %percentage% (default) - is set to 100 if full-at is reached
            # ;   %percentage_raw%
            # ;   %time%
            # ;   %consumption% (shows current discharge rate in watts)
            label-discharging = "%percentage%%";
            label-discharging-padding = 1;

            # ; Available tokens:
            # ;   %percentage% (default) - is set to 100 if full-at is reached
            # ;   %percentage_raw%
            # ;   %time%
            # ;   %consumption% (shows current discharge rate in watts)
            # ; New in version 3.6.0
            label-low = "%percentage%%";
            label-low-padding = 1;

            # ; Only applies if <animation-charging> is used
            animation-charging-0 = "   ";
            animation-charging-1 = "   ";
            animation-charging-2 = "   ";
            animation-charging-3 = "   ";
            animation-charging-4 = "   ";
            animation-charging-foreground = "\${colors.secondary}";
            animation-charging-background = "\${colors.background-alt}";
            animation-charging-font = 6;
            # ; Framerate in milliseconds
            animation-charging-framerate = 750;

            # ; Only applies if <ramp-capacity> is used
            ramp-capacity-0 = "   ";
            ramp-capacity-1 = "   ";
            ramp-capacity-2 = "   ";
            ramp-capacity-3 = "   ";
            ramp-capacity-4 = "   ";
            ramp-capacity-background = "\${colors.background-alt}";
            ramp-capacity-font = 6;

            # ; Framerate in milliseconds
            animation-discharging-framerate = 500;

            # ; Only applies if <animation-low> is used
            # ; New in version 3.6.0
            animation-low-0 = "  ";
            animation-low-1 = "  ";
            animation-low-framerate = 200;
            animation-low-background = "\${colors.background-alt}";
            animation-low-font = 6;
            animation-low-foreground = "\${colors.alert}";
          };
          "module/pulseaudio" = {
            type = internal/pulseaudio;

            # ; Use PA_VOLUME_UI_MAX (~153%) if true, or PA_VOLUME_NORM (100%) if false
            # ; Default: true
            use-ui-max = false;

            # ; Interval for volume increase/decrease (in percent points)
            # ; Default: 5
            interval = 5;

            # ; Available tags:
            # ;   <label-volume> (default)
            # ;   <ramp-volume>
            # ;   <bar-volume>
            format-volume = "%{A1:$HOME/.config/eww/System-Menu/launch:}<ramp-volume>%{A}";

            # ; Available tags:
            # ;   <label-muted> (default)
            # ;   <ramp-volume>
            # ;   <bar-volume>
            format-muted = "%{A1:$HOME/.config/eww/System-Menu/launch:}<label-muted>%{A}";

            # ; Available tokens:
            # ;   %percentage% (default)
            # ;   %decibels%
            # ;label-volume = %percentage%%

            # ; Available tokens:
            # ;   %percentage% (default)
            # ;   %decibels%
            label-muted = "󰝟";
            label-muted-foreground = "\${colors.alert}";
            label-muted-background = "\${colors.background-alt}";
            label-muted-font = 9;
            label-muted-padding = 1;

            # ; Only applies if <ramp-volume> is used
            ramp-volume-0 = "󰕿";
            ramp-volume-1 = "󰖀";
            ramp-volume-2 = "󰕾";
            ramp-volume-font = 9;
            ramp-volume-background = "\${colors.background-alt}";
            ramp-volume-padding = 1;

            # ; Right and Middle click
            click-right = "amixer sset Master toggle";
            # ; click-middle =
          };
          "module/github" = {
            type = custom/script;
            exec = "$HOME/.config/polybar/scripts/github";
            format = <label>;
            label = "%output%";
            format-prefix = "󰊤 ";
            format-prefix-font = 3;
            interval = 60;
            format-padding = 3;
          };
          "module/updates" = {
            type = custom/script;
            exec = "~/.config/polybar/scripts/updates";
            format = <label>;
            label = "%output%";
            format-foreground = "\${colors.foreground}";
            format-background = "\${colors.background-alt}";
            label-font = 12;
            format-font = 6;
            format-prefix = " ";
            interval = 7200;
            click-left = "kitty --hold paru";
          };
          "module/seperator" = {
            type = custom/text;
            content = "  ";
            content-font = 3;
          };
          "module/spotify" = {
            type = custom/script;
            tail = true;
            interval = 1;
            format-prefix = "%{A1:eww open-many --toggle background-closer player:} %{A}";
            format-prefix-padding = 1;
            format-font = 14;
            label-font = 13;
            format-background = "\${colors.background-alt}";
            format-foreground = "\${colors.foreground}";
            format = "%{A1:eww open-many --toggle background-closer player:}<label>%{A}";
            exec = "~/.config/polybar/scripts/scroll-spotify";
          };
          "module/bluetooth" = {
            type = custom/script;
            exec = "~/.config/polybar/scripts/bluetooth";
            interval = 2;
            click-left = "exec blueberry";
            click-right = "exec ~/.config/polybar/scripts/toggle-bluetooth";
            format-padding = 1;
            format-font = 2;
            format-background = "\${colors.background-alt}";
            format-foreground = "\${colors.foreground}";
          };
          "module/microphone" = {
            type = custom/script;
            exec = "~/.config/polybar/scripts/microphone";
            interval = 5;
            format-padding = 1;
            format-font = 14;
            format-background = "\${colors.background-alt}";
            format-foreground = "\${colors.foreground}";
          };
          "module/gamemode" = {
            type = custom/script;
            exec = "~/.config/polybar/scripts/gamemode";
            interval = 2;
            format-padding = 1;
            format-font = 5;
            format-background = "\${colors.background-alt}";
            format-foreground = "\${colors.foreground}";
          };
        };
      };
    };
  };
}
