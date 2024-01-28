{ pkgs, username, ... }: {

  programs = {
    rofi = {
      enable = true;
      plugins = [ pkgs.rofi-calc ];
      # terminal = "\${pkgs.kitty}/bin/kitty";
    };
  };
  xdg = {
    configFile = {
      "rofi/colors.rasi" = {
        text = builtins.readFile ../../../../../config/rofi/default/colors.rasi;
      };
      "rofi/confirm.rasi" = {
        text =
          builtins.readFile ../../../../../config/rofi/default/confirm.rasi;
      };
      "rofi/launcher.rasi" = {
        text =
          builtins.readFile ../../../../../config/rofi/default/launcher.rasi;
      };
      "rofi/message.rasi" = {
        text =
          builtins.readFile ../../../../../config/rofi/default/message.rasi;
      };
      "rofi/networkmenu.rasi" = {
        text =
          builtins.readFile ../../../../../config/rofi/default/networkmenu.rasi;
      };
      "rofi/rofi-network-manager.rasi" = {
        text = builtins.readFile
          ../../../../../config/rofi/default/rofi-network-manager.rasi;
      };
      "rofi/powermenu.rasi" = {
        text =
          builtins.readFile ../../../../../config/rofi/default/powermenu.rasi;
      };
      "rofi/styles.rasi" = {
        text = builtins.readFile ../../../../../config/rofi/default/styles.rasi;
      };
      "rofi/bin/launcher.sh" = {
        executable = true;
        text = ''
          #!/bin/sh

          rofi -no-config -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launcher.rasi
        '';
      };
      "rofi/bin/popup-calendar.sh" = {
        executable = true;
        text = ''
          #!/bin/sh

          DATE="$(/run/current-system/sw/bin/date +"%B %d, %Y")"
          case "$1" in
          --popup)
              /etc/profiles/per-user/${username}/bin/yad --calendar --fixed \
                --posx=1800 --posy=80 --no-buttons --borders=0 --title="yad-calendar" \
                --close-on-unfocus
            ;;
          *)
              echo "$DATE"
            ;;
          esac
        '';
      };
      "rofi/bin/powermenu.sh" = {
        executable = true;
        text = ''
                #!/bin/sh

                configDir="~/.config/rofi"
                uptime=$(uptime -p | sed -e 's/up //g')
                rofi_command="rofi -no-config -theme $configDir/powermenu.rasi"

                # Options
                shutdown=" Shutdown"
                reboot=" Restart"
                lock=" Lock"
                suspend=" Sleep"
                logout=" Logout"

                # Confirmation
                confirm_exit() {
          	      rofi -dmenu\
                        -no-config\
          		      -i\
          		      -no-fixed-num-lines\
          		      -p "Are You Sure? : "\
          		      -theme $configDir/confirm.rasi
                }

                # Message
                msg() {
          	      rofi -no-config -theme "$configDir/message.rasi" -e "Available Options  -  yes / y / no / n"
                }

                # Variable passed to rofi
                options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"
                chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
                case $chosen in
                    $shutdown)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      systemctl poweroff
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                    $reboot)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      systemctl reboot
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                    $lock)
                    betterlockscreen -l
                        ;;
                    $suspend)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      mpc -q pause
          			      amixer set Master mute
          			      systemctl suspend
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                    $logout)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      bspc quit
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                esac
        '';
      };
      # "rofi/bin/rofi-wifi-menu.sh" = {
      #   executable = true;
      #   text = ''
      #     #!/bin/sh

      #     notify-send "Getting list of available Wi-Fi networks..."
      #     # Get a list of available wifi connections and morph it into a nice-looking list
      #     wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

      #     connected=$(nmcli -fields WIFI g)
      #     if [[ "$connected" =~ "enabled" ]]; then
      #     	toggle="󰖪  Disable Wi-Fi"
      #     elif [[ "$connected" =~ "disabled" ]]; then
      #     	toggle="󰖩  Enable Wi-Fi"
      #     fi

      #     # Use rofi to select wifi network
      #     chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )
      #     # Get name of connection
      #     chosen_id=$(echo "$\{chosen_network:3}" | xargs)

      #     if [ "$chosen_network" = "" ]; then
      #     	exit
      #     elif [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
      #     	nmcli radio wifi on
      #     elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
      #     	nmcli radio wifi off
      #     else
      #     	# Message to show when connection is activated successfully
      #     	success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
      #     	# Get saved connections
      #     	saved_connections=$(nmcli -g NAME connection)
      #     	if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
      #     		nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
      #     	else
      #     		if [[ "$chosen_network" =~ "" ]]; then
      #     			wifi_password=$(rofi -dmenu -p "Password: " )
      #     		fi
      #     		nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
      #     	fi
      #     fi
      #   '';
      # };
      "rofi/bin/rofi-wifi.sh" = {
        executable = true;
        text = builtins.readFile ./scripts/rofi-wifi.sh;
      };
    };
  };
}
