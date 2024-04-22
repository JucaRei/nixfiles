args@{ pkgs, config, lib, ... }:
let
  _ = lib.getExe;
  terminal = "${_ vars.alacritty-custom}";
  # browser = "chromium-browser";
  browser = "${config.programs.chromium.package}/bin/chromium-browser";
  vars = import ./vars.nix { inherit pkgs config; };
  filemanager = vars.filemanager;


  sxhkd_helper = pkgs.writeScriptBin "sxhkd_helper" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.gawk}/bin/awk '/^[a-z]/ && last {print "<small>",$0,"\t",last,"</small>"} {last=""} /^#/{last=$0}' ~/.config/sxhkd/sxhkdrc |
    column -t -s $'\t' |
    ${pkgs.rofi}/bin/rofi -dmenu -i -markup-rows -no-show-icons'';
in
{
  "${vars.mod} + Return" = "${terminal}"; # Terminal
  "${vars.mod} + shift + Return" = "${terminal} --class='termfloat'"; # Terminal
  "${vars.modAlt} + shift + Return" = "${terminal} --class='Alacritty','floating'"; # Terminal
  "${vars.mod} + b" = "${browser}"; # web-browser
  "${vars.mod} + shift + b" = "${browser} --new-window https://youtube.com/"; # web-browser
  "${vars.mod} + shift + p" = "${browser} --private-window"; # web-browser
  "${vars.mod} + e" = "${filemanager}";
  # "${vars.mod} + @space" = "rofi -show drun"; # program launcher
  "${vars.mod} + @space" = "rofi -show drun -no-lazy-grab -lines 15 -width 40"; # program launcher
  # calculator
  "F1" = "rofi -show calc -modi calc --no-show-match --no-sort -lines 2";
  # emoji
  "F2" = "rofi -show emoji -modi emoji";
  "${vars.modAlt} + @slash" = "${sxhkd_helper}/bin/sxhkd_helper";

  # make sxhkd reload its configuration files:
  "ctrl + ${vars.modAlt} + escape" = ''
    pkill -USR1 -x sxhkd;
  '';

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
  "${vars.mod} + d" = ''
    bspc query --nodes -n focused.tiled && state=floating || state=tiled; \
        bspc node --state \~$state
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
  "${vars.mod} + bracket{left,right}" = "bspc desktop -f {prev,next}.local";

  # focus the last node/desktop
  "${vars.mod} + {grave,Tab}" = "bspc {node,desktop} -f last";

  # focus the older or newer node in the focus history
  "${vars.mod} + {o,i}" = ''
    bspc wm -h off; \
    bspc node {older,newer} -f; \
    bspc wm -h on
  '';

  # Switch to different workspaces with back-and-forth support
  "${vars.mod} + {1-9,0}" = ''
    desktop='^{1-9,10}'; \
          bspc query -D -d "$desktop.focused" && bspc desktop -f last || bspc desktop -f "$desktop"
  '';

  # Scratchpad
  "${vars.mod} + z" = "bspc node focused -t floating; bspc node -d '^12'";
  "alt + Tab" = "rofi -show window -window-thumbnail";

  # Move windows to different workspaces
  "${vars.mod} + shift + {1-9,0}" = "bspc node -d ^{1-9,10}";

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

  # Send the newest marked node to the newest preselected node
  "${vars.mod} + shift + y" = "bspc node newest.marked.local -n newest.!automatic.local";

  "${vars.mod} + s : {h,j,k,l}" = ''
    STEP=30; SELECTION={1,2,3,4}; \
    bspc node -z $(echo "left -$STEP 0,bottom 0 $STEP,top 0 -$STEP,right $STEP 0" | cut -d',' -f$SELECTION) || \
    bspc node -z $(echo "right -$STEP 0,top 0 $STEP,bottom 0 -$STEP,left $STEP 0" | cut -d',' -f$SELECTION)
  '';

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

  # XF86AudioMute = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle%";
  XF86AudioMute = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle%";
  XF86AudioRaiseVolume = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
  XF86AudioLowerVolume = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
  # "{XF86AudioRaiseVolume, XF86AudioLowerVolume}" = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%{+,-}";
  XF86AudioMicMute = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-source-mute 0 toggle%";
  # XF86AudioMicMute = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-source-mute 0 toggle%";
  # XF86AudioMute = "${_ pkgs.pamixer}/bin/pamixer -t";
  XF86MonBrightnessUp = "exec --no-startup-id ${pkgs.acpilight}/bin/xbacklight -perceived -inc 5";
  XF86MonBrightnessDown = "exec --no-startup-id ${pkgs.acpilight}/bin/xbacklight -perceived -dec 5";
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
}
# keybindings = ''
#   #! =================================================================== !#
#   #!                               general                               !#
#   #! =================================================================== !#

#   #* ============================== system ============================= *#

