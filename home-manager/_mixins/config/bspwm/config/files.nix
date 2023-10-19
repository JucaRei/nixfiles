{ username, config, ... }:

let
  xdg_configHome = "${config.home.homeDirectory}/.config";
  xdg_dataHome = "${config.home.homeDirectory}/.local/share";
  xdg_stateHome = "${config.home.homeDirectory}/.local/state";
in
{

  "${xdg_configHome}/polybar/bin/popup-calendar.sh" = {
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

  "${xdg_configHome}/polybar/bin/check-nixos-updates.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      /run/current-system/sw/bin/git -C ~/.dotfiles/nixfiles fetch upstream master
      UPDATES=$(/run/current-system/sw/bin/git -C ~/.dotfiles/nixfiles rev-list origin/master..upstream/master --count 2>/dev/null);
      /run/current-system/sw/bin/echo " $UPDATES"; # Extra space for presentation with icon
      /run/current-system/sw/bin/sleep 1800;
    '';
  };

  "${xdg_configHome}/polybar/bin/search-nixos-updates.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      /etc/profiles/per-user/${username}/bin/firefox --new-window "https://search.nixos.org/packages?channel=23.05&from=0&size=50&sort=relevance&type=packages"
    '';
  };

  "${xdg_configHome}/rofi/colors.rasi".text = builtins.readFile ./rofi/colors.rasi;
  "${xdg_configHome}/rofi/confirm.rasi".text = builtins.readFile ./rofi/confirm.rasi;
  "${xdg_configHome}/rofi/launcher.rasi".text = builtins.readFile ./rofi/launcher.rasi;
  "${xdg_configHome}/rofi/message.rasi".text = builtins.readFile ./rofi/message.rasi;
  "${xdg_configHome}/rofi/networkmenu.rasi".text = builtins.readFile ./rofi/networkmenu.rasi;
  "${xdg_configHome}/rofi/powermenu.rasi".text = builtins.readFile ./rofi/powermenu.rasi;
  "${xdg_configHome}/rofi/styles.rasi".text = builtins.readFile ./rofi/styles.rasi;

  "${xdg_configHome}/rofi/bin/launcher.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      rofi -no-config -no-lazy-grab -show drun -modi drun -theme ${xdg_configHome}/rofi/launcher.rasi
    '';
  };

  # @todo: Don't use hardcoded src paths
  "${xdg_configHome}/rofi/bin/powermenu.sh" = {
    executable = true;
    text = ''
            #!/bin/sh

            configDir="~/.dotfiles/nixfiles/home-manager/_mixins/config/bspwm/config/rofi"
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
}
