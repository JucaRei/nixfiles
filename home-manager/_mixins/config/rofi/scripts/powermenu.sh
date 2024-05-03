#!/bin/bash

# Load Global Variable
# source $HOME/.aether-corevar

rofi_command="rofi -theme $HOME/.config/rofi/themes/powermenu.rasi"

# Options
shutdown="exec systemctl poweroff -i"
reboot="exec systemctl reboot"
lock=" "
suspend="exec systemctl suspend"
logout="bspcquit"

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -dmenu -selected-row 2)"
case $chosen in
    $shutdown)
        ~/.config/rofi/scripts/promptmenu.sh --yes-command "$POWEROFF" --query "      Poweroff?"
        ;;
    $reboot)
        ~/.config/rofi/scripts/promptmenu.sh --yes-command "$REBOOT" --query "       Reboot?"
        ;;
    $lock)
        bash -c "$LOCK"
        ;;
    $suspend)
        mpc -q pause
        bash -c "$SLEEP"
        bash -c "$LOCK"
        ~/.config/i3/scripts/brightness-startup
        ;;
    $logout)
        ~/.config/rofi/scripts/promptmenu.sh --yes-command "pkill -KILL -u $(whoami)" --query "       Logout?"
        ;;
esac