#   # increase audio volume
#   XF86AudioRaiseVolume
#   	pactl set-sink-volume @DEFAULT_SINK@ +5%

#   # decrease audio volume
#   XF86AudioLowerVolume
#   	pactl set-sink-volume @DEFAULT_SINK@ -5%

#   # mute audio volume
#   XF86AudioMute
#   	pactl set-sink-mute @DEFAULT_SINK@ toggle

#   # mute mic
#   XF86AudioMicMute
#   	amixer -D pulse sset Capture toggle

#   # increase brightness
#   XF86MonBrightnessUp
#   	brightnessctl set +5%

#   # decrease brightness
#   XF86MonBrightnessDown
#   	brightnessctl set 5%-

#   # activate night light
#   shift + XF86MonBrightnessUp
#   	${pkgs.redshift}/bin/redshift -O 3000

#   # desactivate night light
#   shift + XF86MonBrightnessDown
#   	${pkgs.redshift}/bin/redshift -x
#   # print the full screen
#   @Print
#   	${pkgs.scrot}/bin/scrot ~/Pictures/Screenshots/%Y-%m-%d_%H%M%S.png

#   # print a selected area
#   super + Print
#   	${pkgs.scrot}/bin/scrot -s --line mode=edge ~/Pictures/Screenshots/%Y-%m-%d_%H%M%S.png

#   # app launcher
#   Home
#   	rofi -show drun

#   #* =========================== applications ========================== *#

#   # alacritty
#   super + Return
#   	${terminal}
#   super + ${vars.modAlt} + m
#   	${terminal} ${pkgs.cmus}/bin/cmus

#   # file managment
#   super + e
#   	${filemanager}
#   super + ${vars.modAlt} + e
#   	${filemanager} smb://192.168.1.207/

#   # file editor
#   super + c
#   	code
#   super + v
#   	${terminal} nvim

#   # independent apps
#   super + d
#   	discord
#   super + s
#   	steam
#   super + n
#   	notion-app
#   super + o
#   	obsidian

#   # browser
#   super + b
#   	microsoft-edge-dev
#   super + ${vars.modAlt} + b
#   	brave
#   super + i
#   	gtk-launch msedge-bdinhfjgphhmaolbmhcmidoadmkngbng-Default.desktop
#   super + ${vars.modAlt} + g
#   	microsoft-edge-dev github.com/druxorey
#   super + ${vars.modAlt} + y
#   	microsoft-edge-dev youtube.com
#   super + ${vars.modAlt} + w
#   	microsoft-edge-dev web.whatsapp.com

#   #! =================================================================== !#
#   #!                                bspwm                                !#
#   #! =================================================================== !#

#   super + Escape
#   	pkill -USR1 -x sxhkd

#   # close and kill
#   super + {_,shift + }w
#   	bspc node -{c,k}






#   #* =========================== states/flags ========================== *#

#   # set the window state
#   super + ${vars.modAlt} + {7,8,9,0}
#   	bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

#   # set the node flags
#   super + ctrl + {m,x,y,z}
#   	bspc node -g {marked,locked,sticky,private}

#   #* ============================ focus/swap =========================== *#

#   # focus the node in the given direction
#   super + {_,shift + }{h,j,k,l}
#   	bspc node -{f,s} {west,south,north,east}

#   # focus the node for the given path jump
#   super + {p,b,comma,period}
#   	bspc node -f @{parent,brother,first,second}

#   # focus the next/previous window in the current desktop
#   super + Tab
#   	bspc node -f {next,prev}.local.!hidden.window

#   # focus the next/previous desktop in the current monitor
#   super + bracket{left,right}
#   	bspc desktop -f {prev,next}.local

#   # focus the last node/desktop
#   super + {grave,shift grave}
#   	bspc {node,desktop} -f last

#   # focus or send to the given desktop
#   super + {_,shift + }{1-5,9,0}
#   	bspc {desktop -f,node -d} '^{1-9,10}'

#   #* ============================= preselect =========================== *#

#   # preselect the direction
#   super + ctrl + {h,j,k,l}
#   	bspc node -p {west,south,north,east}

#   # preselect the ratio
#   super + ctrl + {1-9}
#   	bspc node -o 0.{1-9}

#   # cancel the preselection for the focused node
#   super + ctrl + space
#   	bspc node -p cancel

#   # cancel the preselection for the focused desktop
#   super + ctrl + shift + space
#   	bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

#   #* =========================== move/resize =========================== *#

#   # expand a window by moving one of its side outward
#   super + ${vars.modAlt} + {h,j,k,l}
#   	bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

#   # contract a window by moving one of its side inward
#   super + ${vars.modAlt} + shift + {h,j,k,l}
#   	bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

#   # move a floating window
#   super + {Left,Down,Up,Right}
#   	bspc node -v {-20 0,0 20,0 -20,20 0}
# '';
