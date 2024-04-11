{ pkgs, config, lib ? pkgs.lib, username, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  vars = import ./vars.nix { inherit pkgs config; };


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
  alpha = "#0000ffff";
  bg = "#960000";
  bg1 = "#141a21";
  bg2 = "#081F2D";
  fg = "#D3EBE9";
  fg1 = "#D3EBE9";
  shade2 = "#720e9e";
  shade3 = "#FF033E";
  shade7 = "#FF03A3";

  # for 50% transparent
  trans1 = "#80000000";
  # for 100% transparent
  trans2 = "#00";

  black = "#0A0F14";
  red = "#C33027";
  green = "#26A98B";
  yellow = "#EDB54B";
  blue = "#33859D";
  purple = "#888BA5";
  indigo = "#093748";
  indigoLight = "#195465";
  cyan = "#91D1CE";
  white = "#ECEFF4";
  teal = "#599CAA";
  gray = "#4E5165";
in

{
  home = {
    packages = with pkgs; [
      # Packages for scripts
      wmctrl
    ];
    file = {
      "/home/${username}/.config/polybar/scripts/polywins" = {
        executable = true;
        text = builtins.readFile ../../config/polybar/scripts/polywins;
      };
      "/home/${username}/.config/rofi/scripts/powermenu" = {
        executable = true;
        text = builtins.readFile ../../config/rofi/scripts/powermenu.sh;
      };
      "/home/${username}/.config/rofi/scripts/promptmenu" = {
        executable = true;
        text = builtins.readFile ../../config/rofi/scripts/promptmenu.sh;
      };
    };
  };
  services = {
    polybar = {
      enable = true;
      package = nixgl pkgs.polybarFull;
      script = "";
      settings = {
        ##################
        ### Config.ini ###
        ##################
        "global/wm" = {
          margin-bottom = 0;
          margin-top = 0;
        };
        "bar/batman" = {
          # monitor = "";
          # monitor-fallback = "";
          monitor-strict = false;
          # monitor-exact = true;

          override-redirect = false;

          bottom = false;
          fixed-center = true;

          width = "100%";
          height = 20;

          offset-x = "0%";
          offset-y = "0%";

          background = "${bg}";
          foreground = "${fg}";

          radius-top = "0.0";
          radius-bottom = "0.0";

          underline-size = 1;
          underline-color = "${fg}";

          border-size = 0;
          border-top-size = 2;
          border-botto0-size = 2;
          border-color = "${bg}";

          padding-left = 1;
          padding-top = 2;

          module-margin-left = 0;
          module-margin-right = 0;

          font-0 = with vars.batman-0; "${ftname};${toString offset}";
          font-1 = with vars.batman-1; "${ftname};${toString offset}";
          font-2 = with vars.batman-2; "${ftname};${toString offset}";
          font-3 = with vars.batman-3; "${ftname};${toString offset}";
          font-4 = with vars.batman-4; "${ftname};${toString offset}";
          font-5 = with vars.batman-5; "${ftname};${toString offset}";
          font-6 = with vars.batman-6; "${ftname};${toString offset}";


          modules-left = "arch sep left workspaces right sepr left title right sepr left backlight battery temperature right";
          modules-center = "sepr left date right sepr";
          modules-right = "left memory right sepr left cpu right sepr left net right sepr left network right sepr left vol right sep left alsa right";

          # separator =
          dim-value = 1.0;

          locale = "pt_BR.UTF-8";

          tray-position = "right";
          tray-detached = false;
          tray-maxsize = 12;
          tray-background = "${bg}";
          tray-offset-x = 0;
          tray-offset-y = 0;
          tray-padding = 9;
          tray-scale = 1.0;

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };
        "settings" = {
          throttle-output = 5;
          throttle-output-for = 10;
          screenchange-reload = false;
          compositing-background = "source";
          compositing-foreground = "over";
          compositing-overline = "over";
          compositing-underline = "over";
          compositing-border = "over";
          pseudo-transparency = false;
        };
        ###################
        ### Modules.ini ###
        ###################
        "module/alsa" = {
          type = "internal/alsa";
          master-soundcard = "default";
          speaker-soundcard = "default";
          headphone-soundcard = "default";
          master-mixer = "Master";
          interval = 5;
          format-volume = "<bar-volume>";
          format-volume-background = "${bg1}";
          format-volume-padding = 0;
          format-muted = "<label-muted>";
          format-muted-background = "${bg1}";
          format-muted-padding = 0;
          bar-volume-width = 10;
          bar-volume-foreground-0 = "${blue}";
          bar-volume-foreground-1 = "${blue}";
          bar-volume-foreground-2 = "${blue}";
          bar-volume-foreground-3 = "${blue}";
          bar-volume-foreground-4 = "${blue}";
          bar-volume-foreground-5 = "${yellow}";
          bar-volume-foreground-6 = "${yellow}";
          bar-volume-foreground-7 = "${yellow}";
          bar-volume-foreground-8 = "${red}";
          bar-volume-foreground-9 = "${red}";
          bar-volume-fill = "";
          bar-volume-fill-font = 1;
          bar-volume-fill-background = "${bg1}";
          bar-volume-empty = "";
          bar-volume-empty-font = 1;
          bar-volume-empty-foreground = "${bg}";
          bar-volume-empty-background = "${bg1}";
          bar-volume-indicator = "雷";
          bar-volume-indicator-foreground = "${cyan}";
          bar-volume-indicator-background = "${bg1}";
          bar-volume-indicator-font = 1;
          label-muted = "Muted";
          label-muted-foreground = "${fg}";
          label-muted-background = "${bg1}";
          ramp-volume-0 = "";
          ramp-volume-1 = "";
          ramp-volume-2 = "";
          ramp-volume-3 = "";
          ramp-volume-4 = "";
          ramp-volume-5 = "";
          ramp-volume-foreground = "${purple}";
          ramp-volume-background = "${bg1}";
          ramp-volume-font = 3;
        };
        "module/vol" = {
          type = "internal/alsa";
          master-soundcard = "default";
          speaker-soundcard = "default";
          headphone-soundcard = "default";
          master-mixer = "Master";
          interval = 5;
          format-volume = "<label-volume>";
          format-volume-background = "${bg1}";
          format-volume-padding = 0;
          format-muted = "<label-muted>";
          label-volume = "";
          label-volume-font = 3;
          label-volume-foreground = "${purple}";
          label-volume-background = "${bg1}";
          label-muted = "";
          label-muted-font = 3;
          label-muted-foreground = "${purple}";
          label-muted-background = "${bg1}";
          ramp-volume-0 = "";
          ramp-volume-1 = "";
          ramp-volume-2 = "";
          ramp-volume-3 = "";
          ramp-volume-4 = "";
          ramp-volume-5 = "";
          ramp-volume-foreground = "${purple}";
          ramp-volume-background = "${bg1}";
          ramp-volume-font = 3;
          ramp-headphones-0 = " ";
        };
        "module/backlight" = {
          type = "internal/backlight";
          card = "intel_backlight";
          enable-scroll = true;
          use-actual-brightness = true;
          format = "<ramp><label>";
          format-background = "${bg1}";
          format-padding = 0;
          label = " %percentage%% ";
          label-foreground = "${fg1}";
          label-background = "${bg1}";
          ramp-0 = "";
          ramp-1 = "";
          ramp-2 = "";
          ramp-3 = "";
          ramp-4 = "";
          ramp-foreground = "${blue}";
          ramp-background = "${bg1}";
          ramp-font = 3;
        };
        "module/battery" = {
          type = "internal/battery";
          full-at = 99;
          battery = "BAT0";
          adapter = "ACAD";
          poll-interval = 2;
          time-format = "%H:%M";
          format-charging = "<animation-charging><label-charging>";
          format-charging-prefix = "";
          format-charging-prefix-font = 3;
          format-charging-prefix-foreground = "${yellow}";
          format-charging-background = "${bg1}";
          format-discharging = "<label-discharging>";
          format-discharging-prefix = "";
          format-discharging-prefix-font = 3;
          format-discharging-prefix-foreground = "${red}";
          format-discharging-prefix-background = "${bg1}";
          format-discharging-background = "${bg1}";
          format-full = "<label-full>";
          format-full-prefix = "";
          format-full-prefix-font = 3;
          format-full-prefix-foreground = "${red}";
          format-full-background = "${bg1}";
          label-charging = "%percentage%% ";
          label-charging-foreground = "${fg}";
          label-charging-background = "${bg1}";
          label-discharging = " %percentage%% ";
          label-discharging-foreground = "${fg}";
          label-discharging-background = "${bg1}";
          label-full = " %percentage%% ";
          label-full-foreground = "${fg}";
          label-full-background = "${bg1}";
          ramp-capacity-0 = "  ";
          ramp-capacity-1 = "  ";
          ramp-capacity-2 = "  ";
          ramp-capacity-3 = "  ";
          ramp-capacity-4 = "  ";
          ramp-capacity-foreground = "${green}";
          ramp-capacity-background = "${bg1}";
          ramp-capacity-font = 7;
          animation-charging-0 = "  ";
          animation-charging-1 = "  ";
          animation-charging-2 = "  ";
          animation-charging-3 = "  ";
          animation-charging-4 = "  ";
          animation-charging-foreground = "${green}";
          animation-charging-background = "${bg1}";
          animation-charging-font = 7;
          animation-charging-framerate = 700;
        };
        "module/cpu" = {
          type = "internal/cpu";
          interval = 1;
          format = "<label>";
          format-prefix = "";
          format-prefix-font = 3;
          format-prefix-foreground = "${blue}";
          format-prefix-background = "${bg1}";
          format-padding = 0;
          label = " CPU %percentage%%";
          label-foreground = "${blue}";
          label-background = "${bg1}";
        };
        "module/date" = {
          type = "internal/date";
          interval = 1.0;
          date = " %a, %d %b %Y";
          time = " %I:%M %p";
          format = "<label>";
          format-prefix = "";
          format-prefix-font = 3;
          format-prefix-foreground = "${gray}";
          format-prefix-background = "${bg1}";
          format-background = "${bg1}";
          format-foreground = "${gray}";
          format-padding = 0;
          label = "%date% %time%";
        };
        "module/filesystem" = {
          type = "internal/fs";
          mount-0 = "/";
          interval = 30;
          fixed-values = true;
          format-mounted = "<label-mounted>";
          format-mounted-prefix = "";
          format-mounted-background = "${shade2}";
          format-mounted-padding = 2;
          format-unmounted = "<label-unmounted>";
          format-unmounted-prefix = "";
          format-unmounted-background = "${shade2}";
          format-unmounted-padding = 2;
          label-mounted = " %free%";
          label-unmounted = " %mountpoint%: not mounted";
        };
        "module/memory" = {
          type = "internal/memory";
          interval = 1;
          format = "<label>";
          format-prefix = " ";
          format-prefix-font = 8;
          format-prefix-foreground = "${indigoLight}";
          format-prefix-background = "${bg1}";
          format-background = "${bg1}";
          format-foreground = "${indigoLight}";
          format-padding = 0;
          label = " %mb_used%";
        };
        "module/mpd" = {
          type = "internal/mpd";
          interval = 2;
          format-online = "<label-song><icon-prev><toggle><icon-next>";
          format-online-foreground = "${fg}";
          format-online-background = "${bg1}";
          format-online-prefix = " ";
          format-online-prefix-font = 3;
          format-online-prefix-foreground = "${purple}";
          format-online-prefix-background = "${bg1}";
          format-playing = "$\{self.format-online}";
          format-paused = "$\{self.format-online}";
          format-stopped = "$\{self.format-online}";
          format-offline = "<label-offline>";
          format-offline-foreground = "${fg}";
          format-offline-background = "${bg1}";
          format-offline-prefix = "";
          format-offline-prefix-font = 3;
          format-offline-prefix-foreground = "${purple}";
          format-offline-prefix-background = "${bg1}";
          label-song = "%artist% - %title% ";
          label-song-foreground = "${fg}";
          label-song-background = "${bg1}";
          label-song-maxlen = 25;
          label-song-ellipsis = true;
          label-offline = " Offline";
          icon-play = "";
          icon-play-foreground = "${green}";
          icon-play-background = "${bg1}";
          icon-pause = "";
          icon-pause-foreground = "${green}";
          icon-pause-background = "${bg1}";
          icon-stop = "栗";
          icon-stop-foreground = "${green}";
          icon-stop-background = "${bg1}";
          icon-prev = "";
          icon-prev-foreground = "${blue}";
          icon-prev-background = "${bg1}";
          icon-next = " ";
          icon-next-foreground = "${blue}";
          icon-next-background = "${bg1}";
          toggle-on-foreground = "${fg}";
          toggle-off-foreground = "${fg}";
        };
        "module/wired-network" = {
          type = "internal/network";
          interface = "eth0";
          interval = 1.0;
          accumulate-stats = true;
          unknown-as-up = true;
          format-connected = "<ramp-signal> <label-connected>";
          format-connected-background = "${shade3}";
          format-connected-padding = 1;
          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "睊 ";
          format-disconnected-prefix-font = 1;
          format-disconnected-prefix-foreground = "${fg}";
          format-disconnected-foreground = "${fg}";
          format-disconnected-background = "${shade3}";
          format-disconnected-padding = 1;
          label-connected = "%{A1:${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu &:}%essid% %{A}";
          label-disconnected = "%{A1:${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu &:}Offline%{A}";
          ramp-signal-0 = "直";
          ramp-signal-1 = "直";
          ramp-signal-2 = "直";
          ramp-signal-foreground = "${fg}";
          ramp-signal-font = 1;
        };
        "module/wireless-network" = {
          type = "internal/network";
          interface = "wlan0";
          interval = 1.0;
          accumulate-stats = true;
          unknown-as-up = true;
          format-connected = "<ramp-signal> <label-connected>";
          format-connected-background = "${shade3}";
          format-connected-padding = 1;
          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "";
          format-disconnected-prefix-font = 1;
          format-disconnected-prefix-foreground = "${fg}";
          format-disconnected-foreground = "${fg}";
          format-disconnected-background = "${shade3}";
          format-disconnected-padding = 1;
          label-connected = "%{A1:${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu &:}%essid% %{A}";
          label-disconnected = "%{A1:${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu &:}Offline%{A}";
          ramp-signal-0 = "";
          ramp-signal-1 = "";
          ramp-signal-2 = "";
          ramp-signal-foreground = "${fg}";
          ramp-signal-font = 1;
        };
        "module/network" = {
          type = "internal/network";
          interface = "wlan0";
          interval = 1.0;
          accumulate-stats = true;
          unknown-as-up = true;
          format-connected = "<label-connected>";
          format-disconnected = "<label-disconnected>";
          label-connected = "%{A1:${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu &:}%essid%%{A}";
          label-connected-foreground = "${fg}";
          label-connected-background = "${bg1}";
          label-disconnected = "%{A1:${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu &:}Offline%{A}";
          label-disconnected-foreground = "${fg}";
          label-disconnected-background = "${bg1}";
          ramp-signal-0 = "";
          ramp-signal-1 = "";
          ramp-signal-2 = "";
          ramp-signal-foreground = "${fg}";
          ramp-signal-background = "${bg1}";
          ramp-signal-font = 3;
        };
        "module/net" = {
          type = "internal/network";
          interface = "wlan0";
          accumulate-stats = true;
          unknown-as-up = true;
          format-connected = "<ramp-signal>";
          format-disconnected = "<label-disconnected>";
          label-disconnected = "";
          label-disconnected-font = 3;
          label-disconnected-foreground = "${green}";
          label-disconnected-background = "${bg1}";
          ramp-signal-0 = "";
          ramp-signal-1 = "";
          ramp-signal-2 = "";
          ramp-signal-foreground = "${green}";
          ramp-signal-background = "${bg1}";
          ramp-signal-font = 3;
        };
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          # ; Sink to be used, if it exists (find using `pacmd list-sinks`, name field)
          # ; If not, uses default sink
          sink = "alsa_output.pci-0000_03_00.6.analog-stereo";
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
          format-volume = "<ramp-volume> <label-volume>";
          format-volume-background = "${shade3}";
          format-volume-padding = 1;
          # Available tags:
          # ;   <label-muted> (default)
          # ;   <ramp-volume>
          # ;   <bar-volume>
          format-muted = "<label-muted>";
          format-muted-prefix = "婢";
          format-muted-background = "${shade3}";
          format-muted-padding = 1;
          # ; Available tokens:
          # ;   %percentage% (default)
          label-volume = "%percentage%% ";
          # ; Available tokens:
          # ;   %percentage% (default
          label-muted = " Muted ";
          label-muted-foreground = "${fg}";

          # ; Only applies if <ramp-volume> is used
          ramp-volume-0 = "奄";
          ramp-volume-1 = "奔";
          ramp-volume-2 = "墳";

        };
        "module/temperature" = {
          type = "internal/temperature";
          # Seconds to sleep between updates
          # ; Default: 1
          interval = 0.5;
          # Thermal zone to use
          # ; To list all the zone types, run
          # ; $ for i in /sys/class/thermal/thermal_zone*; do echo "$i: $(<$i/type)"; done
          # ; Default: 0
          thermal-zone = 0;
          # Full path of temperature sysfs path
          # ; Use `sensors` to find preferred temperature source, then run
          # ; $ for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
          # ; to find path to desired file
          # ; Default reverts to thermal zone setting
          # ;;hwmon-path = /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input
          # ;
          hwmon-path = "/sys/devices/pci0000:00/0000:00:01.3/0000:01:00.0/hwmon/hwmon0/temp1_input";
          # Threshold temperature to display warning label (in degrees celsius)
          # ; Default: 80
          warn-temperature = 85;
          # Whether or not to show units next to the temperature tokens (°C, °F)
          # ; Default: true
          units = true;
          # Available tags:
          # ;   <label> (default)
          # ;   <ramp>
          # ;format = <ramp> <label>
          format = "<ramp><label>";
          format-prefix = "";
          format-prefix-font = 3;
          format-prefix-foreground = "${blue}";
          format-prefix-background = "${bg}";
          format-foreground = "${fg}";
          format-background = "${bg1}";
          format-padding = 1;
          # Available tags:
          # ;   <label-warn> (default)
          # ;   <ramp>
          # ;format-warn = "<ramp> <label-warn>";
          format-warn = "<ramp><label-warn>";
          format-warn-prefix = "";
          format-warn-prefix-font = 3;
          format-warn-prefix-foreground = "${blue}";
          format-warn-prefix-background = "${bg}";
          format-warn-background = "${bg1}";
          format-warn-foreground = "${red}";
          format-warn-padding = 1;
          # Available tokens:
          # ;   %temperature% (deprecated)
          # ;   %temperature-c%   (default, temperature in °C)
          # ;   %temperature-f%   (temperature in °F)
          label = " %temperature-c%";
          label-foreground = "${fg}";
          label-background = "${bg1}";
          # Available tokens:
          # ;   %temperature% (deprecated)
          # ;   %temperature-c%   (default, temperature in °C)
          # ;   %temperature-f%   (temperature in °F)
          label-warn = " %temperature-c%";
          label-warn-foreground = "${red}";
          label-warn-background = "${bg1}";
          # Requires the <ramp> tag
          # ; The icon selection will range from 0 to `warn-temperature`
          # ; with the current temperature as index.
          ramp-0 = "";
          ramp-0-foreground = "${cyan}";
          ramp-1 = "";
          ramp-1-foreground = "${cyan}";
          ramp-2 = "";
          ramp-2-foreground = "${cyan}";
          ramp-3 = "";
          ramp-3-foreground = "${yellow}";
          ramp-4 = "";
          ramp-4-foreground = "${red}";
          ramp-font = 3;
          ramp-background = "${bg1}";
        };
        "module/keyboard" = {
          type = "internal/xkeyboard";
          # ; List of indicators to ignore
          blacklist-0 = "num lock";
          blacklist-1 = "scroll lock";
          # ; Available tags:
          # ;   <label-layout> (default)
          # ;   <label-indicator> (default)
          format = "<label-layout> <label-indicator>";
          format-prefix = "";
          format-background = "${shade7}";
          format-padding = 1;
          # ; Available tokens:
          # ;   %layout%
          # ;   %name%
          # ;   %number%
          # ; Default: %layout%
          label-layout = " %layout%";
          # ; Available tokens:
          # ;   %name%
          # ; Default: %name%
          label-indicator-on = "%name%";
          label-indicator-on-foreground = "${fg}";
        };
        "module/title" = {
          type = "internal/xwindow";
          # Available tags:
          # ;   <label> (default)
          format = "<label>";
          format-prefix = "  ";
          format-prefix-font = 8;
          # format-prefix-foreground = "${gray}";
          format-prefix-background = "${bg1}";
          format-background = "${bg1}";
          format-foreground = "${fg1}";
          format-prefix-foreground = "${indigo}";
          format-padding = 0;
          # Available tokens:
          # ;   %title%
          # ; Default: %title%
          label = " %title%";
          label-maxlen = 30;
          # ; Used instead of label when there is no window title
          label-empty = " Juca's BSPWM";
          label-empty-foreground = "${fg1}";
          label-empty-background = "${bg1}";
        };
        "module/workspaces" = {
          type = "internal/xworkspaces";
          # Only show workspaces defined on the same output as the bar
          # ;
          # ; Useful if you want to show monitor specific workspaces
          # ; on different bars
          # ;
          # ; Default: false
          pin-workspaces = true;
          # Create click handler used to focus desktop
          # ; Default: true
          enable-click = true;
          # Create scroll handlers used to cycle desktops
          # ; Default: true
          enable-scroll = true;
          "icon-[0-9]+" = "<desktop-name>";
          # <icon>
          # ; NOTE: The desktop name needs to match the name configured by the WM
          # ; You can get a list of the defined desktops using:
          # ; $ xprop -root _NET_DESKTOP_NAMES
          icon-0 = "I;% {F#5E6483}";
          icon-1 = "II;% {F#5E6483}";
          icon-2 = "III;% {F#5E6483}";
          # ; icon-3 = 4;
          # ; icon-4 = 5;
          icon-default = " ";
          icon-font = 5;
          # Available tags:
          # ;   <label-monitor>
          # ;   <label-state> - gets replaced with <label-(active|urgent|occupied|empty)>
          # ; Default: <label-state>
          format = "<label-state>";
          format-padding = 0;
          format-background = "${yellow}";
          # Available tokens:
          # ;   %name%
          # ; Default: %name%
          label-monitor = "%name%";
          # Available tokens:
          # ;   %name%
          # ;   %icon%
          # ;   %index%
          # ; Default: %icon%  %name%
          # ;label-active = %icon%
          label-active = "  ";
          label-active-font = 8;
          label-active-underline = "${blue}";
          label-active-background = "${bg1}";
          label-active-foreground = "${yellow}";
          # ${color.foreground-alt}
          # ; Available tokens:
          # ;   %name%
          # ;   %icon%
          # ;   %index%
          # ; Default: %icon%  %name%
          label-occupied = "  ";
          # label-occupied = "  ";
          label-occupied-font = 8;
          label-occupied-foreground = "${green}";
          label-occupied-background = "${bg1}";
          # ${color.foreground-alt}
          # ; Available tokens:
          # ;   %name%
          # ;   %icon%
          # ;   %index%
          # ; Default: %icon%  %name%
          label-urgent = "  ";
          # ;label-urgent = %icon%
          label-urgent-font = 4;
          label-urgent-foreground = "${red}";
          label-urgent-background = "${bg1}";
          # ; Available tokens:
          # ;   %name%
          # ;   %icon%
          # ;   %index%
          # ; Default: %icon%  %name%
          # label-empty = "  ";
          # ;label-empty = "  ";
          # ;label-empty = "%icon%";
          label-empty-font = 8;
          label-empty-background = "${bg1}";
          label-empty-foreground = "${gray}";
          label-active-padding = 0;
          label-urgent-padding = 0;
          label-occupied-padding = 0;
          label-empty-padding = 0;
        };
        "module/bspwm" = {
          type = "internal/bspwm";
          format = "<label-state>";
          format-padding = 0;
          format-background = "${shade2}";
          pin-workspaces = false;
          inline-mode = false;
          enable-scroll = false;
          label-empty = "";
          # label-empty-foreground =
          label-focused = "";
          label-focused-underline = "${fg}";
          label-focused-foreground = "#ffffff";
          label-focused-padding = 1;
          label-occupied = "";
          label-occupied-underline = "${fg}";
          label-occupied-foreground = "#ffffff";
          label-occupied-padding = 1;
          label-urgent = "";
          label-urgent-foreground = "#ffffff";
          label-urgent-underline = "${fg}";
          label-urgent-padding = 1;
        };
        "module/sep" = {
          type = "custom/text";
          content = " ";
        };
        "module/sepr" = {
          type = "custom/text";
          content = "  ";
          content-foreground = "${bg1}";
          content-background = "${bg}";
        };
        "module/arch" = {
          type = "custom/text";
          content = "%{T5}   ";
          content-foreground = "${blue}";
          content-background = "${bg}";
        };
        "module/links" = {
          type = "custom/text";
          content-padding = 0;
        };
        "module/telegram" = {
          type = "custom/text";
          exec = "${pkgs.telegram-desktop}/bin/telegram-desktop";
          click-left = "${pkgs.telegram-desktop}/bin/telegram-desktop &";
          content = "  ";
          content-padding = 0;
          content-font = 7;
          # ;content-underline = "${blue}";
          content-foreground = "${yellow}";
          content-background = "${bg1}";
        };
        "module/google" = {
          "inherit" = "module/links";
          content = " ";
          content-padding = 0;
          content-font = 7;
          # ;content-underline = ${yellow}
          content-foreground = "${red}";
          content-background = "${bg1}";
          click-left = "${pkgs.xfce.exo}/bin/exo-open https://www.google.com/ &";
        };
        "module/github" = {
          "inherit" = "module/links";
          content = "  ";
          content-padding = 0;
          content-font = 7;
          # ;content-underline = ${color.green}
          content-foreground = "${green}";
          content-background = "${bg1}";
          click-left = "${pkgs.xfce.exo}/bin/exo-open https://www.github.com/ &";
        };
        "glyph" = {
          gleft = "";
          gright = "";
        };
        "module/left" = {
          type = "custom/text";
          # ;content-background = ${BG1}
          content-foreground = "${bg1}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left1" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${red}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left2" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${green}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left3" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${yellow}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left4" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${blue}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left5" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${purple}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left6" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${cyan}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left7" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${fg1}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/left8" = {
          type = "custom/text";
          # ;content-background = "${bg1}";
          content-foreground = "${indigo}";
          content = "$\{glyph.gleft}";
          content-font = 4;
        };
        "module/right" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${bg1}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right1" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${red}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right2" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${green}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right3" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${yellow}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right4" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${blue}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right5" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${purple}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right6" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${cyan}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right7" = {
          type = "custom/text";
          # ;content-background = ${color.BG1};
          content-foreground = "${fg1}";
          content = "$\{glyph.gright}";
          # ;content-padding = 20
          content-font = 4;
        };
        "module/right8" = {
          type = "custom/text";
          content-background = "${bg}";
          content-foreground = "${indigoLight}";
          content = "$\{glyph.gright}";
          content-font = 4;
        };
      };
    };
  };
}
