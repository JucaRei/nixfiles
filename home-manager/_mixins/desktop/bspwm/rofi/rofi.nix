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
        text = builtins.readFile ./colors.rasi;
      };
      "rofi/confirm.rasi" = {
        text = builtins.readFile ./confirm.rasi;
      };
      "rofi/launcher.rasi" = {
        text = builtins.readFile ./launcher.rasi;
      };
      "rofi/message.rasi" = {
        text = builtins.readFile ./message.rasi;
      };
      "rofi/networkmenu.rasi" = {
        text = builtins.readFile ./networkmenu.rasi;
      };
      "rofi/powermenu.rasi" = {
        text = builtins.readFile ./powermenu.rasi;
      };
      "rofi/styles.rasi" = {
        text = builtins.readFile ./styles.rasi;
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
    };
  };
}
