{pkgs, ...}: {
  home = {
    packages = with pkgs; [numix-icon-theme];
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
  programs = let
    cursor = "Numix-Cursor";
    primary_accent = "cba6f7";
    secondary_accent = "89b4fa";
    tertiary_accent = "cdd6f4";
  in {
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
            mode = "overlay";
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
            "custom/weather"
          ];
          modules-center = ["hyprland/workspaces"];
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
            "ignore-list" = ["foot"];
            "app_ids-mapping" = {
              "firefoxdeveloperedition" = "firefox-developer-edition";
            };
            "rewrite" = {
              "Firefox Web Browser" = "Firefox";
              "Foot Server" = "Terminal";
            };
          };
          "custom/network_traffic" = {
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
            "exec" = ''
              playerctl -a metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
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
          "custom/wallpaper" = {
            "format" = "";
            "on-click" = "~/.config/rofi/scripts/wallpaper.sh select";
            "on-click-right" = "~/.config/rofi/scripts/wallpaper.sh";
            "tooltip" = false;
          };
          "custom/appmenu" = {
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
              # "urgent" = "";
              # "active" = "";
              "default" = "";
              "urgent" = "";
              "focused" = "";
              # "default" = "";
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              "10" = "十";
              "sort-by-number" = "true";
            };
            "persistent-workspaces" = {"*" = 5;};
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
              # "activated" = "Auto lock OFF";
              # "deactivated" = "ON";
              "activated" = "   OFF";
              "deactivated" = "";
              # activated = "󰅶";
              # deactivated = "󰾪";
            };
          };
          #Cliphist
          "custom/cliphist" = let
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
          in {
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
            "format-icons" = ["" ""];
            "tooltip" = true;
            "tooltip-format" = "{app}: {title}";
          };
          "mpd" = {
            "format" = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
            "format-disconnected" = "Disconnected ";
            "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
            "unknown-tag" = "N/A";
            "interval" = 2;
            "consume-icons" = {"on" = " ";};
            "random-icons" = {
              "off" = ''<span color="#f53c3c"></span> '';
              "on" = " ";
            };
            "repeat-icons" = {"on" = " ";};
            "single-icons" = {"on" = "1 ";};
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
            "format-icons" = ["" "" "" "" ""];
          };
          "backlight" = {
            # "device" = "acpi_video1";
            # "format" = "{percent}% {icon}";
            "format" = "{percent}% <span font='11'>{icon}</span>";
            "format-icons" = ["" "" "" "" "" "" "" "" ""];
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
            "format-icons" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            "on-click" = "";
            "tooltip" = false;
          };
          "battery#bat2" = {"bat" = "BAT2";};
          "network" = {
            "format" = "{ifname}";
            "format-wifi" = "   {signalStrength}%";
            #   "format-wifi" = "  {bandwidthDownBytes}  {bandwidthUpBytes}";
            "format-ethernet" = "  {ipaddr}";
            #   "format-ethernet" = "  {bandwidthDownBytes} 󰅧  {bandwidthUpBytes}";
            "format-disconnected" = "󰞃  Not connected"; # An empty format will hide the module.
            #   "format-alt" = "󰤨  {essid} {signalStrength}% ";
            #   "interval" = 1;
            #   "format-linked" = "";
            "tooltip-format" = " {ifname} via {gwaddri}";
            #   "tooltip-format" =
            #     "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
            "tooltip-format-wifi" = "   {essid} ({signalStrength}%)";
            "tooltip-format-ethernet" = "  {ifname} ({ipaddr}/{cidr})";
            "tooltip-format-disconnected" = "Disconnected";
            "max-length" = 50;
            "on-click" = let
              "rofi-nm" = pkgs.writeShellScriptBin "rofi-nm" ''
                #!/usr/bin/env bash
                # Source: https://github.com/P3rf/rofi-network-manager
                WIDTH_FIX_STATUS=10
                PASSWORD_ENTER="if connection is stored, hit enter/esc."
                WIRELESS_INTERFACES=($(nmcli device | awk '$2=="wifi" {print $1}'))
                WIRELESS_INTERFACES_PRODUCT=()
                WLAN_INT=0
                WIRED_INTERFACES=($(nmcli device | awk '$2=="ethernet" {print $1}'))
                WIRED_INTERFACES_PRODUCT=()
                RASI_DIR="~/.config/rofi/wlan.rasi"
                function initialization() {
                  for i in $(eval "echo "$\{WIRELESS_INTERFACES[@]}""); do WIRELESS_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
                  for i in $(eval "echo "$\{WIRED_INTERFACES[@]}""); do WIRED_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
                  wireless_interface_state && ethernet_interface_state
                }
                function notification() {
                  dunstify -r "5" -u "normal" $1 "$2"
                }
                function wireless_interface_state() {
                  ACTIVE_SSID=$(nmcli device status | grep "^$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")." | awk '{print $4}')
                  WIFI_CON_STATE=$(nmcli device status | grep "^$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")." | awk '{print $3}')
                  { [[ "$WIFI_CON_STATE" == "unavailable" ]] && WIFI_LIST="***Wi-Fi Disabled***" && WIFI_SWITCH="~Wi-Fi On" && OPTIONS="$WIFI_LIST\n$WIFI_SWITCH\n~Scan"; } || { [[ "$WIFI_CON_STATE" =~ "connected" ]] && {
                    PROMPT="$(eval "echo "$\{WIRELESS_INTERFACES_PRODUCT[WLAN_INT]}"")[$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")]"
                    WIFI_LIST=$(nmcli --fields IN-USE,SSID,SECURITY,BARS device wifi list ifname "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")" | awk -F'  +' '{ if (!seen[$2]++) print}' | sed "s/^IN-USE\s//g" | sed "/*/d" | sed "s/^ *//" | awk '$1!="--" {print}')
                    [[ "$ACTIVE_SSID" == "--" ]] && WIFI_SWITCH="~Scan\n~Manual/Hidden\n~Wi-Fi Off" || WIFI_SWITCH="~Scan\n~Disconnect\n~Manual/Hidden\n~Wi-Fi Off"
                    OPTIONS="$WIFI_LIST\n$WIFI_SWITCH"
                  }; }
                }
                function ethernet_interface_state() {
                  WIRED_CON_STATE=$(nmcli device status | grep "ethernet" | head -1 | awk '{print $3}')
                  { [[ "$WIRED_CON_STATE" == "disconnected" ]] && WIRED_SWITCH="~Eth On"; } || { [[ "$WIRED_CON_STATE" == "connected" ]] && WIRED_SWITCH="~Eth Off"; } || { [[ "$WIRED_CON_STATE" == "unavailable" ]] && WIRED_SWITCH="***Wired Unavailable***"; } || { [[ "$WIRED_CON_STATE" == "connecting" ]] && WIRED_SWITCH="***Wired Initializing***"; }
                  OPTIONS="$OPTIONS\n$WIRED_SWITCH"
                }
                function rofi_menu() {
                  { [[ $(eval "echo "$\{\#WIRELESS_INTERFACES[@]}"") -ne "1" ]] && OPTIONS="$OPTIONS\n~Change Wifi Interface\n~More Options"; } || { OPTIONS="$OPTIONS\n~More Options"; }
                  { [[ "$WIRED_CON_STATE" == "connected" ]] && PROMPT="$WIRED_INTERFACES_PRODUCT[$WIRED_INTERFACES]"; } || PROMPT="$(eval "echo "$\{WIRELESS_INTERFACES_PRODUCT[WLAN_INT]}"")[$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")]"
                  SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" 1 "-a 0")
                  SSID=$(echo "$SELECTION" | sed "s/\s\{2,\}/\|/g" | awk -F "|" '{print $1}')
                  selection_action
                }
                function dimensions() {
                  { [[ "$1" != "" ]] && WIDTH=$(echo -e "$1" | awk '{print length}' | sort -n | tail -1) && ((WIDTH += $2)) && LINES=$(echo -e "$1" | wc -l); } || { WIDTH=$2 && LINES=0; }
                }
                function rofi_cmd() {
                  dimensions "$1" $2
                  rofi -dmenu -i $3 \
                    -theme "$RASI_DIR" -theme-str '
                    window{width: '"$((WIDTH / 2))"'em;}
                    listview{lines: '"$LINES"';}
                    textbox-prompt-colon{str:"'"$PROMPT"':";}
                    '"$4"""
                }
                function change_wireless_interface() {
                  { [[ $(eval "echo "$\{\#WIRELESS_INTERFACES[@]}"") -eq "2" ]] && { [[ $WLAN_INT -eq "0" ]] && WLAN_INT=1 || WLAN_INT=0; }; } || {
                    LIST_WLAN_INT=""
                    for i in $(eval "echo "$\{\!WIRELESS_INTERFACES[@]}""); do LIST_WLAN_INT=("$(eval "echo "$\{LIST_WLAN_INT[@]}"")$(eval "echo "$\{WIRELESS_INTERFACES_PRODUCT[\$i]}"")[$(eval "echo "$\{WIRELESS_INTERFACES[\$i]}"")]\n"); done
                    LIST_WLAN_INT[-1]="$(eval "echo "$\{LIST_WLAN_INT[-1]::-2}"")"
                    CHANGE_WLAN_INT=$(echo -e "$(eval "echo "$\{LIST_WLAN_INT[@]}"")" | rofi_cmd "$(eval "echo "$\{LIST_WLAN_INT[@]}"")" $WIDTH_FIX_STATUS)
                    for i in $(eval "echo "$\{\!WIRELESS_INTERFACES[@]}""); do [[ $CHANGE_WLAN_INT == "$(eval "echo "$\{WIRELESS_INTERFACES_PRODUCT[\$i]}"")[$(eval "echo "$\{WIRELESS_INTERFACES[\$i]}"")]" ]] && WLAN_INT=$i && break; done
                  }
                  wireless_interface_state && ethernet_interface_state
                  rofi_menu
                }
                function scan() {
                  [[ "$WIFI_CON_STATE" =~ "unavailable" ]] && change_wifi_state "Wi-Fi" "Enabling Wi-Fi connection" "on" && sleep 2
                  notification "-t 0 Wifi" "Please Wait, Scanning..."
                  WIFI_LIST=$(nmcli --fields IN-USE,SSID,SECURITY,BARS device wifi list ifname "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")" --rescan yes | awk -F'  +' '{ if (!seen[$2]++) print}' | sed "s/^IN-USE\s//g" | sed "/*/d" | sed "s/^ *//" | awk '$1!="--" {print}')
                  wireless_interface_state && ethernet_interface_state
                  notification "-t 1 Wifi" "Please Wait, Scanning..."
                  rofi_menu
                }
                function change_wifi_state() {
                  notification "$1" "$2"
                  nmcli radio wifi "$3"
                }
                function change_wired_state() {
                  notification "$1" "$2"
                  nmcli device "$3" "$4"
                }
                function net_restart() {
                  notification "$1" "$2"
                  nmcli networking off && sleep 3 && nmcli networking on
                }
                function disconnect() {
                  ACTIVE_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")" | cut -d ':' -f2)
                  notification "$1" "You're now disconnected from Wi-Fi network '$ACTIVE_SSID'"
                  nmcli con down id "$ACTIVE_SSID"
                }
                function check_wifi_connected() {
                  [[ "$(nmcli device status | grep "^$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")." | awk '{print $3}')" == "connected" ]] && disconnect "Connection_Terminated"
                }
                function connect() {
                  check_wifi_connected
                  notification "-t 0 Wi-Fi" "Connecting to $1"
                  { [[ $(nmcli dev wifi con "$1" password "$2" ifname "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")" | grep -c "successfully activated") -eq "1" ]] && notification "Connection_Established" "You're now connected to Wi-Fi network '$1'"; } || notification "Connection_Error" "Connection can not be established"
                }
                function enter_passwword() {
                  PROMPT="Enter_Password" && PASS=$(echo "$PASSWORD_ENTER" | rofi_cmd "$PASSWORD_ENTER" 4 "-password")
                }
                function enter_ssid() {
                  PROMPT="Enter_SSID" && SSID=$(rofi_cmd "" 40)
                }
                function stored_connection() {
                  check_wifi_connected
                  notification "-t 0 Wi-Fi" "Connecting to $1"
                  { [[ $(nmcli dev wifi con "$1" ifname "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")" | grep -c "successfully activated") -eq "1" ]] && notification "Connection_Established" "You're now connected to Wi-Fi network '$1'"; } || notification "Connection_Error" "Connection can not be established"
                }
                function ssid_manual() {
                  enter_ssid
                  [[ -n $SSID ]] && {
                    enter_passwword
                    { [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && connect "$SSID" "$PASS"; } || stored_connection "$SSID"
                  }
                }
                function ssid_hidden() {
                  enter_ssid
                  [[ -n $SSID ]] && {
                    enter_passwword && check_wifi_connected
                    [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && {
                      nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")"
                      nmcli con modify "$SSID" wifi-sec.key-mgmt wpa-psk
                      nmcli con modify "$SSID" wifi-sec.psk "$PASS"
                    } || [[ $(nmcli -g NAME con show | grep -c "$SSID") -eq "0" ]] && nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")"
                    notification "-t 0 Wifi" "Connecting to $SSID"
                    { [[ $(nmcli con up id "$SSID" | grep -c "successfully activated") -eq "1" ]] && notification "Connection_Established" "You're now connected to Wi-Fi network '$SSID'"; } || notification "Connection_Error" "Connection can not be established"
                  }
                }
                function interface_status() {
                  local -n INTERFACES=$1 && local -n INTERFACES_PRODUCT=$2
                  for i in $(eval "echo "$\{\!INTERFACES[@]}""); do
                    CON_STATE=$(nmcli device status | grep "^$(eval "echo "$\{INTERFACES[\$i]}"")." | awk '{print $3}')
                    INT_NAME=$(eval "echo "$\{INTERFACES_PRODUCT[\$i]}"")[$(eval "echo "$\{INTERFACES[\$i]}"")]
                    [[ "$CON_STATE" == "connected" ]] && STATUS="$INT_NAME:\n\t$(nmcli -t -f GENERAL.CONNECTION dev show "$(eval "echo "$\{INTERFACES[\$i]}"")" | awk -F '[:]' '{print $2}') ~ $(nmcli -t -f IP4.ADDRESS dev show "$(eval "echo "$\{INTERFACES[\$i]}"")" | awk -F '[:/]' '{print $2}')" || STATUS="$INT_NAME: $(eval "echo "$\{CON_STATE^}"")"
                    echo -e "$STATUS"
                  done
                }
                function status() {
                  WLAN_STATUS="$(interface_status WIRELESS_INTERFACES WIRELESS_INTERFACES_PRODUCT)"
                  ETH_STATUS="$(interface_status WIRED_INTERFACES WIRED_INTERFACES_PRODUCT)"
                  OPTIONS="$ETH_STATUS\n$WLAN_STATUS"
                  ACTIVE_VPN=$(nmcli -g NAME,TYPE con show --active | awk '/:vpn/' | sed 's/:vpn.*//g')
                  [[ -n $ACTIVE_VPN ]] && OPTIONS="$OPTIONS\n$ACTIVE_VPN[VPN]: $(nmcli -g ip4.address con show "$ACTIVE_VPN" | awk -F '[:/]' '{print $1}')"
                  echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" $WIDTH_FIX_STATUS "" "mainbox {children:[listview];}"
                }
                function share_pass() {
                  SSID=$(nmcli dev wifi show-password | grep -oP '(?<=SSID: ).*' | head -1)
                  PASSWORD=$(nmcli dev wifi show-password | grep -oP '(?<=Password: ).*' | head -1)
                  OPTIONS="SSID: $SSID\nPassword: $PASSWORD"
                  SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" $WIDTH_FIX_STATUS "-a "$((LINES - 1))"" "mainbox {children:[listview];}")
                  selection_action
                }
                function manual_hidden() {
                  OPTIONS="~Manual\n~Hidden" && SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" $WIDTH_FIX_STATUS "" "mainbox {children:[listview];}")
                  selection_action
                }
                function vpn() {
                  ACTIVE_VPN=$(nmcli -g NAME,TYPE con show --active | awk '/:vpn/' | sed 's/:vpn.*//g')
                  [[ $ACTIVE_VPN ]] && OPTIONS="~Deactive $ACTIVE_VPN" || OPTIONS="$(nmcli -g NAME,TYPE connection | awk '/:vpn/' | sed 's/:vpn.*//g')"
                  VPN_ACTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" "$WIDTH_FIX_STATUS" "" "mainbox {children:[listview];}")
                  [[ -n "$VPN_ACTION" ]] && { { [[ "$VPN_ACTION" =~ "~Deactive" ]] && nmcli connection down "$ACTIVE_VPN" && notification "VPN_Deactivated" "$ACTIVE_VPN"; } || {
                    notification "-t 0 Activating_VPN" "$VPN_ACTION" && VPN_OUTPUT=$(nmcli connection up "$VPN_ACTION" 2>/dev/null)
                    { [[ $(echo "$VPN_OUTPUT" | grep -c "Connection successfully activated") -eq "1" ]] && notification "VPN_Successfully_Activated" "$VPN_ACTION"; } || notification "Error_Activating_VPN" "Check your configuration for $VPN_ACTION"
                  }; }
                }
                function more_options() {
                  OPTIONS=""
                  [[ "$WIFI_CON_STATE" == "connected" ]] && OPTIONS="~Share Wifi Password\n"
                  OPTIONS="$OPTIONS~Status\n~Restart Network"
                  [[ $(nmcli -g NAME,TYPE connection | awk '/:vpn/' | sed 's/:vpn.*//g') ]] && OPTIONS="$OPTIONS\n~VPN"
                  OPTIONS="$OPTIONS\n~Open Connection Editor"
                  SELECTION=$(echo -e "$OPTIONS" | rofi_cmd "$OPTIONS" "$WIDTH_FIX_STATUS" "" "mainbox {children:[listview];}")
                  selection_action
                }
                function selection_action() {
                  case "$SELECTION" in
                  "~Disconnect") disconnect "Connection_Terminated" ;;
                  "~Scan") scan ;;
                  "~Status") status ;;
                  "~Share Wifi Password") share_pass ;;
                  "~Manual/Hidden") manual_hidden ;;
                  "~Manual") ssid_manual ;;
                  "~Hidden") ssid_hidden ;;
                  "~Wi-Fi On") change_wifi_state "Wi-Fi" "Enabling Wi-Fi connection" "on" ;;
                  "~Wi-Fi Off") change_wifi_state "Wi-Fi" "Disabling Wi-Fi connection" "off" ;;
                  "~Eth Off") change_wired_state "Ethernet" "Disabling Wired connection" "disconnect" "$WIRED_INTERFACES" ;;
                  "~Eth On") change_wired_state "Ethernet" "Enabling Wired connection" "connect" "$WIRED_INTERFACES" ;;
                  "***Wi-Fi Disabled***") ;;
                  "***Wired Unavailable***") ;;
                  "***Wired Initializing***") ;;
                  "~Change Wifi Interface") change_wireless_interface ;;
                  "~Restart Network") net_restart "Network" "Restarting Network" ;;
                  "~More Options") more_options ;;
                  "~Open Connection Editor") ${pkgs.unstable.networkmanagerapplet}/bin/nm-connection-editor ;;
                  "~VPN") vpn ;;
                  *)
                    [[ -n "$SELECTION" ]] && [[ "$WIFI_LIST" =~ .*"$SELECTION".* ]] && {
                      [[ "$SSID" == "*" ]] && SSID=$(echo "$SELECTION" | sed "s/\s\{2,\}/\|/g " | awk -F "|" '{print $3}')
                      { [[ "$ACTIVE_SSID" == "$SSID" ]] && nmcli con up "$SSID" ifname "$(eval "echo "$\{WIRELESS_INTERFACES[WLAN_INT]}"")"; } || {
                        [[ "$SELECTION" =~ "WPA2" ]] || [[ "$SELECTION" =~ "WEP" ]] && enter_passwword
                        { [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && connect "$SSID" "$PASS"; } || stored_connection "$SSID"
                      }
                    }
                    ;;
                  esac
                }
                function main() {
                  initialization && rofi_menu
                }
                main
              '';
            in "${rofi-nm}/bin/rofi-nm";
          };
          # "network" = {
          #   "format-wifi" = "  {bandwidthDownBytes}  {bandwidthUpBytes}";
          #   "format-ethernet" = "  {bandwidthDownBytes} 󰅧  {bandwidthUpBytes}";
          #   "format-disconnected" = " 󰞃 ";
          #   "format-alt" = "󰤨  {essid} {signalStrength}% ";
          #   "interval" = 1;
          #   "format-linked" = "";
          #   "tooltip-format" =
          #     "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
          #   "tooltip-format-wifi" = ''
          #     {essid} ({signalStrength}%) 
          #     {ipaddr} | {frequency} MHz {icon}
          #       {bandwidthDownBytes}  {bandwidthUpBytes}  '';
          #   "tooltip-format-ethernet" = ''
          #     {ifname} 
          #     {ipaddr} | {frequency} MHz{icon}
          #      {bandwidthDownBytes}  {bandwidthUpBytes} '';
          #   "tooltip-format-disconnected" = "Not Connected";
          #   "on-click" = "bash ~/.config/rofi/scripts/rofi-wifi-menu.sh";
          # };
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
            "modules" = ["custom/settings" "custom/waybarthemes" "custom/wallpaper"];
          };
          "group/quicklinks" = {
            "orientation" = "horizontal";
            "modules" = ["custom/filemanager" "custom/browser"];
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
              "default" = ["" " " " "];
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
              "disabled" = "󰂲 OFF";
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
          "custom/weather" = {
            "exec" = "nix-shell ~/.config/waybar/scripts/weather.py";
            "restart-interval" = 300;
            "return-type" = "json";
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
          "hyprland/language" = {"format" = "/ K {short}";};
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
  home.file = {
    ".config/waybar/scripts/weather.py" = {
      source = ../../../../config/scripts/waybar-wttr.py;
      executable = true;
    };
  };
}
