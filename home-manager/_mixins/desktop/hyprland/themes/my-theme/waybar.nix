{ pkgs, ... }: {
  programs = {
    waybar = {
      enable = true;
      # package = pkgs.waybar;
      settings = [
        {
          mainBar = {
            ## General Settings
            layer = "top";
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
            "wlr/taskbar"
            # "group/quicklinks"
          ];
          modules-center = [
            "hyprland/workspaces"
            "pulseaudio"
            "bluetooth"
            "battery"
            "network"
            "clock"
          ];
          modules-right = [
            "custom/cliphist"
          ];

          ### Custom Modules
          "wlr/taskvar" = {
            "format" = "{icon}";
            "icon-size" = "16";
            "tooltip-format" = "{title}";
            "on-click" = "activate";
            "on-click-middle" = "close";
            "ignore-list" = [
              "Alacritty"
            ];
            "app_ids-mapping" = {
              "firefoxdeveloperedition" = "firefox-developer-edition";
            };
            "rewrite" = {
              "Firefox Web Browser" = "Firefox";
              "Foot Server" = "Terminal";
            };
          };
          "custom/appmenu" = {
            # START APPS LABEL
            "format" = "Apps";
            # END APPS LABEL
            "on-click" = "rofi -show drun -replace";
            # "on-click-right" = "~/dotfiles/hypr/scripts/keybindings.sh";
            "on-click-right" = pkgs.writeShellScript "keybindings"
              ''
                # Get keybindings location based on variation
                config_file=$(cat ~/.config/hypr/hyprland.conf)
                config_file=''${config_file/source = ~/}
                config_file=''${config_file/source=~/}

                # Path to keybindings config file
                config_file="/home/$USER$config_file"
                echo "Reading from: $config_file"

                # Parse keybindings
                keybinds=$(grep -oP '(?<=bind = ).*' $config_file)
                keybinds=$(echo "$keybinds" | sed 's/$mainMod/SUPER/g'|  sed 's/,\([^,]*\)$/ = \1/' | sed 's/, exec//g' | sed 's/^,//g')

                # -----------------------------------------------------
                # Show keybindings in rofi
                # -----------------------------------------------------
                rofi -dmenu -i -replace -p "Keybinds" -config ~/.config/rofi/config-compact.rasi <<< "$keybinds"
              '';
            "tooltip" = false;
          };

          "hyprland/workspaces" = {
            "on-click" = "activate";
            "active-only" = "false";
            "all-outputs" = "true";
            "format" = "{}";
            "format-icons" = {
              "urgent" = "";
              "active" = "";
              "default" = "";
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
            "separate-outputs" = "true";
          };
          #Cliphist
          "custom/cliphist" =
            let
              cliphist = pkgs.writeShellScript "cliphist" ''
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
              "on-click" = "sleep 0.1 && ${cliphist}";
              "on-click-right" = "sleep 0.1 && ${cliphist} d";
              "on-click-middle" = "sleep 0.1 && ${cliphist} w";
              "tooltip" = "false";
            };
        }
      ];
    };
  };
}

# {
#   mainBar = {
#     layer = "top";
#     position = "top";
#     height = 30;
#     output = [ "eDP-1" "HDMI-A-1" ];
#     modules-left = [
#       "sway/workspaces"
#       "sway/mode"
#       "wlr/taskbar"
#     ];
#     modules-center = [
#       "sway/window"
#       "custom/hello-from-waybar"
#     ];
#     modules-right = [
#       "mpd"
#       "custom/mymodule#with-css-id"
#       "temperature"
#     ];
#     "sway/workspaces" = {
#       disable-scroll = true;
#       all-outputs = true;
#     };
#     "custom/hello-from-waybar" = {
#       format = "hello {}";
#       max-length = 40;
#       interval = "once";
#       exec = pkgs.writeShellScript "hello-from-waybar" ''        echo "from within waybar"      '';
#     };
#   };
# }
