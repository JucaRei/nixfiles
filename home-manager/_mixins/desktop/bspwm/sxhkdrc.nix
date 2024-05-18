args@{ pkgs, config, lib, hostname, ... }:
let
  _ = lib.getExe;
  terminal = "${_ vars.alacritty-custom}";
  # browser = "${config.programs.chromium.package}/bin/chromium-browser";
  vars = import ./vars.nix { inherit pkgs config hostname; };
  filemanager = vars.filemanager;

  bspwm-conf = "${config.xsession.windowManager.bspwm.package}/bin";

  picom-toggle = pkgs.writeShellScriptBin "picom-toggle" ''
    #!${pkgs.stdenv.shell}

    if ${pkgs.procps}/bin/pgrep -x "picom" > /dev/null
    then
    	${pkgs.killall}/bin/killall picom
    	${pkgs.libnotify}/bin/notify-send picom "compositing disabled"
    else
    	picom -b --corner-radius 10
    	${pkgs.libnotify}/bin/notify-send picom "compositing enabled"
    fi
  '';

  dunst-light = pkgs.writeShellScriptBin "dunst-light" ''
    #!/usr/bin/env bash
    #
    # You can call this script like this:
    # $ ./brightnessdunst.sh up
    # $ ./brightnessdunst.sh down

    # ICON="preferences-system-brightness-lock"
    NOTIFICATION_ID="5555"
    INCREMENT="0.2%"

    get_brightness() {
      awk -v current="$(${pkgs.brillo}/bin/brillo -b)" -v max="$(${pkgs.brillo}/bin/brillo -m)" 'BEGIN { printf "%.0f\n", (current / max) * 100 }'
    }

    send_notification() {
      brightness="$1"
      progressbar "$brightness"
      ${pkgs.dunst}/bin/dunstify -r "$NOTIFICATION_ID" -u normal -t 1 ""
    }

    increase_brightness() {
      ${pkgs.brillo}/bin/brillo -e -A "$INCREMENT"
    }

    decrease_brightness() {
      ${pkgs.brillo}/bin/brillo -e -U "$INCREMENT"
    }

    # Main
    case $1 in
    up)
      increase_brightness
      ;;
    down)
      decrease_brightness
      ;;
    toggle-auto)
      auto_brightness_toggle
      ;;
    *)
      echo "Invalid argument. Usage: $0 [up|down|toggle-auto]"
      exit 1
      ;;
    esac

    send_notification "$(get_brightness)"
  '';

  isNitro = if (hostname == "nitro") then "1920x1080" else "1366x768";
  screenshooter = pkgs.writeShellScriptBin "screenshooter" ''
    #!/usr/bin/env sh

    # Save Screenshots here
    screenshotdir=$HOME/Pictures/screenshots
    # file name
    file=$screenshotdir/$(date '+%y%m%d-%H%M-%S').png
    # icon for notification
    icon=${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48/apps/deepin-camera.svg
    # rofi config
    roficonfig=$HOME/.config/rofi/configurations/screenshot.rasi
    #make sure you have directory
    [ -d "$screenshotdir" ] || mkdir -pv "$screenshotdir"

    # ┬─┐┌─┐┌─┐┬
    # ├┬┘│ │├┤ │
    # ┴└─└─┘└  ┴

    area=""
    cwin=""
    full=""
    copy=""
    save=""

    rofiopt="$area\n$cwin\n$full"
    rofi=$(${pkgs.coreutils}/bin/printf "$rofiopt" | ${config.programs.rofi.package}/bin/rofi -config $roficonfig -dmenu -i )
    [ -z "$rofi" ] && ${pkgs.execline}/bin/exit
    option="$save\n$copy"
    saveopt=$(${pkgs.coreutils}/bin/printf "$option" | ${config.programs.rofi.package}/bin/rofi -config $roficonfig -dmenu -i )

    case $rofi in
    	"$area")
    	if [ "$saveopt" = "$copy" ]; then
    	${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Select Area'
    	${pkgs.maim}/bin/maim -u -m 5 -s | xclip -selection clipboard -t image/png && ${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Screenshot copied' || ${pkgs.libnotify}/bin/notify-send -i $icon 'failed to take screenshot'
      elif [ "$saveopt" = "$save" ]; then
    	${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Select Area'
    	${pkgs.maim}/bin/maim -u -m 5 -s $file && ${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Screenshot Taken' || ${pkgs.libnotify}/bin/notify-send -i $icon 'failed to take screenshot'
    	fi
    	;;
    	"$cwin")
    	if [ "$saveopt" = "$copy" ]; then
    	${pkgs.maim}/bin/maim -u -m 5 -i "$(${pkgs.xdotool}/bin/xdotool getactivewindow)" | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png && ${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Screenshot copied' || ${pkgs.libnotify}/bin/notify-send -i $icon 'failed to take screenshot'
      elif [ "$saveopt" = "$save" ]; then
    	${pkgs.maim}/bin/maim -u -m 5 -i "$(${pkgs.xdotool}/bin/xdotool getactivewindow)" $file && ${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Screenshot Taken' || ${pkgs.libnotify}/bin/notify-send -i $icon 'failed to take screenshot'
    	fi
    	;;
    	"$full")
    	if [ "$saveopt" = "$copy" ]; then
        sleep 2
    	${pkgs.maim}/bin/maim -u -m 5 | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png && ${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Screenshot copied' || ${pkgs.libnotify}/bin/notify-send -i $icon 'failed to take screenshot'
      elif [ "$saveopt" = "$save" ]; then
        sleep 2
    	${pkgs.maim}/bin/maim -u -m 5 $file && ${pkgs.libnotify}/bin/notify-send -i $icon --urgency low 'Screenshot Taken' || ${pkgs.libnotify}/bin/notify-send -i $icon 'failed to take screenshot'
    	fi
    	;;
    esac
  '';

  orpheus_lower-volume = pkgs.writeShellScriptBin "orpheus_lower-volume" ''
    #!${pkgs.stdenv.shell}
    DSINK="@DEFAULT_SINK@"
    ID=9932
    MSG=""

    getcurrvol() {
      ${pkgs.pulseaudio}/bin/pactl get-sink-volume $DSINK | awk '{print $5;exit}'
    }

    CURR=$(getcurrvol) # get value

    if [ $CURR = '0%' ]; then
      MSG='  '
    else
      ${pkgs.pulseaudio}/bin/pactl set-sink-volume $DSINK -2%
      MSG=" 󰝞 $(getcurrvol)"
    fi

    ${pkgs.dunst}/bin/dunstify -a 'orpheus' -r $ID $MSG

      ""
  '';
  orpheus_raise-volume = pkgs.writeShellScriptBin "orpheus_raise-volume" ''
    #!${pkgs.stdenv.shell}
    DSINK="@DEFAULT_SINK@"
    MAX=65536
    NINEPER=58982
    ID=9932
    MSG=""

    getcurrvol() {
      ${pkgs.pulseaudio}/bin/pactl get-sink-volume $DSINK | awk '{print $5;exit}'
    }
    getcurrvolint() {
      ${pkgs.pulseaudio}/bin/pactl get-sink-volume $DSINK | awk '{print $3;exit}'
    }

    if (($(getcurrvolint) >= $MAX)); then
      MSG=' 󰕾 '
    elif (($(getcurrvolint) >= $NINEPER)); then
      ${pkgs.pulseaudio}/bin/pactl set-sink-volume $DSINK 150%
      MSG=" 󰝝 $(getcurrvol)"
    else
      ${pkgs.pulseaudio}/bin/pactl set-sink-volume $DSINK +2%
      MSG=" 󰝝 $(getcurrvol)"
    fi

    ${pkgs.dunst}/bin/dunstify -a 'orpheus' -r $ID $MSG

    ""
  '';
  orpheus_mute = pkgs.writeShellScriptBin "orpheus_mute" ''
    #!${pkgs.stdenv.shell}
    DSINK="@DEFAULT_SINK@"
    ID=9932
    MSG=""

    ${pkgs.pulseaudio}/bin/pactl set-sink-mute $DSINK toggle
    IS_MUTED=$(${pkgs.pulseaudio}/bin/pactl get-sink-mute $DSINK | awk '{print $2}')

    if [ $IS_MUTED = 'no' ]; then
      MSG='  '
    else
      MSG='  '
    fi

    ${pkgs.dunst}/bin/dunstify -a 'orpheus' -r $ID $MSG

  '';
in
{
  "${vars.mod} + Return" = "${terminal}"; # Terminal
  "${vars.mod} + shift + Return" = "${terminal} --class='termfloat'"; # Terminal
  "${vars.mod} + b" = "${vars.browser}"; # web-browser
  "${vars.mod} + shift + b" = "${vars.browser} --new-window https://youtube.com/"; # web-browser
  "${vars.mod} + shift + p" = "${vars.browser} --private-window"; # web-browser
  "${vars.mod} + e" = "${filemanager}";

  "${vars.modAlt} + shift + p" = "${picom-toggle}/bin/picom-toggle";

  # "${vars.mod} + @space" = "rofi -show drun"; # program launcher
  "${vars.modAlt} + @space" = "rofi -config -no-lazy-grab -show drun -modi drun -theme $HOME/.config/rofi/configurations/Themes/Forest/launcher.rasi"; # program launcher
  # calculator    rofi -config -no-lazy-grab -show drun -modi drun -theme
  "F1" = "rofi -show calc -modi calc --no-show-match --no-sort -lines 2";
  # emoji
  "F2" = "rofi -show emoji -modi emoji";
  # "${vars.modAlt} + @slash" = "${sxhkd_helper}/bin/sxhkd_helper";

  # make sxhkd reload its configuration files:
  "${vars.modAlt} + Escape" = "${pkgs.procps}/bin/pkill -USR1 -x sxhkd; ${bspwm-conf}/bspc wm -r; ${pkgs.libnotify}/bin/notify-send 'Sxhkd & Polybar' 'Reloaded config'";

  # "${vars.modAlt} + Escape" =
  #   ''
  #     ${pkgs.procps}/bin/pkill -USR1 -x sxhkd; \
  #     ${bspwm-conf}//bspc wm -r; \
  #     ${config.services.polybar.package}/bin/polybar-msg cmd restart; \
  #     ${pkgs.dunst}/bin/dunstify 'Reload all configuration.' -u low
  #   '';

  # bspc wm -r; \
  # polybar-msg cmd restart; \
  # dunstify "Reload all configuration." -u low

  #   ${bspwm-conf}//bspc wm -r; \
  #   polybar-msg cmd restart; \
  #   dunstify "Reload all configuration." -u low
  # '';

  # quit bspwm
  "${vars.mod} + ${vars.modAlt} + q" = ''
    systemctl --user stop bspwm-session.target; \
    ${bspwm-conf}//bspc quit
  '';

  ### Bspwm hotkeys
  #to change tabs ig
  # Switch to recent window
  # "${vars.modAlt} + Tab" = "${bspwm-conf}//bspc node -f last.local";
  "${vars.mod},${vars.modAlt} + {_,shift + }Tab" = "${bspwm-conf}/bspc node -f {next,prev}.loca+l";
  "${vars.mod} + ctrl + q" =
    let
      quit = ''
          ${pkgs.systemdMinimal}/bin/systemctl --user stop bspwm-session.target; \
        	${bspwm-conf}/bspc quit
      '';
    in
    "${quit}";

  "${vars.mod} + ctrl + r" = "${bspwm-conf}/bspc wm -r"; # quit | restart
  "${vars.mod} + m" = "${bspwm-conf}/bspc desktop -l next"; # ${vars.modAlt}ernate between the tiled and monocle layout
  "${vars.mod} + {_, ${vars.modAlt} + }m" = "${bspwm-conf}/bspc node -f {next, prev}.local.!hidden.window";
  "${vars.mod} + {_,shift + }{Left,Down,Up,Right}" = "${bspwm-conf}/bspc node -{f,s} {west, south,north,east}"; # Send the window to another edge of the screen
  "${vars.mod} + equal" = "${bspwm-conf}/bspc node @/ --equalize"; # Make split ratios equal
  "${vars.mod} + minus" = "${bspwm-conf}/bspc node @/ --balance"; # Make split ratios balanced
  "${vars.modAlt} + d" = "bspc query --nodes -n focused.tiled && state=floating || state=tiled; bspc node --state \~$state";
  # rotate
  "${vars.mod} + f" = "${bspwm-conf}/bspc node --state \~fullscreen"; # Toggle fullscreen of window
  "${vars.mod} + {_,shift + }q" = "${bspwm-conf}/bspc node -{c,k}"; # Close and kill
  "${vars.mod} + k" = "${bspwm-conf}/bspc desktop -l next"; # ${vars.modAlt}ernate between the tiled and monocle layout
  # "${vars.modAlt} + shift + g" = "${bspwm-conf}//bspc config window_gap 5";
  # "${vars.modAlt} + g" = "${bspwm-conf}//bspc config window_gap 0";
  # change window gap
  "${vars.mod} + {minus,equal}" = "${bspwm-conf}/bspc config -d focused window_gap $((`${bspwm-conf}/bspc config -d focused window_gap` {+,-} 2 ))";
  "${vars.mod} + g" = "${bspwm-conf}/bspc node -s biggest.window"; # Swap the current node and the biggest window
  "${vars.mod} + shift + g" = "if [ \"$(${bspwm-conf}/bspc config window_gap)\" -eq 0 ]; then ${bspwm-conf}/bspc config window_gap 12; ${bspwm-conf}/bspc config border_width 2; else ${bspwm-conf}/bspc config window_gap 0; ${bspwm-conf}/bspc config border_width 0; fi";
  # "${vars.mod} + shift + g" = "${bspwm-conf}/bspc node -s biggest.window"; # Swap the current node and the smallest window

  # "${vars.mod} + g" = ''if [ \"$(${bspwm-conf}//bspc config window_gap)\" -eq 0 ]; then ${bspwm-conf}//bspc config window_gap 12; ${bspwm-conf}//bspc config border_width 2; else ${bspwm-conf}//bspc config window_gap 0; ${bspwm-conf}//bspc config border_width 0; fi'';

  # Move current window to a pre-selected space
  "${vars.mod} + shift + m" = "${bspwm-conf}/bspc node -n last.!automatic";

  "${vars.mod} + {_,shift} + {u,i}" = "${bspwm-conf}/bspc {monitor -f,node -m} {prev,next}"; # focus or send to the next monitor

  # ${vars.modAlt} - Move workspaces
  # "${vars.mod} + {Left,Right}" = "${bspwm-conf}//bspc desktop -f {prev,next}.local"; # Focus the next/previous desktop in the current monitor
  # "${vars.mod} + {_,shift +}{1-9,0}" = "${bspwm-conf}//bspc {desktop -f,node -d} '{1-9,10}'"; # Focus or send to the given desktop
  "${vars.mod} + shift + {Left,Right}" = "${bspwm-conf}/bspc node -d {prev,next}.local --follow"; # Send and follow to previous or next desktop

  ####################
  ### States flags ###
  ####################

  "${vars.mod} + {t,shift + t,s,f}" = "${bspwm-conf}/bspc node -t {tiled,pseudo_tiled,floating,\~fullscreen}";
  "${vars.modAlt} + f" = ''${bspwm-conf}/bspc node -t "~"{floating,tiled}'';
  "${vars.mod} + ctrl + {m,x,y,z}" = "${bspwm-conf}/bspc node -g {marked,locked,sticky,private}"; # set the node flags

  # set the node flags
  # "${vars.mod} + ctrl + {x,y,z}" = "${bspwm-conf}//bspc node -g {locked,sticky,private}";

  ##################
  ### Focus/swap ###
  ##################

  # focus the node in the given direction
  "${vars.mod} + {_,shift + }{h,j,k,l}" = "${bspwm-conf}/bspc node -{f,s} {west,south,north,east}";

  # focus the node for the given path jump
  "${vars.mod} + {p,b,comma,period}" = "${bspwm-conf}/bspc node -f @{parent,brother,first,second}";

  # focus the next/previous node in the current desktop
  "${vars.mod} + {_,shift + }c" = "${bspwm-conf}/bspc node -f {prev,next}.local";

  # Focus left/right occupied desktop
  "${vars.mod} + {Left,Right}" = "${bspwm-conf}/bspc desktop --focus {prev,next}.occupied";

  # Focus left/right desktop
  "ctrl + ${vars.modAlt} + {Left,Right}" = "${bspwm-conf}/bspc desktop --focus {prev,next}";

  # Focus left/right desktop
  "ctrl + ${vars.modAlt} + {Up, Down}" = "${bspwm-conf}/bspc desktop --focus {prev,next}";

  # Focus left/right occupied desktop
  "${vars.mod} + {Up,Down}" = "${bspwm-conf}/bspc desktop --focus {prev,next}.occupied";
  # focus the next/previous desktop in the current monitor
  # "${vars.mod} + bracket{left,right}" = "${bspwm-conf}//bspc desktop -f {prev,next}.local";
  "${vars.mod} + Left" = "${bspwm-conf}/bspc desktop -f prev.local";
  "${vars.mod} + Right" = "${bspwm-conf}/bspc desktop -f next.local";

  # focus the last node/desktop
  "${vars.mod} + {grave,Tab}" = "${bspwm-conf}/bspc {node,desktop} -f last";

  # focus the older or newer node in the focus history
  "${vars.mod} + {o,i}" = ''
    ${bspwm-conf}/bspc wm -h off; \
    ${bspwm-conf}/bspc node {older,newer} -f; \
    ${bspwm-conf}/bspc wm -h on
  '';

  # Switch to different workspaces with back-and-forth support
  "${vars.mod} + {1-9,0}" = "${bspwm-conf}/bspc desktop -f '^{1-9,10}'";

  # alternate between the tiled and monocle layout
  "${vars.modAlt} + m" = "${bspwm-conf}/bspc desktop -l next";

  # Scratchpad
  "${vars.mod} + z" = "${bspwm-conf}/bspc node focused -t floating; ${bspwm-conf}/bspc node -d '^12'";
  # Scratchpad
  # "super + alt + o" = "${pkgs.tdrop}/bin/tdrop -a -w 70% -h 35% -y 0 -x 15%  --class scratch alacritty --class=scratch";
  "alt + Tab" = "rofi -show window -window-thumbnail";

  # Move windows to different workspaces
  "${vars.mod} + shift + {1-9,0}" = "${bspwm-conf}/bspc node -d '^{1-9,10}' --follow";

  # Send to monitor
  "${vars.mod} + shift + equal" = "${bspwm-conf}/bspc node -m last --follow";

  #################
  ### Preselect ###
  #################

  # preselect the direction
  "${vars.mod} + ${vars.modAlt} + {h,j,k,l}" = "${bspwm-conf}/bspc node -p {west,south,north,east}";

  # preselect the ratio
  "${vars.mod} + ctrl + {1-9}" = "${bspwm-conf}/bspc node -o 0.{1-9}";

  # Cancel the preselect
  # For context on syntax: https://github.com/baskerville/bspwm/issues/344
  "${vars.mod} + ${vars.modAlt} + {_,shift + }Escape" = "${bspwm-conf}/bspc query -N -d | xargs -I id -n 1 ${bspwm-conf}/bspc node id -p cancel";

  "${vars.mod} + shift + Escape" = "${bspwm-conf}/bspc node -p cancel"; # cancel the preselection for the focused node

  # Set the node flags
  "${vars.mod} + ctrl + {m,x,s,p}" = "${bspwm-conf}/bspc node -g {marked,locked,sticky,private}";

  "${vars.mod} + y" = "${bspwm-conf}/bspc node @parent -R 90";
  "${vars.mod} + r" = "${bspwm-conf}/bspc node @focused:/ --rotate 90";
  "${vars.mod} + shift + r" = "${bspwm-conf}/bspc node @focused:/ --rotate 180";

  # Rotate tree
  "${vars.mod} + shift + {d,a}" = "${bspwm-conf}/bspc node @/ -C {forward,backward}";

  # Send the newest marked node to the newest preselected node
  "${vars.mod} + shift + y" = "${bspwm-conf}/bspc node newest.marked.local -n newest.!automatic.local";

  "${vars.mod} + s : {h,j,k,l}" = ''
    STEP=30; SELECTION={1,2,3,4}; \
    ${bspwm-conf}/bspc node -z $(echo "left -$STEP 0,bottom 0 $STEP,top 0 -$STEP,right $STEP 0" | cut -d',' -f$SELECTION) || \
    ${bspwm-conf}/bspc node -z $(echo "right -$STEP 0,top 0 $STEP,bottom 0 -$STEP,left $STEP 0" | cut -d',' -f$SELECTION)
  '';

  ##############
  ### Helper ###
  ##############
  #Show keybind cheatsheet";

  "${vars.modAlt} + F1" = "${config.programs.rofi.package}/bin/rofi  -dmenu -i -p 'Hotkeys 󰄾' < ${config.xdg.configHome}/sxhkd/sxhkdrc | ${pkgs.choose}/bin/choose -f ' => ' 2 | ${pkgs.bash}/bin/bash";

  ##############
  ### jgmenu ###
  ##############
  "~button3" = "${pkgs.xqp}/bin/xqp 0 $(${pkgs.xdo}/bin/xdo id -N Bspwm -n root) && ${pkgs.jgmenu}/bin/jgmenu --csv-file=$HOME/.config/jgmenu/scripts/menu.txt --config-file=$HOME/.config/jgmenu/jgmenurc";
  ###################
  ### Move/Resize ###
  ###################

  # expand a window by moving one of its side outward
  "ctrl + ${vars.modAlt} +  {Left,Down,Up,Right}" = ''
    ${bspwm-conf}/bspc node -z {left -20 0 || ${bspwm-conf}/bspc node -z right -20 0, \
      bottom 0 20 || ${bspwm-conf}/bspc node -z top 0 20,\
      top 0 -20 || ${bspwm-conf}/bspc node -z bottom 0 -20,\
      right 20 0 || ${bspwm-conf}/bspc node -z left 20 0}
  '';

  # move a floating window
  "${vars.mod} + {Left,Down,Up,Right}" = "${bspwm-conf}/bspc node -v {-20 0,0 20,0 -20,20 0}";

  "${vars.modAlt} + o" = "polybar-msg cmd toggle";
  "${vars.modAlt} + shift +x" = "i3lock-fancy -p";

  # contract a window by moving one of its side inward
  "${vars.mod} + ${vars.modAlt} + shift + {h,j,k,l}" = "${bspwm-conf}/bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";

  # move a floating window
  #"${vars.mod} + {Left,Down,Up,Right}" = "${bspwm-conf}//bspc node -v {-20 0,0 20,0 -20,20 0}"

  ## Move floating windows
  "${vars.modAlt} + shift + {Left,Down,Up,Right}" = "${bspwm-conf}/bspc node -v {-20 0,0 20,0 -20,20 0}";

  ####################
  ### Control Keys ###
  ####################

  ### PulseAudio ###

  # XF86AudioMute = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle%";
  # XF86AudioRaiseVolume = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
  # XF86AudioLowerVolume = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";

  ### Wireplumber ###

  # XF86AudioMute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  # "{XF86AudioRaiseVolume, XF86AudioLowerVolume}" = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%{+,-}";
  # XF86AudioMicMute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

  ### Script ###

  XF86AudioRaiseVolume = "${orpheus_raise-volume}/bin/orpheus_raise-volume";
  XF86AudioLowerVolume = "${orpheus_lower-volume}/bin/orpheus_lower-volume";
  XF86AudioMute = "${orpheus_mute}/bin/orpheus_mute";

  ### Mac backlight ###
  XF86KbdBrightnessUp = "exec ${pkgs.kbdlight}/bin/kbdlight up 5";
  XF86KbdBrightnessDown = "exec ${pkgs.kbdlight}/bin/kbdlight down 5";

  ### Pamixer cmdline ###

  # XF86AudioMute = "${_ pkgs.pamixer}/bin/pamixer -t";
  # XF86AudioRaiseVolume = "${_ pkgs.pamixer}/bin/pamixer -i 2";
  # XF86AudioLowerVolume = "${_ pkgs.pamixer}/bin/pamixer -d 2"

  ### Acpilight ###

  # XF86MonBrightnessUp = "exec ${pkgs.acpilight}/bin/xbacklight -perceived -inc 5";
  # XF86MonBrightnessDown = "exec ${pkgs.acpilight}/bin/xbacklight -perceived -dec 5";

  ### Brillo ###

  XF86MonBrightnessUp = "exec ${dunst-light}/bin/dunst-light up";
  XF86MonBrightnessDown = "exec ${dunst-light}/bin/dunst-light down";
  # XF86MonBrightnessUp = "exec ${pkgs.brillo}/bin/brillo -e -A 0.2";
  # XF86MonBrightnessDown = "exec ${pkgs.brillo}/bin/brillo -e -U 0.2";

  ### Xbacklight ###

  # XF86MonBrightnessUp = "${_ pkgs.xorg.xbacklight}/bin/xbacklight + 5";
  # XF86MonBrightnessDown = "${_ pkgs.xorg.xbacklight}/bin/xbacklight - 5";

  ### PlayerCtl ###

  XF86AudioPlay = "${pkgs.playerctl}/bin/playerctl play";
  XF86AudioPause = "${pkgs.playerctl}/bin/playerctl pause";
  XF86AudioNext = "${pkgs.playerctl}/bin/playerctl next";
  XF86AudioPrev = "${pkgs.playerctl}/bin/playerctl previous";
  # "${vars.mod} + l" = "exec ${_ pkgs.systemd}/bin/loginctl lock-session";
  "${vars.mod} + n" = "exec ${pkgs.xdg-utils}/bin/xdg-open http://";

  ##################
  ### Screenshot ###
  ##################
  "Print" = "~/.config/rofi/configurations/scripts/screenshots.sh";
  "${vars.modAlt} + shift + 4" = "~/.config/rofi/configurations/scripts/screenshots.sh";
  # "Print" = "${screenshooter}/bin/screenshooter";
  # "Print" = "${pkgs.flameshot}/bin/flameshot gui";
  # "Print" = "${pkgs.rofi-screenshot}/bin/rofi-screenshot";
}
