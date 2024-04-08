{ pkgs, config, lib ? pkgs.lib, username, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  fonts = import ./fonts.nix { inherit pkgs; };

  okay = green;
  warn = orange;
  fail = red;
  alert = cyan;
  dim = grey;

  # --icon-playing "${okay ""}"

  player-mpris-tail = pkgs.writeShellScriptBin "player-mpris-tail" ''
    ${pkgs.player-mpris-tail}/bin/player-mpris-tail \
      --icon-playing #A7C080 "" \
      --icon-paused #A7C080 "" \
      --icon-stopped #D83F31 "" \
      --icon-none "" \
      --format "{icon} {artist} - {title} ({album})" \
      --blacklist vlc \
      "$@"
  '';

  ##################
  ### Colors.ini ###
  ##################

  ### Colors
  # ;; Dark Add FC at the beginning #FC1E1F29 for 99 transparency
  bg = "#2D353B";
  bg-alt = "#BF1D1F28";
  fg = "#d3c6aa";
  mb = "#2D353B";

  trans = "#00000000";
  white = "#FFFFFF";
  black = "#000000";

  blue-arch = "#0A9CF5";
  amber = "#FBC02D";
  sapphire = "#74c7ec";

  red = "#E67E80";
  orange = "#E69875";
  yellow = "#DBBC7F";
  green = "#A7C080";
  aqua = "#83C092";
  blue = "#7FBBB3";
  purple = "#D699B6";
  pink = "#EC407A";
  cyan = "#79E6F3";
  teal = "#00B19F";
  lime = "#B9C244";
  brown = "#AC8476";
  grey = "#8C8C8C";
  indigo = "#6C77BB";
  blue-gray = "#6D8895";

  pallete = "#D83F31";
in

{
  home = {
    file = {
      "/home/${username}/.config/polybar/scripts/polywins.sh" = {
        executable = true;
        text = builtins.readFile ../../config/polybar/scripts/polywins;
      };
    };
  };
  services = {
    polybar = {
      enable = true;
      package = nixgl pkgs.unstable.polybarFull;
      script = "polybar bar/everforest &";
      settings = {
        "bar/everforest" = {
          ##################
          ### Config.ini ###
          ##################
          "global/wm" = {
            margin-bottom = 0;
            margin-top = 0;
          };

          "default" = {
            module-foreground = "${bg}";
            module-background = "${red}";

            triangle-right = "%{T2} %{T-}";
            triangle-left = "%{T2} %{T-}";

            #triangle-right = %{T2}█ %{T-}
            #triangle-left = %{T2} █%{T-}

            #triangle-right = %{T2} %{T-}
            #triangle-left = %{T2} %{T-}

            #triangle-right = %{T2}%{T-}
            #triangle-left = %{T2}%{T-}

            # monitor = "";
            # monitor-fallback = "";
            # monitor-strict = false;

            # override-redirect = false;
            # fixed-center = true;

            # width = "2.5%";
            # height = 40;

            # offset-x = "2%";
            # offset-y = 10;

            # background = "${bg-alt}";
            # foreground = "${fg}";

            # radius = 6;

            # line-size = 2;
            # line-color = "${blue}";

            # padding = 0;

            # module-margin-left = 0;
            # module-margin-right = 0;

            # font-0 = "${pkgs.iosevka}/share/fonts/truetype/Iosevka-Regular.ttf";
            font-0 = with fonts.polybar-0;
              "${ftname};${toString offset}";
            font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
            font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
            font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
            font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
            font-5 = with fonts.polybar-5; "${ftname};${toString offset}";

          };

          "bar" = {
            # monitor = "";
            # monitor-fallback = "";
            monitor-strict = false;
            # monitor-exact = true;

            override-redirect = false;

            bottom = false;
            fixed-center = true;

            width = "99%";
            height = 24;

            offset-x = "0.5%";
            # offset-y = 10;

            background = "${bg}";
            foreground = "${fg}";

            radius = "4.0";

            line-size = 2;
            line-color = "${blue}";

            border-size = "1.4px";
            border-color = "${bg}";

            padding = "0.2";

            module-margin-left = 0;
            module-margin-right = 0;

            font-0 = with fonts.polybar-0; "${ftname};${toString offset}";
            font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
            font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
            font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
            font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
            font-5 = with fonts.polybar-5; "${ftname};${toString offset}";
            font-6 = with fonts.polybar-6; "${ftname};${toString offset}";

            modules-left = "sep launcher blok bspwm round-left polywins round-right";
            # modules-center =
            # ; modules-right = sep network blok2 weather blok audio blok memory_bar blok battery blok date blok powermenu sep;
            # modules-right = sep weather blok audio blok memory_bar blok cpu_bar blok date blok powermenu sep pulseaudio-control-output
            modules-right = "sep temperature blok2 filesystem blok2 memory_bar blok2 cpu_bar blok pulseaudio-control-output blok date blok2 battery blok powermenu sep";

            spacing = 0;
            # separator =
            dim-value = 1.0;

            locale = "pt_BR.UTF-8";

            tray-position = "none";
            tray-detached = false;
            tray-maxsize = 16;
            tray-background = "${sapphire}";
            tray-offset-x = 0;
            tray-offset-y = 0;
            tray-padding = 0;
            tray-scale = 1.0;

            wm-restack = "bspwm";
            enable-ipc = true;

            cursor-click = "pointer";
            cursor-scroll = "ns-resize";
          };

          "settings" = {
            screenchange-reload = true;

            compositing-background = "source";
            compositing-foreground = "over";
            compositing-overline = "over";
            compositing-underline = "over";
            compositing-border = "over";

            pseudo-transparency = true;
          };
        };
      };

      config = {
        ##################
        ### System.ini ###
        ##################
        # ; When some modules in the polybar doesn't show up.
        # ; Look for battery/adapter: "ls -l /sys/class/power_supply"
        # ; Look for backlight: "ls -l /sys/class/backlight"
        # ; Look for network: "ls -l /sys/class/net"
        "system" = {
          adapter = "AC";
          battery = "BAT1";
          graphics_card = "intelgpu";
          network_interface = "wlan0";
        };
        ###################
        ### Modules.ini ###
        ###################
        # https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/player-mpris-tail
        "module/mpris" = {
          type = "custom/script";
          exec = "${player-mpris-tail}/bin/player-mpris-tail";
          tail = true;
        };
        "module/pulseaudio-control-output" = {
          type = "custom/script";
          tail = true;
          exec = ''
            ${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --icons-volume " , " --icon-muted " " --node-nicknames-from "device.description" --node-nickname "alsa_output.pci-0000_00_1b.0.analog-stereo:  Speakers" --node-nickname "alsa_output.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo:  Headphones" listen
          '';
          click-right = "exec ${pkgs.pavucontrol}bin/pavucontrol &";
          click-middle = ''${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --node-blacklist "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2" next-node'';
          scroll-up = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --volume-max 130 up";
          scroll-down = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --volume-max 130 down";
          label-foreground = "${fg}";
        };
        "module/polywins" = {
          type = "custom/script";
          exec = "/home/${username}/.config/polybar/scripts/polywins.sh";
          format = "<label>";
          format-background = "#2E4374";
          label = "%output%";
          label-padding = 0;
          tail = true;
        };
        "module/battery" = {
          type = "internal/battery";
          full-at = 100;
          battery = "$\{system.battery}";
          adapter = "$\{system.adapter}";
          poll-interval = 2;
          time-format = "%H:%M";
          format-charging = "<animation-charging><label-charging>";
          format-charging-prefix = "";
          format-discharging = "<ramp-capacity><label-discharging>";
          format-full = "<label-full>";
          format-full-prefix = " ";
          format-full-prefix-font = 2;
          format-full-prefix-foreground = "${fg}";
          format-full-prefix-background = "${mb}";

          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";
          label-full = "%percentage%%";

          label-charging-background = "${mb}";
          label-discharging-background = "${mb}";
          label-full-background = "${mb}";

          label-charging-foreground = "${fg}";
          label-discharging-foreground = "${fg}";
          label-full-foreground = "${fg}";

          ramp-capacity-0 = " ";
          ramp-capacity-1 = " ";
          ramp-capacity-2 = " ";
          ramp-capacity-3 = " ";
          ramp-capacity-4 = " ";
          ramp-capacity-font = 2;
          ramp-capacity-foreground = "${green}";
          ramp-capacity-background = "${mb}";

          animation-charging-0 = " ";
          animation-charging-1 = " ";
          animation-charging-2 = " ";
          animation-charging-3 = " ";
          animation-charging-4 = " ";
          animation-charging-font = 2;
          animation-charging-foreground = "${orange}";
          animation-charging-background = "${mb}";
          animation-charging-framerate = "750;";
        };
        "module/date" = {
          type = "internal/date";
          interval = "1.0";
          time = "%H:%M";
          format-background = "${mb}";
          format-foreground = "${fg}";
          date-alt = " %A, %d %B %Y";
          format = "<label>";
          format-prefix = "";
          format-prefix-background = "${mb}";
          format-prefix-foreground = "${amber}";
          label = "%date% %time%";
        };
        "module/filesystem" = {
          type = "internal/fs";
          mount-0 = "/";
          interval = "60";
          # ; fixed-values = true;
          fixed-values = false;
          format-mounted = "<label-mounted>";
          format-mounted-prefix = "󰋊 ";
          format-mounted-prefix-background = "${mb}";
          format-mounted-prefix-foreground = "${yellow}";
          format-unmounted = "<label-unmounted>";
          format-unmounted-prefix = "󰋊 ";
          # ; label-mounted = "%used%";
          label-mounted = "%percentage_used%%";
          # ; label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%"
          label-mounted-background = "${mb}";
          label-unmounted = "%mountpoint%: not mounted";
          label-unmounted-foreground = "$\{disabled}";
          bar-used-width = "6";
          bar-used-gradient = false;
          bar-used-indicator = "$\{bar.indicator}";
          bar-used-indicator-foreground = "${fg}";
          bar-used-fill = "$\{bar.fill}";
          bar-used-foreground-0 = "${fg}";
          bar-used-foreground-1 = "${fg}";
          bar-used-foreground-2 = "${fg}";
          bar-used-empty = "$\{bar.empty}";
          bar-used-empty-foreground = "${fg}";
        };
        "module/temperature2" = {
          type = "internal/temperature";
          thermal-zone = 0;
          warn-temperature = 70;
          format = "<ramp> <label>";
          format-warn = "<ramp> <label-warn>";
          format-padding = 1;
          label = "%temperature%";
          label-warn = "%temperature%";
          ramp-0 = "󰜗";
          ramp-font = 3;
          ramp-foreground = "#a4ebf3";
        };
        "module/temperature" = {
          type = "internal/temperature";
          # ; Seconds to sleep between updates
          # ; Default: 1
          interval = "0.5";
          # ; Thermal zone to use
          # ; To list all the zone types, run
          # ; $ for i in /sys/class/thermal/thermal_zone*; do echo "$i: $(<$i/type)"; done
          # ; Default: 0
          thermal-zone = "0";
          # ; Full path of temperature sysfs path
          # ; Use `sensors` to find preferred temperature source, then run
          # ; $ for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
          # ; to find path to desired file
          # ; Default reverts to thermal zone setting
          hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input";
          # ; Base temperature for where to start the ramp (in degrees celsius)
          # ; Default: 0
          base-temperature = 20;
          # ; Threshold temperature to display warning label (in degrees celsius)
          # ; Default: 80
          warn-temperature = 60;
          # ; Whether or not to show units next to the temperature tokens (°C, °F)
          # ; Default: true
          units = false;
          # ; Available tags:
          # ;   <label> (default)
          # ;   <ramp>
          format = "<ramp> <label>";
          # ; Available tags:
          # ;   <label-warn> (default)
          # ;   <ramp>
          format-warn = "<ramp> <label-warn>";
          # ; Available tokens:
          # ;   %temperature% (deprecated)
          # ;   %temperature-c%   (default, temperature in °C)
          # ;   %temperature-f%   (temperature in °F)
          label = "TEMP %temperature-c%";
          # ; Available tokens:
          # ;   %temperature% (deprecated)
          # ;   %temperature-c%   (default, temperature in °C)
          # ;   %temperature-f%   (temperature in °F)
          label-warn = "TEMP %temperature-c%";
          label-warn-foreground = "${red}";
          # ; Requires the <ramp> tag
          # ; The icon selection will range from `base-temperature` to `warn-temperature`,
          # ; temperatures at and above `warn-temperature` will use the last icon
          # ; and temperatures at and below `base-temperature` will use `ramp-0`.
          # ; All other icons are distributed evenly between the two temperatures.
          ramp-0 = "A";
          ramp-1 = "B";
          ramp-2 = "C";
          ramp-foreground = "";
        };
        "module/network" = {
          type = "internal/network";
          interface = "wlan0";
          interval = "3.0";
          accumulate-stats = true;
          unknown-as-up = true;
          format-connected = "<label-connected>";
          format-connected-prefix = "";
          format-connected-background = "${mb}";
          format-connected-foreground = "${green}";
          speed-unit = "";
          label-connected = " %{A1:def-nmdmenu &:}%essid%%{A}";
          label-connected-background = "${mb}";
          label-connected-foreground = "${fg}";
          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "󰌙";
          format-disconnected-background = "${mb}";
          format-disconnected-foreground = "${red}";
          label-disconnected = " not connected";
          label-disconnected-foreground = "${red}";
        };
        "module/audio" = {
          type = "internal/alsa";
          use-ui-max = true;
          interval = 2;
          format-volume = "<ramp-volume><label-volume>";
          format-volume-prefix = "";
          format-volume-background = "${mb}";
          format-volume-foreground = " ${purple}";
          label-volume = " %percentage%%";
          label-volume-background = "${mb}";
          label-volume-foreground = "${fg}";
          format-muted = "<label-muted>";
          format-muted-prefix = "";
          format-muted-foreground = "${red}";
          format-muted-background = "${mb}";
          label-muted = " Muted";
          label-muted-foreground = "${red}";
          label-muted-background = "${mb}";
          ramp-volume-0 = "󰕿";
          ramp-volume-1 = "󰖀";
          ramp-volume-2 = "󰕾";
          ramp-volume-3 = "󰕾";
          ramp-volume-4 = "󱄡";
          ramp-volume-font = 4;
          click-right = "bspc rule -a Pavucontrol -o state=floating follow=on center=true && ${pkgs.pavucontrol}/bin/pavucontrol";
        };
        "module/bspwm" = {
          type = "internal/bspwm";
          enable-click = true;
          enable-scroll = true;
          reverse-scroll = true;
          pin-workspaces = true;
          occupied-scroll = false;
          background = "${pallete}";
          format = "%{T4}<label-state>%{T-}";
          format-background = ''$'{self."${bg}"}'';
          format-prefix = "$\{default.triangle-left}";
          format-prefix-foreground = ''$'{self."${bg}"}'';
          format-prefix-background = ''$'{root."${bg}"}'';
          format-suffix = "$\{default.triangle-right}";
          format-suffix-background = ''$'{root."${bg}"}'';
          format-suffix-foreground = ''$'{self."${bg}"}'';
          label-focused = "󰮯";
          label-focused-background = "${mb}";
          label-focused-padding = 1;
          label-focused-foreground = "${yellow}";
          label-occupied = "󰊠";
          label-occupied-padding = 1;
          label-occupied-background = "${mb}";
          label-occupied-foreground = "${blue}";
          label-urgent = "%icon%";
          label-urgent-padding = 0;
          label-empty = "󰑊";
          label-empty-foreground = "${purple}";
          label-empty-padding = 1;
          label-empty-background = "${mb}";
        };
      };
      extraConfig = ''
        ### Decor.ini

        [module/round-left]
        type = "custom/text"
        content = "%{T3}%{T-}"
        # content = "%{T3}%{T-}";
        content-foreground = #2E4374

        [module/round-right]
        type = "custom/text"
        content = "%{T5}%{T-}"
        # content = "%{T3}%{T-}";
        content-foreground = #2E4374

        [module/bi]
        type                        = custom/text
        content                     = "%{T5}%{T-}"
        content-foreground          = ${mb}
        content-background          = ${bg}

        ## bylo mb bg

        [module/bd]
        type                        = custom/text
        content                     = "%{T5}%{T-}"
        content-foreground          = ${mb}
        content-background          = ${bg}

        [module/spacing]
        type = custom/text
        content = " "
        content-background = ${bg}

        [module/sep]
        type = custom/text
        ;content = 
        content = " "

        content-font = 5
        content-background = ${bg}
        content-foreground = ${bg-alt}
        content-padding = 2

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        [module/LD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-background = ${bg}
        content-foreground = ${blue}

        [module/RD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-background = ${black}
        content-foreground = ${blue}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        [module/RLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${red}

        [module/BRLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${red}

        [module/RRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${red}

        [module/BRRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${red}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        [module/WLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${white}

        [module/WRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${white}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_


        [module/CLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${aqua}

        [module/CRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${aqua}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_


        [module/MLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${purple}

        [module/MRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${purple}

        [module/BMLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${purple}

        [module/BMRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${purple}


        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_


        [module/YLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${yellow}

        [module/YRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${yellow}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        [module/OLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${orange}

        [module/BOLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${orange}

        [module/ORD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${orange}

        [module/BORD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${orange}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        [module/PLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${pink}

        [module/BPLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${pink}

        [module/PRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${pink}

        [module/BPRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${pink}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_


        [module/GLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${green}

        [module/BGLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${green}

        [module/GRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${green}

        [module/BGRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${green}


        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        [module/BLD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${black}

        [module/BRD]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${bg}
        content-foreground = ${black}

        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        [module/YPL]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${black}

        [module/CPL]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${black}

        [module/GPL]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${black}
        content-foreground = ${black}

        [module/RPL]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${red}
        content-foreground = ${red}

        [module/MPL]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${green}
        content-foreground = ${red}

        [module/GMPL]
        type = custom/text
        content = "%{T3}%{T-}"
        content-font = 3
        content-background = ${red}
        content-foreground = ${green}
        ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
      '';
    };
  };
}
