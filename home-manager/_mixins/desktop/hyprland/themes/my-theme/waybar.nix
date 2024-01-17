{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      numix-icon-theme
    ];
    file = {
      ".config/waybar/scripts/keybindings.sh" = {
        text = ''
          #!/usr/bin/env bash

          config_file=~/.config/hypr/keybindings.conf
          keybinds=$(grep -oP '(?<=bind = ).*' $config_file)
          keybinds=$(echo "$keybinds" | sed 's/,\([^,]*\)$/ = \1/' | sed 's/, exec//g' | sed 's/^,//g')
          rofi -dmenu -p "Keybinds" <<< "$keybinds"
        '';
        executable = true;
      };
      ".config/waybar/scripts/net-traffic.sh" = {
        source = ./rofi/net-traffic.sh;
        executable = true;
      };
    };
  };
  programs =
    let
      cursor = "Numix-Cursor";
      primary_accent = "cba6f7";
      secondary_accent = "89b4fa";
      tertiary_accent = "cdd6f4";
    in
    {
      waybar = {
        enable = true;
        package = pkgs.unstable.waybar.override {
          hyprlandSupport = true;
          experimentalPatches = true;
        };
        systemd = {
          enable = false;
          target = "hyprland-session.target";
        };
        settings = [
          {
            mainBar = {
              ## General Settings
              mode = "dock";
              layer = "top";
              position = "top";
              height = 18;
              margin-top = 0;
              margin-bottom = 0;
              margin-left = 0;
              margin-right = 0;
              spacing = 0;
              # output = [
              # "eDP-1"
              # "HDMI-A-1"
              # ];
            };
            modules-left = [
              "custom/appmenu"
              "custom/settings"
              "custom/waybarthemes"
              "custom/wallpaper"
              # Start task toogle
              "wlr/taskbar"
              # End task toogle
              # "group/quicklinks"
              "hyprland/window"
              "custom/playerctl#backward"
              "custom/playerctl#play"
              "custom/playerctl#foward"
            ];
            modules-center = [
              "hyprland/workspaces"
            ];
            modules-right = [
              "pulseaudio"
              "bluetooth"
              "battery"
              "network"
              "group/hardware"
              "custom/cliphist"
              "idle_inhibitor"
              # "custom/network_traffic"
              # Start tray toogle
              "tray"
              "backlight"
              "clock"
              "custom/exit"
              # End tray toogle
            ];

            ### Custom Modules
            "wlr/taskbar" = {
              "format" = "{icon}";
              "icon-size" = "16";
              "tooltip-format" = "{title}";
              "on-click" = "activate";
              "on-click-middle" = "close";
              "ignore-list" = [
                "foot"
              ];
              "app_ids-mapping" = {
                "firefoxdeveloperedition" = "firefox-developer-edition";
              };
              "rewrite" = {
                "Firefox Web Browser" = "Firefox";
                "Foot Server" = "Terminal";
              };
            };
            "custom/network_traffic" =
              {
                "exec" = ".config/waybar/scripts/net-traffic.sh";
                "return-type" = "json";
                "format-ethernet" = "{icon} {ifname} ⇣{bandwidthDownBytes:>4} ⇡{bandwidthUpBytes:>4}";
              };
            "custom/playerctl#backward" = {
              "format" = "󰙣 ";
              "on-click" = "playerctl previous";
              "on-scroll-up" = "playerctl volume .05+";
              "on-scroll-down" = "playerctl volume .05-";
            };
            "custom/playerctl#play" = {
              "format" = "{icon}";
              "return-type" = "json";
              "exec" = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
              "on-click" = "playerctl play-pause";
              "on-scroll-up" = "playerctl volume .05+";
              "on-scroll-down" = "playerctl volume .05-";
              "format-icons" = {
                "Playing" = "<span>󰏥 </span>";
                "Paused" = "<span> </span>";
                "Stopped" = "<span> </span>";
              };
            };
            "custom/playerctl#foward" = {
              "format" = "󰙡 ";
              "on-click" = "playerctl next";
              "on-scroll-up" = "playerctl volume .05+";
              "on-scroll-down" = "playerctl volume .05-";
            };
            "custom/wallpaper" =
              {
                "format" = "";
                "on-click" = "~/.config/rofi/scripts/wallpaper.sh select";
                "on-click-right" = "~/.config/rofi/scripts/wallpaper.sh";
                "tooltip" = false;
              };
            "custom/appmenu" =
              {
                # START APPS LABEL
                "format" = "  Apps";
                # END APPS LABEL
                "on-click" = "pkill .rofi-wrapped || rofi -show drun -replace";
                # "on-click-right" = "~/dotfiles/hypr/scripts/keybindings.sh";
                "on-click-right" = "$HOME/.config/waybar/scripts/keybindings.sh";
                "tooltip" = false;
              };
            "custom/keybindings" = {
              "format" = "";
              "on-click" = "~/dotfiles/hypr/scripts/keybindings.sh";
              "tooltip" = false;
            };
            "hyprland/workspaces" = {
              "on-click" = "activate";
              "active-only" = "false";
              "all-outputs" = "true";
              "on-scroll-up" = "hyprctl dispatch workspace e-1";
              "on-scroll-down" = "hyprctl dispatch workspace e+1";
              "format" = "{name}";
              "format-icons" = {
                "urgent" = "";
                "active" = "";
                "default" = "";
                "sort-by-number" = "true";
              };
              "persistent-workspaces" = {
                "*" = 5;
              };
            };
            "hyprland/window" = {
              "rewrite" = {
                "(.*) - Brave" = "$1";
                "(.*) - Chromium" = "$1";
                "(.*) - Brave Search" = "$1";
                "(.*) - Outlook" = "$1";
                "(.*) Microsoft Teams" = "$1";
              };
              format = "{}";
              "separate-outputs" = "true";
            };
            "idle_inhibitor" = {
              "format" = "{icon}";
              "tooltip" = false;
              "format-icons" = {
                "activated" = "Auto lock OFF";
                "deactivated" = "ON";
                # activated = "󰅶";
                # deactivated = "󰾪";
              };
            };
            #Cliphist
            "custom/cliphist" =
              let
                cliphist-custom = pkgs.writeShellScriptBin "cliphist-custom" ''
                  case $1 in
                      d) ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | ${pkgs.cliphist}/bin/cliphist delete
                        ;;

                      w) if [ `echo -e "Clear\nCancel" | rofi -dmenu -config ~/.config/rofi/config-short.rasi` == "Clear" ] ; then
                              ${pkgs.cliphist}/bin/cliphist wipe
                        fi
                        ;;

                      *) ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
                        ;;
                  esac
                '';
              in
              {
                "format" = "";
                "on-click" = "sleep 0.1 && ${cliphist-custom}/bin/cliphist-custom";
                "on-click-right" = "sleep 0.1 && ${cliphist-custom}/bin/cliphist-custom d";
                "on-click-middle" = "sleep 0.1 && ${cliphist-custom}/bin/cliphist-custom w";
                "tooltip" = "false";
              };
            "keyboard-state" = {
              "numlock" = true;
              "capslock" = true;
              format = "{name} {icon}";
              "format-icons" = {
                "locked" = "";
                "unlocked" = "";
              };
            };
            "sway/scratchpad" = {
              "format" = "{icon} {count}";
              "show-empty" = false;
              "format-icons" = [ "" "" ];
              "tooltip" = true;
              "tooltip-format" = "{app}: {title}";
            };
            "mpd" = {
              "format" = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
              "format-disconnected" = "Disconnected ";
              "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
              "unknown-tag" = "N/A";
              "interval" = 2;
              "consume-icons" = {
                "on" = " ";
              };
              "random-icons" = {
                "off" = "<span color=\"#f53c3c\"></span> ";
                "on" = " ";
              };
              "repeat-icons" = {
                "on" = " ";
              };
              "single-icons" = {
                "on" = "1 ";
              };
              "state-icons" = {
                "paused" = "";
                "playing" = "";
              };
              "tooltip-format" = "MPD (connected)";
              "tooltip-format-disconnected" = "MPD (disconnected)";
            };
            "tray" = {
              "spacing" = 10;
              "icon-size" = 21;
            };
            # "clock" = {
            #   # "timezone" = "America/Sao_Paulo";
            #   "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            #   # START CLOCK FORMAT
            #   "format-alt" = "{:%Y-%m-%d}";
            #   # END CLOCK FORMAT
            # };
            "clock" = {
              "format" = "{:%H:%M} ";
              "format-alt" = "{:%A, %d de %B, %Y (%R)} ";
              "tooltip-format" = "<tt><small>{calendar}</small></tt>";
              "calendar" = {
                "mode" = "year";
                "mode-mon-col" = 3;
                "weeks-pos" = "right";
                "on-scroll" = 1;
                "on-click-right" = "mode";
                "format" = {
                  "months" = "<span color='#ffead3'><b>{}</b></span>";
                  "days" = "<span color='#ecc6d9'><b>{}</b></span>";
                  "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
                  "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
                  "today" = "<span color='#EF6F6C'><b><u>{}</u></b></span>";
                };
              };
              "actions" = {
                "on-click-right" = "mode";
                "on-click-forward" = "tz_up";
                "on-click-backward" = "tz_down";
                "on-scroll-up" = "shift_up";
                "on-scroll-down" = "shift_down";
              };
            };
            "cpu" = {
              "format" = "{usage}% <span font='11'></span> ";
              "interval" = 1;
              # "format" = "{usage}% ";
              # "format" = "/c {usage}%";
              "on-click" = "foot -e htop";
              "tooltip" = false;
            };
            "memory" = {
              # "format" = "/ M {}% ";
              "format" = "{}% <span font='11'></span> ";
              "interval" = 1;
              "on-click" = "foot -e htop";
            };
            "disk" = {
              "format" = "{percentage_used}% <span font='11'></span> ";
              "interval" = 30;
              # "format" = "D {percentage_used}% ";
              "path" = "/";
              "on-click" = "foot -e htop";
            };
            "temperature" = {
              #  "thermal-zone"= 2;
              #  "hwmon-path" = "/sys/class/hwmon/hwmon2/temp1_input";
              "critical-threshold" = 80;
              # "format-critical" = "{temperatureC}°C {icon}";
              "format" = "{temperatureC}°C {icon} ";
              "format-icons" = [ "" "" "" "" "" ];
            };
            "backlight" = {
              # "device" = "acpi_video1";
              # "format" = "{percent}% {icon}";
              "format" = "{percent}% <span font='11'>{icon}</span>";
              "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
            };
            "battery" = {
              "states" = {
                # "good"= 95;
                "warning" = 30;
                "critical" = 15;
              };
              "format" = "{icon} {capacity}%";
              "format-charging" = "󰂄 {capacity}%";
              "format-plugged" = "󱘖 {capacity}%"; # 
              "format-alt" = "{icon} {time}";
              # "format-good"= ""; # An empty format will hide the module
              # "format-full"= "";
              #  "format-icons" = [ " " " " " " " " " " ];
              "format-icons" = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
              "on-click" = "";
              "tooltip" = false;
            };
            "battery#bat2" = {
              "bat" = "BAT2";
            };
            "network" = {
              "format" = "{ifname}";
              "format-wifi" = "   {signalStrength}%";
              "format-ethernet" = "  {ipaddr}";
              "format-disconnected" = "Not connected"; #An empty format will hide the module.
              "tooltip-format" = " {ifname} via {gwaddri}";
              "tooltip-format-wifi" = "   {essid} ({signalStrength}%)";
              "tooltip-format-ethernet" = "  {ifname} ({ipaddr}/{cidr})";
              "tooltip-format-disconnected" = "Disconnected";
              "max-length" = 50;
              "on-click" = "foot -e nmtui";
            };
            "group/hardware" = {
              "orientation" = "inherit";
              "drawer" = {
                "transition-duration" = 300;
                "children-class" = "not-memory";
                "transition-left-to-right" = false;
              };
              "modules" = [
                "custom/system"
                "temperature"
                "disk"
                "cpu"
                "memory"
                "hyprland/language"
              ];
            };
            "group/settings" = {
              "orientation" = "inherit";
              "drawer" = {
                "transition-duration" = 300;
                "children-class" = "not-memory";
                "transition-left-to-right" = false;
              };
              "modules" = [
                "custom/settings"
                "custom/waybarthemes"
                "custom/wallpaper"
              ];
            };
            "group/quicklinks" = {
              "orientation" = "horizontal";
              "modules" = [
                "custom/filemanager"
                "custom/browser"
              ];
            };
            "pulseaudio" = {
              # "scroll-step": 1; ## %, can be a float
              "format" = "{icon} {volume}% {format_source}";
              "format-bluetooth" = "{volume}% {icon} {format_source}";
              "format-bluetooth-muted" = " {icon} {format_source}";
              "format-muted" = "󰗿 {format_source}";
              "format-source" = " {volume}%";
              "format-source-muted" = "";
              "format-icons" = {
                "headphone" = " ";
                "hands-free" = "󰂰 ";
                "headset" = "󰋎 ";
                "phone" = "󰏳 ";
                "portable" = " ";
                "car" = " ";
                "default" = [ "" " " " " ];
              };
              "on-click" = "pavucontrol";
            };
            # "bluetooth" = {
            #   "format" = " {status}";
            #   "format-disabled" = "";
            #   "format-off" = "";
            #   "interval" = 30;
            #   "on-click" = "blueman-manager";
            # };
            "bluetooth" = {
              "on-click" = "~/.config/rofi/scripts/bluetooth-control.sh";
              "on-click-right" = "~/.config/rofi/scripts/rofi-bluetooth.sh";
              "on-click-middle" = "~/.config/rofi/scripts/rofi-bluetooth.sh";
              "format" = "{icon}";
              "interval" = 15;
              "format-icons" = {
                "on" = "<span foreground='#88C0D0'></span>";
                "off" = "<span foreground='#F38BA8'>󰂲</span>";
                "disabled" = "󰂲 OFF#";
                "connected" = " ON";
              };
              "tooltip-format" = "{device_alias} {status}";
            };
            "custom/media" = {
              "format" = "{icon} {}";
              "return-type" = "json";
              "max-length" = 40;
              "format-icons" = {
                "spotify" = "";
                "default" = "🎜";
              };
              "escape" = true;
              "exec" = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
              # "exec"= "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null"; # Filter player based on name
            };
            "custom/browser" = {
              "format" = "";
              "on-click" = "exec firefox";
              "tooltip" = false;
            };
            # Filemanager Launcher
            "custom/filemanager" = {
              "format" = "";
              "on-click" = "exec thunar";
              "tooltip" = false;
            };
            "custom/calculator" = {
              "format" = "";
              "on-click" = "qalculate-gtk";
              "tooltip" = false;
            };
            "custom/exit" = {
              "format" = "";
              "on-click" = "wlogout";
              "tooltip" = false;
            };
            "custom/system" = {
              "format" = "";
              "tooltip" = false;
            };
            "hyprland/language" = {
              "format" = "/ K {short}";
            };
            "user" = {
              "format" = "{user}";
              "interval" = 60;
              "icon" = false;
            };
          }
        ];

        #############
        ### Style ###
        #############

        style = ''
          /* -----------------------------------------------------
           * Import Pywal colors
           * ----------------------------------------------------- */
          @import '/home/juca/.cache/wal/colors-waybar.css';
          @define-color backgroundlight @color5;
          @define-color backgrounddark @color11;
          @define-color workspacesbackground1 @color5;
          @define-color workspacesbackground2 @color11;
          @define-color bordercolor @color11;
          @define-color textcolor1 #FFFFFF;
          @define-color textcolor2 #FFFFFF;
          @define-color textcolor3 #FFFFFF;
          @define-color iconcolor #FFFFFF;

          /* -----------------------------------------------------
           * General
           * ----------------------------------------------------- */

          * {
              font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
              border: 0.8px;
              border-radius: 2px;
              border-color: #B6BBC4;
          }

          window#waybar {
              background-color: rgba(0,0,0,0.2);
              border-bottom: 0px solid #ffffff;
              /* color: #FFFFFF; */
              transition-property: background-color;
              transition-duration: .5s;
          }

          /* -----------------------------------------------------
           * Workspaces
           * ----------------------------------------------------- */

          #workspaces {
              background: @workspacesbackground1;
              margin: 5px 1px 6px 1px;
              padding: 0px 1px;
              border-radius: 15px;
              border: 0px;
              font-weight: bold;
              font-style: normal;
              opacity: 0.8;
              font-size: 16px;
              color: @textcolor1;
          }

          #workspaces button {
              padding: 0px 5px;
              margin: 4px 3px;
              border-radius: 15px;
              border: 0px;
              color: @textcolor1;
              background-color: @workspacesbackground2;
              transition: all 0.3s ease-in-out;
              opacity: 0.4;
          }

          #workspaces button.active {
              color: @textcolor1;
              background: @workspacesbackground2;
              border-radius: 15px;
              min-width: 40px;
              transition: all 0.3s ease-in-out;
              opacity:1.0;
          }

          #workspaces button:hover {
              color: @textcolor1;
              background: @workspacesbackground2;
              border-radius: 15px;
              opacity:0.75;
          }

          /* -----------------------------------------------------
           * Tooltips
           * ----------------------------------------------------- */

          tooltip {
              border-radius: 10px;
              background-color: @backgroundlight;
              opacity:0.8;
              padding:20px;
              margin:0px;
          }

          tooltip label {
              color: @textcolor2;
          }

          /* -----------------------------------------------------
           * Window
           * ----------------------------------------------------- */

          #window {
              background: @backgroundlight;
              margin: 8px 14px 8px 0px;
              padding: 2px 10px 0px 10px;
              border-radius: 12px;
              color:@textcolor2;
              font-size:16px;
              font-weight:normal;
              opacity:0.8;
          }

          window#waybar.empty #window {
              background-color:transparent;
          }

          /* -----------------------------------------------------
           * Taskbar
           * ----------------------------------------------------- */

          /*
          #custom-playerctl.backward,
          #custom-playerctl.play,
          #custom-playerctl.foward
          */
          #taskbar {
              background: @backgroundlight;
              margin: 6px 15px 6px 0px;
              padding:0px;
              border-radius: 15px;
              font-weight: normal;
              font-style: normal;
              opacity:0.8;
              border: 3px solid @backgroundlight;
          }

          #taskbar button {
              margin:0;
              border-radius: 15px;
              padding: 0px 5px 0px 5px;
          }

          /* -----------------------------------------------------
           * Modules
           * ----------------------------------------------------- */

          .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
          }

          .modules-right > widget:last-child > #workspaces {
              margin-right: 0;
          }

          /* -----------------------------------------------------
           * Custom Quicklinks
           * ----------------------------------------------------- */

          #custom-brave,
          #custom-browser,
          #custom-keybindings,
          #custom-outlook,
          #custom-filemanager,
          #custom-teams,
          #custom-chatgpt,
          #custom-calculator,
          #custom-windowsvm,
          #custom-cliphist,
          #custom-wallpaper,
          #custom-settings,
          #custom-wallpaper,
          #custom-system,
          #custom-waybarthemes {
              margin-right: 23px;
              font-size: 20px;
              font-weight: bold;
              opacity: 0.8;
              color: @iconcolor;
          }


          #custom-system {
              margin-right:15px;
          }

          #custom-wallpaper {
              margin-right:25px;
          }

          #custom-waybarthemes, #custom-settings {
              margin-right:20px;
          }

          #custom-playerctl {
            margin-right: 6px;
            font-size: 18px;
            font-weight: bold;
            /* opacity: 0.8; */
            opacity: 0.8;
            color: @iconcolor;
            background-color: @backgroundlight;
            /* background: @backgroundlight; */
          }
          #custom-playerctl.backward,
          #custom-playerctl.play,
          #custom-playerctl.foward {
            /* background: #${tertiary_accent}; */
            /* background: @backgroundlight; */
            background-color: @backgroundlight;
            font-weight: bold;
            margin: 5px 0px;
            opacity: 0.9;
          }
          #custom-playerctl.backward,
          #custom-playerctl.play,
          #custom-playerctl.foward {
            /* background: #${tertiary_accent}; */
            background-color: @backgroundlight;
            font-size: 22px;
          }
          #custom-playerctl.backward:hover,
          #custom-playerctl.play:hover,
          #custom-playerctl.foward:hover {
            color: #${tertiary_accent};
          }
          #custom-playerctl.backward {
            color: #${primary_accent};
            border-radius: 24px 0px 0px 10px;
            padding-left: 16px;
            margin-left: 7px;
          }
          #custom-playerctl.play {
            color: #${secondary_accent};
            padding: 0 5px;
          }
          #custom-playerctl.foward {
            color: #${primary_accent};
            border-radius: 0px 10px 24px 0px;
            padding-right: 12px;
            margin-right: 7px
          }
          /* -----------------------------------------------------
           * Idle Inhibator
           * ----------------------------------------------------- */

          #idle_inhibitor {
              margin-right: 15px;
              font-size: 16px;
              font-weight: bold;
              opacity: 0.8;
              color: @iconcolor;
          }

          #idle_inhibitor.activated {
              background-color: #dc2f2f;
              font-size: 16px;
              color: #FFFFFF;
              border-radius: 15px;
              padding: 2px 10px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.8;
          }

          /* -----------------------------------------------------
           * Custom Modules
           * ----------------------------------------------------- */

          #custom-appmenu {
              background-color: @backgrounddark;
              font-size: 15px;
              color: @textcolor1;
              border-radius: 15px;
              padding: 0px 10px 0px 10px;
              margin: 6px 15px 6px 14px;
              opacity:0.8;
              border:3px solid @bordercolor;
          }

          /* -----------------------------------------------------
           * Custom Exit
           * ----------------------------------------------------- */

          #custom-exit {
              margin: 0px 20px 0px 0px;
              padding:0px;
              font-size:20px;
              /* color: @iconcolor; */
              color: #F05941;
          }

          /* -----------------------------------------------------
           * Custom Updates
           * ----------------------------------------------------- */

          #custom-updates {
              background-color: @backgroundlight;
              font-size: 16px;
              color: @textcolor2;
              border-radius: 15px;
              padding: 2px 10px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.8;
          }

          #custom-updates.green {
              background-color: @backgroundlight;
          }

          #custom-updates.yellow {
              background-color: #ff9a3c;
              color: #FFFFFF;
          }

          #custom-updates.red {
              background-color: #dc2f2f;
              color: #FFFFFF;
          }

          /* -----------------------------------------------------
           * Custom Youtube
           * ----------------------------------------------------- */

          #custom-youtube {
              background-color: @backgroundlight;
              font-size: 16px;
              color: @textcolor2;
              border-radius: 15px;
              padding: 2px 10px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.8;
          }

          /* -----------------------------------------------------
           * Hardware Group
           * ----------------------------------------------------- */

          /* #disk,#memory,#language { */
          #disk,#memory,#cpu,#language {
              margin:0px;
              padding:0px;
              font-size:16px;
              color:@iconcolor;
          }

          /*
          #cpu {
            margin:0px;
            padding:0px;
            font-size:16px;
            color:#e86489;
          }
          */

          #language {
              margin-right:10px;
          }

          /* -----------------------------------------------------
           * Clock
           * ----------------------------------------------------- */

          #clock {
              background-color: @backgrounddark;
              font-size: 16px;
              color: @textcolor1;
              border-radius: 15px;
              padding: 1px 10px 0px 10px;
              margin: 6px 15px 6px 0px;
              opacity:0.8;
              border:3px solid @bordercolor;
          }

          /* -----------------------------------------------------
           * Pulseaudio
           * ----------------------------------------------------- */

          #pulseaudio {
              background-color: @backgroundlight;
              font-size: 16px;
              color: @textcolor2;
              border-radius: 15px;
              padding: 2px 10px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.8;
          }

          #pulseaudio.muted {
              background-color: @backgrounddark;
              color: @textcolor1;
          }

          /* -----------------------------------------------------
           * Network
           * ----------------------------------------------------- */

          #network {
              background-color: @backgroundlight;
              font-size: 16px;
              color: @textcolor2;
              border-radius: 15px;
              padding: 2px 10px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.8;
          }

          #network.ethernet {
              background-color: @backgroundlight;
              color: @textcolor2;
          }

          #network.wifi {
              background-color: @backgroundlight;
              color: @textcolor2;
          }

          /* -----------------------------------------------------
           * Bluetooth
           * ----------------------------------------------------- */

          #bluetooth, #bluetooth.on, #bluetooth.connected {
              background-color: @backgroundlight;
              font-size: 16px;
              /* color: @textcolor2; */
              color: #B4D4FF;
              border-radius: 15px;
              padding: 2px 10px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.8;
          }

          #bluetooth.off {
              background-color: transparent;
              padding: 0px;
              margin: 0px;
          }

          /* -----------------------------------------------------
           * Battery
           * ----------------------------------------------------- */

          #battery {
              background-color: @backgroundlight;
              font-size: 16px;
              color: @textcolor2;
              border-radius: 15px;
              padding: 2px 12px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.8;
          }

          #battery.charging, #battery.plugged {
              color: @textcolor2;
              background-color: @backgroundlight;
          }

          @keyframes blink {
              to {
                  background-color: @backgroundlight;
                  color: @textcolor2;
              }
          }

          #battery.critical:not(.charging) {
              background-color: #f53c3c;
              color: @textcolor3;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          /* -----------------------------------------------------
           * Tray
           * ----------------------------------------------------- */

          #tray {
              padding: 0px 10px 0px 0px;
          }

          #tray > .passive {
              -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
          }

          /* -----------------------------------------------------
           * Other
           * ----------------------------------------------------- */

          label:focus {
              background-color: #000000;
          }

          #backlight {
              background-color: @backgroundlight;
              font-size: 16px;
              /* color: #39A7FF; */
              /* color: #9400FF; */
              /* color: #6c07fa; */
              color: @textcolor2;
              border-radius: 15px;
              padding: 2px 10px 0px 10px;
              margin: 8px 15px 8px 0px;
              opacity:0.83;
          }

          #network {
              background-color: #2980b9;
          }

          #network.disconnected {
              background-color: #f53c3c;
          }

        '';
      };
    };
}
