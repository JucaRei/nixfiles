{ pkgs, ... }: {
  programs = {
    waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = {
        ## General Settings
        layer = "top";
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;
        spacing = 0;

        # Load modules
        "hyprland/workspaces" =
          {
            "on-click" = "activate";
            "activate-only" = "false";
            "all-outputs" = "true";
            "format" = "{}";
            "format-icons" = {
              "urgent" = "";
              "active" = "";
              "default" = "";
            };
            "persistent-workspaces" = {
              "*" = "5";
            };
          };

        "wlr/taskbar" = {
          "format" = "{icon}";
          "icon-size" = "18";
          "tooltip-format" = "{title}";
          "on-click" = "activate";
          "on-click-middle" = "close";
          "ignore-list" = [
            "Alacritty"
          ];
          "apps_ids-mapping" = {
            "firefoxdeveloperedition" = "firefox-developer-edition";
          };
          "rewrite" = {
            "Firefox Web Browser" = "Firefox";
            "Foot Server" = "Terminal";
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
          "separate-outputs" = "true";
        };
        # // Cliphist
        "custom/cliphist" = {
          "format" = "";
          "on-click" = "sleep 0.1 && ~/.config/hypr/scripts/cliphist.sh";
          "on-click-right" = "sleep 0.1 && ~/.config/hypr/scripts/cliphist.sh d";
          "on-click-middle" = "sleep 0.1 && ~/.config/hypr/scripts/cliphist.sh w";
          "tooltip" = "false";
        };
        # ChatGPT Launcher
        "custom/chatgpt" = {
          "format" = "";
          "on-click" = "chromium --app=https://chat.openai.com";
          "tooltip" = "false";
        };
        # Wallpapers
        "custom/wallpaper" = {
          "format" = "";
          "on-click" = "~/.config/hypr/scripts/wallpaper.sh select";
          "on-click-right" = "~/.config/hypr/scripts/wallpaper.sh";
          "tooltip" = "false";
        };
        # Rofi Calculator
        "custom/calculator" = {
          "format" = "";
          "on-click" = "qalculate-gtk";
          "tooltip" = "false";
        };
        # Windows VM
        "custom/windowsvm" = {
          "format" = "";
          "on-click" = "~/dotfiles/scripts/launchvm.sh";
          "tooltip" = "false";
        };
        # Power Menu
        "custom/exit" = {
          "format" = "";
          "on-click" = "wlogout";
          "tooltip" = "false";
        };
        # Keyboard State
        "keyboard-state" = {
          "numlock" = "true";
          "capslock" = "true";
          "format" = "{name} {icon}";
          "format-icons" = {
            "locked" = "";
            "unlocked" = "";
          };
        };
        # System tray
        "tray" = {
          "icon-size" = "21";
          "spacing" = "10";
        };
        # Clock
        "clock" = {
          # // "timezone": "America/Sao_Paulo";
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          # // START CLOCK FORMAT
          "format-alt" = "{:%Y-%m-%d}";
          # // END CLOCK FORMAT
        };
        # System
        "custom/system" = {
          "format" = "";
          "tooltip" = "false";
        };
        # CPU
        "cpu" = {
          "format" = "/ C {usage}% ";
          "on-click" = "alacritty -e htop";
        };
        # Memory
        "memory" = {
          "format" = "/ M {}% ";
          "on-click" = "alacritty -e htop";
        };
        # Hard disc space used
        "disk" = {
          "interval" = 30;
          "format" = "D {percentage_used}% ";
          "path" = "/";
          "on-click" = "alacritty -e htop";
        };
        "hyprland/language" = {
          "format" = "/ K {short}";
        };
        # Group Hardware
        "group/hardware" = {
          "orientation" = "inherit";
          "drawer" = {
            "transition-duration" = "300";
            "children-class" = "not-memory";
            "transition-left-to-right" = "false";
          };
          "modules" = [
            "custom/system"
            "disk"
            "cpu"
            "memory"
            "hyprland/language"
          ];
        };
        # Group Settings
        "group/settings" = {
          "orientation" = "inherit";
          "drawer" = {
            "transition-duration" = "300";
            "children-class" = "not-memory";
            "transition-left-to-right" = "false";
          };
          "modules" = [
            "custom/settings"
            "custom/waybarthemes"
            "custom/wallpaper"
          ];
        };
        # Group Quicklinks
        "group/quicklinks" = {
          "orientation" = "horizontal";
          "modules" = [
            "custom/filemanager"
            "custom/browser"
          ];
        };
        # network
        "network" = {
          "format" = "{ifname}";
          "format-wifi" = "   {signalStrength}%";
          "format-ethernet" = "  {ipaddr}";
          "format-disconnected" = "Not connected"; #//An empty format will hide the module.
          "tooltip-format" = " {ifname} via {gwaddri}";
          "tooltip-format-wifi" = "   {essid} ({signalStrength}%)";
          "tooltip-format-ethernet" = "  {ifname} ({ipaddr}/{cidr})";
          "tooltip-format-disconnected" = "Disconnected";
          "max-length" = "50";
          "on-click" = "~/dotfiles/.settings/networkmanager.sh";
        };
        # Battery
        "battery" = {
          "states" = {
            #// "good"= "95";
            "warning" = "30";
            "critical" = "15";
          };
          "format" = "{icon}   {capacity}%";
          "format-charging" = "  {capacity}%";
          "format-plugged" = "  {capacity}%";
          "format-alt" = "{icon}  {time}";
          #// "format-good"= ""; #// An empty format will hide the module
          #// "format-full"= "";
          "format-icons" = [
            " "
            " "
            " "
            " "
            " "
          ];
        };
        # Pulseaudio
        "pulseaudio" = {
          #// "scroll-step"= "1"; #// %, can be a float
          "format" = "{icon} {volume}%";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [
              ""
              " "
              " "
            ];
          };
          "on-click" = "pavucontrol";
        };
        # Bluetooth
        "bluetooth" = {
          "format" = " {status}";
          "format-disabled" = "";
          "format-off" = "";
          "interval" = "30";
          "on-click" = "blueman-manager";
        };
        # Other
        "user" = {
          "format" = "{user}";
          "interval" = "60";
          "icon" = "false";
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "tooltip" = "false";
          "format-icons" = {
            "activated" = "Auto lock OFF";
            "deactivated" = "ON";
          };
        };

        style = ''
          @define-color backgroundlight @color5;
          @define-color backgrounddark @color11;
          @define-color workspacesbackground1 @color5;
          @define-color workspacesbackground2 @color11;
          @define-color bordercolor @color11;
          @define-color textcolor1 #FFFFFF;
          @define-color textcolor2 #FFFFFF;
          @define-color textcolor3 #FFFFFF;
          @define-color iconcolor #FFFFFF;


          * {
              font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
              border: none;
              border-radius: 0px;
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
              opacity:0.7;
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
              margin: 8px 15px 8px 0px;
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
              font-size: 16px;
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
              color: @iconcolor;
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

           #disk,#memory,#cpu,#language {
              margin:0px;
              padding:0px;
              font-size:16px;
              color:@iconcolor;
          }

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
              color: @textcolor2;
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
              padding: 2px 15px 0px 10px;
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
              padding: 0px 15px 0px 0px;
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
              background-color: #90b1b1;
          }

          #network {
              background-color: #2980b9;
          }

          #network.disconnected {
              background-color: #f53c3c;
          }

        '';
        systemd = {
          enable = true;
          target = "graphical-session.target";
        };
      };
    };
  };
}
