{ pkgs, config, lib ? pkgs.lib, username, hostname, ... }:
let
  nixgl = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
  vars = import ../vars.nix { inherit pkgs config hostname; };

  hwmonPath = "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp1_input";

  polybar-custom = (pkgs.polybar.override {
    pulseSupport = true;
    nlSupport = true;
  });

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

  # dracula theme
  # standard colours
  # bg = "#282a36";
  # bg-alt = "#44475a";
  # fg = "#f8f8f2";
  # fg-alt = "#6272a4";
  # blue = "#6272a4";
  # cyan = "#8be9fd";
  # green = "#50fa7b";
  # orange = "#ffb86c";
  # pink = "#ff79c6";
  # purple = "#bd93f9";
  # red = "#ff5555";
  # yellow = "#f1fa8c";

  # xresources colours
  # color0 = "#000000";
  # color8 = "#4d4d4d";
  # color1 = "#ff5555";
  # color9 = "#ff6e67";
  # color2 = "#50fa7b";
  # color10 = "#5af78e";
  # color3 = "#f1fa8c";
  # color11 = "#f4f99d";
  # color4 = "#bd93f9";
  # color12 = "#caa9fa";
  # color5 = "#ff79c6";
  # color13 = "#ff92d0";
  # color6 = "#8be9fd";
  # color14 = "#9aedfe";
  # color7 = "#bfbfbf";
  # color15 = "#e6e6e6";

  # one-dark theme
  # bg = "#282c34";
  # bg-alt = "#21242b";
  # base0 = "#1B2229";
  # base1 = "#1c1f24";
  # base2 = "#202328";
  # base3 = "#23272e";
  # base4 = "#3f444a";
  # base5 = "#5B6268";
  # base6 = "#73797e";
  # base7 = "#9ca0a4";
  # base8 = "#DFDFDF";
  # fg = "#bbc2cf";
  # fg-alt = "#5B6268";
  # grey = base4;
  # red = "#ff6c6b";
  # orange = "#da8548";
  # green = "#98be65";
  # teal = "#4db5bd";
  # yellow = "#ECBE7B";
  # blue = "#51afef";
  # dark-blue = "#2257A0";
  # magenta = "#c678dd";
  # violet = "#a9a1e1";
  # cyan = "#46D9FF";
  # dark-cyan = "#5699AF";

  ##################
  ### Colors.ini ###
  ##################

  # bg = #1A1B26
  # fg = #F1F1F1
  # mb = #222330

  # red = #f7768e
  # pink = #FF0677
  # purple = #583794
  # blue = #7aa2f7
  # blue-arch = #0A9CF5
  # cyan = #7dcfff
  # teal = #00B19F
  # green = #9ece6a
  # lime = #B9C244
  # yellow = #e0af68
  # amber = #FBC02D
  # orange = #E57C46
  # brown = #AC8476
  # grey = #8C8C8C
  # indigo = #6C77BB
  # blue-gray = #6D8895

in

