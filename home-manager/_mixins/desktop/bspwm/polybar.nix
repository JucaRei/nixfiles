{ pkgs, config, lib ? pkgs.lib, ... }:
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
  services = {
    polybar = {
      enable = true;
      package = nixgl pkgs.unstable.polybarFull;
      script = "polybar bar/pam1 &";
      settings = {
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

        # https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/player-mpris-tail
        "module/mpris" = {
          type = "custom/script";
          exec = "${player-mpris-tail}/bin/player-mpris-tail";
          tail = true;
        };
        ##################
        ### Config.ini ###
        ##################
        "global/wm" = {
          margin-bottom = 0;
          margin-top = 0;
        };

        "default" = {
          module-foreground = "${bg}";
          monitor = "";
          monitor-fallback = "";
          monitor-strict = false;

          override-redirect = false;
          fixed-center = true;

          width = "2.5%";
          height = 40;

          offset-x = "2%";
          offset-y = 10;

          background = "${bg-alt}";
          foreground = "${fg}";

          radius = 6;

          line-size = 2;
          line-color = "${blue}";

          padding = 0;

          module-margin-left = 0;
          module-margin-right = 0;

          # font-0 = "${pkgs.iosevka}/share/fonts/truetype/Iosevka-Regular.ttf";
          font-0 = with fonts.polybar-0; "${ftname};${toString offset}";
          font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
          font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
          font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
          font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
          font-5 = with fonts.polybar-5; "${ftname};${toString offset}";

          modules-left = "";
          modules-center = "xdomenu";
          modules-right = "";

          separator = "";
          dim-value = "1.0";

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };

        ## ----------------------------------  [bar/pam2] ---------------------------------- ##

        "bar/pam2" = {
          monitor = "";
          monitor-fallback = "";
          monitor-strict = false;

          override-redirect = false;

          bottom = false;
          fixed-center = true;

          width = "17%";
          height = 40;

          offset-x = "5%";
          offset-y = 10;

          background = "${bg-alt}";
          foreground = "${fg}";

          radius = 6;

          line-size = 2;
          line-color = "${blue}";

          border-size = 2;
          border-color = "${bg}";

          padding = 1;

          module-margin-left = 0;
          module-margin-right = 0;

          font-0 = with fonts.polybar-0; "${ftname};${toString offset}";
          font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
          font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
          font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
          font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
          font-5 = with fonts.polybar-5; "${ftname};${toString offset}";
          font-6 = with fonts.polybar-6; "${ftname};${toString offset}";

          modules-left = "title space bspwm";
          modules-center = "";
          modules-right = "";

          separator = "";
          dim-value = "1.0";

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };

        ## ----------------------------------  [bar/pam3] ---------------------------------- ##
        "bar/pam3" = {
          monitor = "";
          monitor-fallback = "";
          monitor-strict = false;

          override-redirect = false;

          bottom = false;
          fixed-center = true;

          width = "21.5%";
          height = 40;

          offset-x = "43.5%";
          offset-y = 10;

          background = "${bg-alt}";
          foreground = "${fg}";

          radius = 6;

          line-size = 2;
          line-color = "${blue}";

          border-size = 2;
          border-color = "${bg}";

          padding = 1;

          module-margin-left = 0;
          module-margin-right = 0;



          font-0 = with fonts.polybar-0; "${ftname};${toString offset}";
          font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
          font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
          font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
          font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
          font-5 = with fonts.polybar-5; "${ftname};${toString offset}";
          font-6 = with fonts.polybar-5; "${ftname};${toString offset}";

          modules-left = "volume space cpu space cpuTemp space updates-pacman space notification-github space battery";
          modules-center = "";
          modules-right = "";

          separator = "";
          dim-value = "";

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "
          pointer ";
          cursor-scroll = "
          ns-resize ";
        };

        ## ----------------------------------  [bar/pam4] ---------------------------------- ##
        "bar/pam4" = {
          monitor = "";
          monitor-fallback = "";
          monitor-strict = false;

          override-redirect = false;

          bottom = false;
          fixed-center = true;

          width = "20%";
          height = 40;

          offset-x = "65.5%";
          offset-y = 10;

          background = "${bg-alt}";
          foreground = "${fg}";

          radius = 6;

          line-size = 2;
          line-color = "${blue}";

          border-size = 2;
          border-color = "${bg}";

          padding = 1;

          module-margin-left = 0;
          module-margin-right = 0;

          font-0 = with fonts.polybar-0; "${ftname};${toString offset}";
          font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
          font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
          font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
          font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
          font-5 = with fonts.polybar-5; "${ftname};${toString offset}";

          modules-left = "themes space brightness space network space mod";
          modules-center = "";
          modules-right = "";

          separator = "";
          dim-value = "1.0";

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";

        };

        ## ----------------------------------  [bar/pam5] ---------------------------------- ##

        "bar/pam5" = {
          monitor = "";
          monitor-fallback = "";
          monitor-strict = false;

          override-redirect = false;

          bottom = false;
          fixed-center = false;

          width = "11.5%";
          height = 40;

          offset-x = "86%";
          offset-y = 10;

          background = "${bg-alt}";
          foreground = "${fg}";

          radius = 6;

          line-size = 2;
          line-color = "${blue}";

          border-size = 2;
          border-color = "${bg}";

          padding = 1;

          module-margin-left = 0;
          module-margin-right = 0;

          font-0 = with fonts.polybar-0; "${ftname};${toString offset}";
          font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
          font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
          font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
          font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
          font-5 = with fonts.polybar-5; "${ftname};${toString offset}";

          modules-left = "sysmenu space date";
          modules-center = "";
          modules-right = "";

          separator = "";
          dim-value = "1.0";

          tray-position = "right";
          tray-detached = true;
          tray-maxsize = 16;
          tray-background = "${bg-alt}";
          tray-offset-x = 0;
          tray-offset-y = 0;
          tray-padding = 0;
          tray-scale = "1.0";

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };

        ## ----------------------------------  [bar/pam6] ---------------------------------- ##

        "bar/pam6" = {
          monitor = "";
          monitor-fallback = "";
          monitor-strict = false;

          override-redirect = false;

          bottom = false;
          fixed-center = true;

          width = "20.5%";
          height = 40;

          offset-x = "22.5%";
          offset-y = 10;

          background = "${bg-alt}";
          foreground = "${fg}";

          radius = 6;

          line-size = 2;
          line-color = "${blue}";

          border-size = 2;
          border-color = "${bg}";

          padding = 2;

          module-margin-left = 0;
          module-margin-right = 0;

          font-0 = with fonts.polybar-0; "${ftname};${toString offset}";
          font-1 = with fonts.polybar-1; "${ftname};${toString offset}";
          font-2 = with fonts.polybar-2; "${ftname};${toString offset}";
          font-3 = with fonts.polybar-3; "${ftname};${toString offset}";
          font-4 = with fonts.polybar-4; "${ftname};${toString offset}";
          font-5 = with fonts.polybar-5; "${ftname};${toString offset}";


          modules-left = "song";
          modules-center = "info-cava";
          modules-right = "mpd";

          separator = "";
          dim-value = "1.0";

          wm-restack = "bspwm";
          enable-ipc = true;

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };

        "system" = { };
      };
    };
  };
}
