args@{ pkgs, config, lib, hostname, ... }:
let
  _ = lib.getExe;
  terminal = "${_ vars.alacritty-custom}";
  browser = "brave";
  # browser = "${config.programs.chromium.package}/bin/chromium-browser";
  vars = import ./vars.nix { inherit pkgs config hostname; };
  filemanager = vars.filemanager;

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
  "${vars.mod} + b" = "${browser}"; # web-browser
  "${vars.mod} + shift + b" = "${browser} --new-window https://youtube.com/"; # web-browser
  "${vars.mod} + shift + p" = "${browser} --private-window"; # web-browser
  "${vars.mod} + e" = "${filemanager}";
  # "${vars.mod} + @space" = "rofi -show drun"; # program launcher
  "${vars.mod} + @space" = "rofi -show drun -show-icons -no-lazy-grab -lines 15 -width 40"; # program launcher
  # calculator
  "F1" = "rofi -show calc -modi calc --no-show-match --no-sort -lines 2";
  # emoji
  "F2" = "rofi -show emoji -modi emoji";
  # "${vars.modAlt} + @slash" = "${sxhkd_helper}/bin/sxhkd_helper";

  # make sxhkd reload its configuration files:
  "${vars.modAlt} + Escape" = "${pkgs.procps}/bin/pkill -USR1 -x sxhkd; ${pkgs.libnotify}/bin/notify-send 'sxhkd' 'Reloaded config'";

  #   bspc wm -r; \
  #   polybar-msg cmd restart; \
  #   dunstify "Reload all configuration." -u low
  # '';

  # quit bspwm
  "${vars.mod} + ${vars.modAlt} + q" = ''
    systemctl --user stop bspwm-session.target; \
    bspc quit
  '';

  ### Bspwm hotkeys
  #to change tabs ig
  # Switch to recent window
  # "${vars.modAlt} + Tab" = "bspc node -f last.local";
  "${vars.mod},${vars.modAlt} + {_,shift + }Tab" = "bspc node -f {next,prev}.local";
  "${vars.mod} + ctrl + {q,r}" = "bspc {quit,wm -r}"; # quit | restart
  "${vars.mod} + m" = "bspc desktop -l next"; # ${vars.modAlt}ernate between the tiled and monocle layout
  "${vars.mod} + {_, ${vars.modAlt} + }m" = "bspc node -f {next, prev}.local.!hidden.window";
  "${vars.mod} + {_,shift + }{Left,Down,Up,Right}" = "bspc node -{f,s} {west, south,north,east}"; # Send the window to another edge of the screen
  "${vars.mod} + equal" = "bspc node @/ --equalize"; # Make split ratios equal
  "${vars.mod} + minus" = "bspc node @/ --balance"; # Make split ratios balanced
  "${vars.modAlt} + d" = ''
    bspc node focused -t \~floating
  '';
  # rotate
  "${vars.mod} + f" = "bspc node --state \~fullscreen"; # Toggle fullscreen of window
  "${vars.mod} + {_,shift + }q" = "bspc node -{c,k}"; # Close and kill
  "${vars.mod} + k" = "bspc desktop -l next"; # ${vars.modAlt}ernate between the tiled and monocle layout
  "${vars.modAlt} + shift + g" = "bspc config window_gap 5";
  "${vars.modAlt} + g" = "bspc config window_gap 0";
  # change window gap
  "${vars.mod} + {minus,equal}" = "bspc config -d focused window_gap $((`bspc config -d focused window_gap` {+,-} 2 ))";
  # "${vars.mod} + g" = "bspc node -s biggest.window"; # Swap the current node and the biggest node
  # "${vars.mod} + shift + g" = "bspc node -s biggest.window"; # Swap the current node and the biggest node

  "${vars.mod} + g" = ''if [ \"$(bspc config window_gap)\" -eq 0 ]; then bspc config window_gap 12; bspc config border_width 2; else bspc config window_gap 0; bspc config border_width 0; fi'';

  # Move current window to a pre-selected space
  "${vars.mod} + shift + m" = "bspc node -n last.!automatic";

  "${vars.mod} + {_,shift} + {u,i}" = "bspc {monitor -f,node -m} {prev,next}"; # focus or send to the next monitor

  # ${vars.modAlt} - Move workspaces
  # "${vars.mod} + {Left,Right}" = "bspc desktop -f {prev,next}.local"; # Focus the next/previous desktop in the current monitor
  # "${vars.mod} + {_,shift +}{1-9,0}" = "bspc {desktop -f,node -d} '{1-9,10}'"; # Focus or send to the given desktop
  "${vars.mod} + shift + {Left,Right}" = "bspc node -d {prev,next}.local --follow"; # Send and follow to previous or next desktop

  ####################
  ### States flags ###
  ####################

  "${vars.mod} + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,\~fullscreen}";
  "${vars.modAlt} + f" = ''bspc node -t "~"{floating,tiled}'';
  "${vars.mod} + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}"; # set the node flags

  # set the node flags
  "${vars.mod} + ctrl + {x,y,z}" = "bspc node -g {locked,sticky,private}";

  ##################
  ### Focus/swap ###
  ##################

  # focus the node in the given direction
  "${vars.mod} + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";

  # focus the node for the given path jump
  "${vars.mod} + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}";

  # focus the next/previous node in the current desktop
  "${vars.mod} + {_,shift + }c" = "bspc node -f {prev,next}.local";

  # Focus left/right occupied desktop
  "${vars.mod} + {Left,Right}" = "bspc desktop --focus {prev,next}.occupied";

  # Focus left/right desktop
  "ctrl + ${vars.modAlt} + {Left,Right}" = "bspc desktop --focus {prev,next}";

  # Focus left/right desktop
  "ctrl + ${vars.modAlt} + {Up, Down}" = "bspc desktop --focus {prev,next}";

  # Focus left/right occupied desktop
  "${vars.mod} + {Up,Down}" = "bspc desktop --focus {prev,next}.occupied";
  # focus the next/previous desktop in the current monitor
  # "${vars.mod} + bracket{left,right}" = "bspc desktop -f {prev,next}.local";
  "${vars.mod} + Left" = "bspc desktop -f prev.local";
  "${vars.mod} + Right" = "bspc desktop -f next.local";

  # focus the last node/desktop
  "${vars.mod} + {grave,Tab}" = "bspc {node,desktop} -f last";

  # focus the older or newer node in the focus history
  "${vars.mod} + {o,i}" = ''
    bspc wm -h off; \
    bspc node {older,newer} -f; \
    bspc wm -h on
  '';

  # Switch to different workspaces with back-and-forth support
  "${vars.mod} + {1-9,0}" = "bspc desktop -f '^{1-9,10}'";

  # alternate between the tiled and monocle layout
  "${vars.modAlt} + m" = "bspc desktop -l next";

  # Scratchpad
  "${vars.mod} + z" = "bspc node focused -t floating; bspc node -d '^12'";
  # Scratchpad
  # "super + alt + o" = "${pkgs.tdrop}/bin/tdrop -a -w 70% -h 35% -y 0 -x 15%  --class scratch alacritty --class=scratch";
  "alt + Tab" = "rofi -show window -window-thumbnail";

  # Move windows to different workspaces
  "${vars.mod} + shift + {1-9,0}" = "bspc node -d '^{1-9,10}' --follow";

  # Send to monitor
  "${vars.mod} + shift + equal" = "bspc node -m last --follow";

  #################
  ### Preselect ###
  #################

  # preselect the direction
  "${vars.mod} + ${vars.modAlt} + {h,j,k,l}" = "bspc node -p {west,south,north,east}";

  # preselect the ratio
  "${vars.mod} + ctrl + {1-9}" = "bspc node -o 0.{1-9}";

  # Cancel the preselect
  # For context on syntax: https://github.com/baskerville/bspwm/issues/344
  "${vars.mod} + ${vars.modAlt} + {_,shift + }Escape" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel";

  "${vars.mod} + shift + Escape" = "bspc node -p cancel"; # cancel the preselection for the focused node

  # Set the node flags
  "${vars.mod} + ctrl + {m,x,s,p}" = "bspc node -g {marked,locked,sticky,private}";

  "${vars.mod} + y" = "bspc node @parent -R 90";
  "${vars.mod} + r" = "bspc node @focused:/ --rotate 90";
  "${vars.mod} + shift + r" = "bspc node @focused:/ --rotate 180";

  # Rotate tree
  "${vars.mod} + shift + {d,a}" = "bspc node @/ -C {forward,backward}";

  # Send the newest marked node to the newest preselected node
  "${vars.mod} + shift + y" = "bspc node newest.marked.local -n newest.!automatic.local";

  "${vars.mod} + s : {h,j,k,l}" = ''
    STEP=30; SELECTION={1,2,3,4}; \
    bspc node -z $(echo "left -$STEP 0,bottom 0 $STEP,top 0 -$STEP,right $STEP 0" | cut -d',' -f$SELECTION) || \
    bspc node -z $(echo "right -$STEP 0,top 0 $STEP,bottom 0 -$STEP,left $STEP 0" | cut -d',' -f$SELECTION)
  '';

  ##############
  ### Helper ###
  ##############
  #Show keybind cheatsheet";

  "${vars.modAlt} + F1" = "${config.programs.rofi.package}/bin/rofi  -dmenu -i -p 'Hotkeys 󰄾' < ${config.xdg.configHome}/sxhkd/sxhkdrc | ${pkgs.choose}/bin/choose -f ' => ' 2 | ${pkgs.bash}/bin/bash";

  ##############
  ### jgmenu ###
  ##############
  "~button3" = "${pkgs.xqp}/bin/xqp 0 $(${pkgs.xdo}/bin/xdo id -N Bspwm -n root) && ${pkgs.jgmenu}/bin/jgmenu --csv-file=~/.config/jgmenu/scripts/menu.txt --config-file=~/.config/jgmenu/jgmenurc";
  ###################
  ### Move/Resize ###
  ###################

  # expand a window by moving one of its side outward
  "ctrl + ${vars.modAlt} +  {Left,Down,Up,Right}" = ''
    bspc node -z {left -20 0 || bspc node -z right -20 0, \
      bottom 0 20 || bspc node -z top 0 20,\
      top 0 -20 || bspc node -z bottom 0 -20,\
      right 20 0 || bspc node -z left 20 0}
  '';

  # move a floating window
  "${vars.mod} + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

  "${vars.modAlt} + o" = "polybar-msg cmd toggle";
  "${vars.modAlt} + shift +x" = "i3lock-fancy -p";

  # contract a window by moving one of its side inward
  "${vars.mod} + ${vars.modAlt} + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";

  # move a floating window
  #"${vars.mod} + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}"

  ## Move floating windows
  "${vars.modAlt} + shift + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

  ####################
  ### Control Keys ###
  ####################

  # XF86AudioMute = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle%";
  # XF86AudioRaiseVolume = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
  # XF86AudioLowerVolume = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
  # XF86AudioMute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  # "{XF86AudioRaiseVolume, XF86AudioLowerVolume}" = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%{+,-}";
  # XF86AudioMicMute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

  XF86AudioRaiseVolume = "${orpheus_raise-volume}/bin/orpheus_raise-volume";
  XF86AudioLowerVolume = "${orpheus_lower-volume}/bin/orpheus_lower-volume";
  XF86AudioMute = "${orpheus_mute}/bin/orpheus_mute";


  # XF86AudioMicMute = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-source-mute 0 toggle%";
  # XF86AudioMute = "${_ pkgs.pamixer}/bin/pamixer -t";
  # XF86MonBrightnessUp = "exec ${pkgs.acpilight}/bin/xbacklight -perceived -inc 5";
  # XF86MonBrightnessDown = "exec ${pkgs.acpilight}/bin/xbacklight -perceived -dec 5";
  XF86MonBrightnessUp = "exec ${pkgs.brillo}/bin/brillo -e -A 0.5";
  XF86MonBrightnessDown = "exec ${pkgs.brillo}/bin/brillo -e -U 0.5";
  # XF86AudioRaiseVolume = "${_ pkgs.pamixer}/bin/pamixer -i 2";
  # XF86AudioLowerVolume = "${_ pkgs.pamixer}/bin/pamixer -d 2";
  # XF86MonBrightnessUp = "${_ pkgs.xorg.xbacklight}/bin/xbacklight + 5";
  # XF86MonBrightnessDown = "${_ pkgs.xorg.xbacklight}/bin/xbacklight - 5";
  XF86AudioPlay = "${pkgs.playerctl}/bin/playerctl play";
  XF86AudioPause = "${pkgs.playerctl}/bin/playerctl pause";
  XF86AudioNext = "${pkgs.playerctl}/bin/playerctl next";
  XF86AudioPrev = "${pkgs.playerctl}/bin/playerctl previous";
  # "${vars.mod} + l" = "exec ${_ pkgs.systemd}/bin/loginctl lock-session";
  "${vars.mod} + n" = "exec ${pkgs.xdg-utils}/bin/xdg-open http://";

  ##################
  ### Screenshot ###
  ##################
  "Print" = "${pkgs.flameshot}/bin/flameshot gui";
  # "Print" = "${pkgs.rofi-screenshot}/bin/rofi-screenshot";
}