{
  home = {
    packages = with pkgs; [
      # Packages for scripts
      wmctrl
      # fonts
      maple-mono
      font-awesome
      meslo-lgs-nf
      maple-mono-SC-NF
      unstable.sarasa-gothic
    ];
    file = {
      "/home/${username}/.config/polybar/scripts/polywins" = {
        executable = true;
        text = builtins.readFile ../../../config/polybar/scripts/polywins;
        # text = builtins.readFile ../../../config/polybar/scripts/polywins2;
      };
      # "/home/${username}/.config/rofi/scripts/powermenu" = {
      #   executable = true;
      #   text = builtins.readFile ../../../config/rofi/scripts/powermenu.sh;
      # };
      # "/home/${username}/.config/rofi/themes/powermenu.rasi" = {
      #   text = builtins.readFile ../../../config/rofi/everforest/powermenu.rasi;
      # };
      # "/home/${username}/.config/rofi/images" = {
      #   recursive = true;
      #   source = ../../../config/rofi/everforest/images;
      # };
      # "/home/${username}/.config/rofi/scripts/promptmenu" = {
      #   executable = true;
      #   text = builtins.readFile ../../../config/rofi/scripts/promptmenu.sh;
      # };
    };
  };
  services = {
    polybar = {
      enable = true;
      package = polybar-custom;
      script = "";
      settings = {
        ##################
        ### Config.ini ###
        ##################
        "global/wm" = {
          margin-bottom = 0;
          margin-top = 0;
        };

        "colors" = {
          ### Colors
          # ;; Dark Add FC at the beginning #FC1E1F29 for 99 transparency
          bg = "#2D353B";
          bg-alt = "#1e1e2e";
          fg = "#d3c6aa"; # "#c5c9c5"
          # fg = "#c5c9c5";
          mb = "#2D353B"; #"#242121"
          # mb = "#242121";

          weather = "#f1fa8c";

          trans = "#00000000";
          white = "#FFFFFF";
          black = "#000000";

          blue-arch = "#0A9CF5";
          blue-indigo = "#2E4374";
          amber = "#FBC02D";
          sapphire = "#74c7ec";
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          # pink = "#f5c2e7";
          mauve = "#cba6f7";

          red = "#E67E80";
          orange = "#E69875";
          yellow = "#DBBC7F";
          green = "#A7C080";
          aqua = "#83C092";
          # blue = "#7FBBB3";
          blue = "#7aa2f7";
          teal = "#94e2d5";
          lavender = "#b4befe";
          purple = "#D699B6";
          purple-1 = "#938AA9";
          pink = "#EC407A";
          # cyan = "#79E6F3";
          cyan = "#7dcfff";
          lime = "#B9C244";
          brown = "#AC8476";
          grey = "#8C8C8C";
          indigo = "#6C77BB";
          blue-gray = "#6D8895";
          sky = "#89dceb";
          blue-bright = "#5755FE";
          pallete = "#D83F31";
        };

        "default" = {
          module-foreground = "$\{colors.indigo}";
          module-background = "$\{colors.red}";

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
          font-0 = with vars.everforest-0; "${ftname};${toString offset}";
          font-1 = with vars.everforest-1; "${ftname};${toString offset}";
          font-2 = with vars.everforest-2; "${ftname};${toString offset}";
          font-3 = with vars.everforest-3; "${ftname};${toString offset}";
          font-4 = with vars.everforest-4; "${ftname};${toString offset}";
          font-5 = with vars.everforest-5; "${ftname};${toString offset}";
          font-6 = with vars.everforest-6; "${ftname};${toString offset}";

        };

        "bar/everforest" = {
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
          # offset-x = "1%";
          offset-y = "0.1%";

          background = "$\{colors.bg}";
          foreground = "$\{colors.fg}";

          radius = "4.0";

          line-size = 2;
          line-color = "$\{colors.blue}";

          border-size = "2px"; # "1.4px";
          border-color = "$\{colors.bg}";

          padding = "0.2";
          # padding-right = 1;

          module-margin-left = 0;
          module-margin-right = 0;

          font-0 = with vars.everforest-0; "${ftname};${toString offset}";
          font-1 = with vars.everforest-1; "${ftname};${toString offset}";
          font-2 = with vars.everforest-2; "${ftname};${toString offset}";
          font-3 = with vars.everforest-3; "${ftname};${toString offset}";
          font-4 = with vars.everforest-4; "${ftname};${toString offset}";
          font-5 = with vars.everforest-5; "${ftname};${toString offset}";
          font-6 = with vars.everforest-6; "${ftname};${toString offset}";

          modules-left = "launcher bspwm polywins";
          modules-center = "title";
          # ; modules-right = sep network blok2 weather blok audio blok memory_bar blok battery blok date blok powermenu sep;
          # modules-right = sep weather blok audio blok memory_bar blok cpu_bar blok date blok powermenu sep pulseaudio-control-output
          modules-right = "filesystem sep bluetooth sep pulseaudio-control-output sep date brightness sep battery sep powermenu";

          spacing = 0;
          # separator =
          dim-value = 1.0;

          locale = "pt_BR.UTF-8";

          # tray-position = "none";
          # tray-detached = false;
          # tray-maxsize = 16;
          # tray-background = "${sapphire}";
          # tray-offset-x = 0;
          # tray-offset-y = 0;
          # tray-padding = 9;
          # tray-scale = 1.0;

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
          battery = if (hostname == "nitro") then "BAT1" else "BAT0";
          graphics_card = "intel_backlight";
          network_interface = if (hostname == "nitro") then ("enp7s0f1") else ("wlan0");
        };
        ###################
        ### Modules.ini ###
        ###################
        # "module/polypomo" =
        #   let
        #     polypomo = pkgs.writeShellScriptBin "polypomo"
        #       ''
        #         ${builtins.readFile ../../../config/polybar/scripts/polypomo}
        #       '';
        #   in
        #   {
        #     type = "custom/script";
        #     exec = "${polypomo}/bin/polypomo";
        #     tail = true;
        #     label = "%output%";
        #     click-left = "${polypomo}/bin/polypomo toggle";
        #     click-right = "${polypomo}/bin/polypomo end";
        #     click-middle = "${polypomo}/bin/polypomo lock";
        #     scroll-up = "${polypomo}/bin/polypomo time +60";
        #     scroll-down = "${polypomo}/bin/polypomo time -60";
        #   };
        # https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/player-mpris-tail
        "module/mpris" = {
          type = "custom/script";
          exec = "${player-mpris-tail}/bin/player-mpris-tail";
          tail = true;
        };
        "module/pulseaudio-control-output" = {
          type = "custom/script";
          tail = true;
          # exec = ''
          #   ${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --icons-volume " , " --icon-muted " " --node-nicknames-from "device.description" --node-nickname "alsa_output.pci-0000_00_1b.0.analog-stereo:  Speakers" --node-nickname "alsa_output.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo:  Headphones" listen
          # '';
          exec = ''
            ${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --icons-volume " , " --icon-muted " " --node-nicknames-from "device.description" --node-nickname "alsa_output.pci-0000_00_1b.0.analog-stereo:  Speakers" --node-nickname "alsa_output.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo:  Headphones" listen
          '';
          click-right = "pavucontrol &";
          click-middle = ''${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --node-blacklist "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2" next-node'';
          click-left = ''${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --node-type input togmute'';
          scroll-up = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --volume-max 150 up";
          scroll-down = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --volume-max 150 down";
          label-foreground = "$\{colors.fg}";
        };
        "module/pulseaudio-control-input" = {
          type = "custom/script";
          tail = true;
          format = "$\{colors.cyan}";
          # format-underline = "$\{colors.cyan}";
          # label-padding = 2;
          label-foreground = "$\{colors.fg}";

          # Use --node-blacklist to remove the unwanted PulseAudio .monitor that are child of sinks
          exec = ''${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control  --node-type input --icons-volume "" --icon-muted "" --node-nickname "alsa_output.pci-0000_0c_00.3.analog-stereo:  Webcam" --node-nickname "alsa_output.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo:  Headphones" --node-blacklist "*.monitor" listen'';
          click-right = "exec pavucontrol &";
          click-left = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --node-type input togmute";
          click-middle = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --node-type input next-node";
          scroll-up = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --node-type input --volume-max 130 up";
          scroll-down = "${pkgs.unstable.polybar-pulseaudio-control}/bin/pulseaudio-control --node-type input --volume-max 130 down";
        };
        "module/polywins" = {
          type = "custom/script";
          exec = "/home/${username}/.config/polybar/scripts/polywins";
          # exec = "${pkgs.polywins}/bin/polywins eDP-1";
          format = "<label>";
          format-background = "$\{colors.blue-indigo}";
          label = "%output%";
          label-padding = 1;
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
          format-full-prefix-foreground = "$\{colors.fg}";
          format-full-prefix-background = "$\{colors.mb}";

          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";
          label-full = "%percentage%%";

          label-charging-background = "$\{colors.mb}";
          label-discharging-background = "$\{colors.mb}";
          label-full-background = "$\{colors.mb}";

          label-charging-foreground = "$\{colors.fg}";
          label-discharging-foreground = "$\{colors.fg}";
          label-full-foreground = "$\{colors.fg}";

          ramp-capacity-0 = " ";
          ramp-capacity-1 = " ";
          ramp-capacity-2 = " ";
          ramp-capacity-3 = " ";
          ramp-capacity-4 = " ";
          ramp-capacity-font = 2;
          ramp-capacity-foreground = "$\{colors.green}";
          ramp-capacity-background = "$\{colors.mb}";

          animation-charging-0 = " ";
          animation-charging-1 = " ";
          animation-charging-2 = " ";
          animation-charging-3 = " ";
          animation-charging-4 = " ";
          animation-charging-font = 2;
          animation-charging-foreground = "$\{colors.orange}";
          animation-charging-background = "$\{colors.mb}";
          animation-charging-framerate = "750;";
        };
        "module/date" = {
          type = "internal/date";
          interval = "1.0";
          time = "%H:%M:%S";
          format-background = "$\{colors.mb}";
          format-foreground = "$\{colors.fg}";
          date-alt = " %A, %d %B %Y";
          format = "<label>";
          format-prefix = "";
          format-prefix-background = "$\{colors.mb}";
          format-prefix-foreground = "$\{colors.amber}";
          label = "%date% %time%";
          # label-font = 1;
        };
        "module/tray" = {
          type = "internal/tray";
          format = "<tray>";
          format-background = "$\{colors.bg}";
          tray-background = "$\{colors.bg}";
          tray-foreground = "$\{colors.fg}";
          tray-spacing = "8px";
          tray-padding = "0px";
          tray-size = "63%";
        };
        "module/filesystem" = {
          type = "internal/fs";
          mount-0 = "/";
          interval = "60";
          # ; fixed-values = true;
          fixed-values = false;
          format-mounted = "<label-mounted>";
          format-mounted-prefix = "󰋊 ";
          format-mounted-prefix-background = "$\{colors.mb}";
          format-mounted-prefix-foreground = "$\{colors.purple-1}";
          format-unmounted = "<label-unmounted>";
          format-unmounted-prefix = "󰋊 ";
          # ; label-mounted = "%used%";
          label-mounted = "%percentage_used%%";
          # ; label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%"
          label-mounted-background = "$\{colors.mb}";
          label-unmounted = "%mountpoint%: not mounted";
          label-unmounted-foreground = "$\{disabled}";
          bar-used-width = "6";
          bar-used-gradient = false;
          bar-used-indicator = "$\{bar.indicator}";
          bar-used-indicator-foreground = "$\{colors.fg}";
          bar-used-fill = "$\{bar.fill}";
          bar-used-foreground-0 = "$\{colors.fg}";
          bar-used-foreground-1 = "$\{colors.fg}";
          bar-used-foreground-2 = "$\{colors.fg}";
          bar-used-empty = "$\{bar.empty}";
          bar-used-empty-foreground = "$\{colors.fg}";
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
          hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp1_input";
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
          label-warn-foreground = "$\{colors.red}";
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
          format-connected-background = "$\{colors.mb}";
          format-connected-foreground = "$\{colors.green}";
          speed-unit = "";
          label-connected = " %{A1:def-nmdmenu &:}%essid%%{A}";
          label-connected-background = "$\{colors.mb}";
          label-connected-foreground = "$\{colors.fg}";
          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "󰌙";
          format-disconnected-background = "$\{colors.mb}";
          format-disconnected-foreground = "$\{colors.red}";
          label-disconnected = " not connected";
          label-disconnected-foreground = "$\{colors.red}";
        };
        "module/audio" = {
          type = "internal/alsa";
          use-ui-max = true;
          interval = 2;
          format-volume = "<ramp-volume><label-volume>";
          format-volume-prefix = "";
          format-volume-background = "$\{colors.mb}";
          format-volume-foreground = " $\{colors.purple}";
          label-volume = " %percentage%%";
          label-volume-background = "$\{colors.mb}";
          label-volume-foreground = "$\{colors.fg}";
          format-muted = "<label-muted>";
          format-muted-prefix = "";
          format-muted-foreground = "$\{colors.red}";
          format-muted-background = "$\{colors.mb}";
          label-muted = " Muted";
          label-muted-foreground = "$\{colors.red}";
          label-muted-background = "$\{colors.mb}";
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
          background = "$\{colors.pallete}";
          foreground = "$\{colors.indigo}";
          format = "%{T3}<label-state>%{T-}";
          format-background = "$\{self.$\{colors.bg}}";
          format-prefix = "$\{default.triangle-left}";
          format-prefix-foreground = "$\{self.$\{colors.bg}}";
          format-prefix-background = "$\{root.$\{colors.bg}}";
          format-suffix = "$\{default.triangle-right}";
          format-suffix-background = "$\{root.$\{colors.bg}}";
          format-suffix-foreground = "$\{self.$\{colors.bg}}";
          label-focused = "󰮯";
          label-focused-background = "$\{colors.mb}";
          label-focused-padding = 1;
          label-focused-foreground = "$\{colors.yellow}";
          label-occupied = "󰊠";
          label-occupied-padding = 1;
          label-occupied-background = "$\{colors.mb}";
          label-occupied-foreground = "$\{colors.pallete}";
          label-urgent = "%icon%";
          label-urgent-padding = 0;
          label-empty = "󰑊";
          label-empty-foreground = "$\{colors.purple}";
          label-empty-padding = 1;
          label-empty-background = "$\{colors.mb}";
        };
        "module/launcher" = {
          type = "custom/text";
          label = "  ";
          label-foreground = "$\{colors.blue-arch}";
          label-font = 4;
          click-left = "${config.programs.rofi.package}/bin/rofi -show drun -show-icons -theme $HOME/.config/rofi/configurations/Themes/Forest/launcher-polybar.rasi";
        };
        "module/blok2" = {
          type = "custom/text";
          format = " |";
          format-foreground = "$\{colors.fg}";
          format-background = "$\{colors.bg}";
        };
        "module/blok" = {
          type = "custom/text";
          format = " | ";
          format-foreground = "$\{colors.fg}";
          format-background = "$\{colors.bg}";
        };
        "module/nowplaying" = {
          type = "custom/script";
          tail = true;
          interval = 1;
          format = "󰫔 <label> "; # 󰷞 󰽴 󰽱 󱂵
          exec = ''${pkgs.playerctl}/bin/playerctl metadata --format "{{ artist }} - {{ title }}"'';
          label-maxlen = "20..";
        };
        "module/dots" = {
          type = "custom/text";
          content = " 󰇙 ";
          content-foreground = "$\{colors.purple}";
        };
        "module/title" = {
          type = "internal/xwindow";
          format = "<label>";
          format-foreground = "#99CEF0";
          label = "  %title%";
          label-maxlen = "20...";
        };
        "module/cpu_bar" = {
          type = "internal/cpu";
          interval = "0.5";
          format = "<label>";
          format-prefix = " "; #" "
          format-prefix-font = 2;
          format-prefix-background = "$\{colors.mb}";
          format-prefix-foreground = "$\{colors.red}";
          label = "%percentage%%";
          label-background = "$\{colors.mb}";
        };
        "module/memory_bar" = {
          type = "internal/memory";
          interval = 3;
          format = "<label>";
          format-prefix = " ";
          format-prefix-background = "$\{colors.mb}";
          format-prefix-foreground = "$\{colors.cyan}";
          label = "%used%";
          label-background = "$\{colors.mb}";
        };
        "module/mpd_control" = {
          type = "internal/mpd";
          host = "127.0.0.1";
          port = "6600";
          interval = 2;
          format-online = "<icon-prev><toggle><icon-next>";
          format-offline = "<label-offline>";
          label-offline = "󰝛 No music";
          icon-play = " %{T3} ";
          icon-pause = " %{T3} ";
          icon-stop = " %{T3} ";
          icon-prev = "%{T3} ";
          icon-next = " %{T3}";
          format-offline-background = "$\{colors.mb}";
          format-offline-foreground = "$\{colors.grey}";
          icon-play-background = "$\{colors.mb}";
          icon-pause-background = "$\{colors.mb}";
          icon-stop-background = "$\{colors.mb}";
          icon-prev-background = "$\{colors.mb}";
          icon-next-background = "$\{colors.mb}";
          icon-repeat-background = "$\{colors.mb}";
          icon-play-foreground = "$\{colors.green}";
          icon-pause-foreground = "$\{colors.green}";
          icon-stop-foreground = "$\{colors.green}";
          icon-prev-foreground = "$\{colors.sky}";
          icon-next-foreground = "$\{colors.sky}";
          toggle-on-foreground = "$\{colors.green}";
          toggle-off-foreground = "$\{colors.red}";
        };
        "module/mpd" = {
          type = "internal/mpd";
          host = "127.0.0.1";
          port = "6600";
          interval = 2;
          format-online = ''<icon-repeat> %{F#9ece6a}[%{F-} %{A1:bspc rule -a org.wezfurlong.wezterm -o state=floating follow=on center=true && wezterm start -- " ${pkgs.ncmpcpp}/bin/ncmpcpp ":}<label-song>%{A} %{F#9ece6a}]%{F-}'';
          format-offline = "";
          label-song = "%title%";
          label-song-maxlen = 21;
          icon-repeat = "";
          icon-repeat-background = "$\{colors.bg}";
          toggle-on-foreground = "$\{colors.green}";
          toggle-off-foreground = "$\{colors.red}";
        };
        "module/powermenu" = {
          type = "custom/text";
          content = "⏻ ";
          content-background = "$\{colors.mb}";
          content-foreground = "$\{colors.red}";
          click-left = "~/.config/rofi/configurations/scripts/powermenu.sh";
          # click-right = "~/.config/rofi/scripts/powermenu";
          # click-left = "${pkgs.powermenu}/bin/powermenu";
          # click-right = "${pkgs.powermenu}/bin/powermenu";
        };
        # "module/weather" = {
        #   type = "custom/script";
        #   exec = "~/.config/polybar/scripts/weather-plugin";
        #   tail = false;
        #   interval = 960;
        # };
        "module/weather" = {
          type = "custom/script";
          exec =
            let
              weather-binary = pkgs.writeShellScriptBin "weather-binary" ''
                #!/usr/bin/env bash
                ${pkgs.curlMinimal}/bin/curl -s wttr.in/$(${pkgs.curlMinimal}/bin/curl -s https://ipapi.co/$(${pkgs.curlMinimal}/bin/curl -s ipinfo.io/ip)/json | ${pkgs.jq}/bin/jq '.["city"]' | sed 's/"//g')?\&format=1 | sed 's/\s\+/ /' | sed 's/+//'
              '';
            in
            "${weather-binary}/bin/weather-binary";
          # ; 30 minutes
          interval = 1800;
        };
        "module/cava" = {
          type = "custom/script";
          tail = true;
          exec = "${pkgs.cava-polybar}/bin/cava-polybar";
          format = "<label>";
          format-font = 5;
          label = "%output%";
        };
        "module/brightness" = {
          type = "internal/backlight";
          card = "intel_backlight";
          enable-scroll = true;
          format = "<ramp><label>";
          label = "%percentage%% ";
          ramp-0 = "󰃚";
          ramp-1 = "󰃚";
          ramp-2 = "󰃝";
          ramp-3 = "󰃝";
          ramp-4 = "󰃟";
          ramp-5 = "󰃟";
          ramp-6 = "󰃠";
          ramp-7 = "󰃠";
          ramp-font = 2;
          ramp-padding = "3pt";
          ramp-foreground = "$\{colors.yellow}";
        };
        "module/bluetooth" = {
          type = "custom/text";
          content = "";
          content-background = "$\{colors.bg}";
          content-foreground = "$\{colors.blue-arch}";
          exec = "${pkgs.rofi-bluetooth}/bin/rofi-bluetooth --status";
          interval = 1;
          click-left = "${pkgs.rofi-bluetooth}/bin/rofi-bluetooth";
        };

        #################
        ### Decor.ini ###
        #################

        "module/round-left" = {
          type = "custom/text";
          content = "%{T5}%{T-}";
          # content = "%{T3}%{T-}";
          content-foreground = "$\{colors.blue-indigo}";
        };
        "module/round-right" = {
          type = "custom/text";
          content = "%{T5}%{T-}";
          # content = "%{T3}%{T-}";
          content-foreground = "$\{colors.blue-indigo}";
        };
        "module/round-left2" = {
          type = "custom/text";
          content = "%{T6}%{T-}";
          # content = "%{T3}%{T-}";
          content-foreground = "$\{colors.blue-bright}";
        };
        "module/round-right2" = {
          type = "custom/text";
          content = "%{T6}%{T-}";
          # content = "%{T3}%{T-}";
          content-foreground = "$\{colors.blue-bright}";
        };
        "module/bi" = {
          type = "custom/text";
          content = "%{T4}%{T-}";
          content-foreground = "$\{colors.mb}";
          content-background = "$\{colors.bg}";
        };
        "module/bd" = {
          type = "custom/text";
          content = "%{ T4 }%{T-}";
          content-foreground = "$\{colors.mb}";
          content-background = "$\{colors.bg}";
        };
        "module/spacing" = {
          type = "custom/text";
          content = " ";
          content-background = "$\{colors.bg}";
        };
        "module/sep" = {
          type = "custom/text";
          label = " ";
          label-foreground = "$\{colors.bg}";
        };
      };
    };
  };
}
