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
      ".config/polybar/scripts/polywins.sh" = {
        executable = true;
        source = builtins.readFile ../../config/polybar/scripts/polywins;
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
      };
      extraConfig = ''
        ### Decor.ini

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
