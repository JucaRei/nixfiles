args@{ pkgs, config, lib, ... }:
let
  _ = lib.getExe;
  # alacritty-custom = nixgl pkgs.alacritty;
  terminal = "${_ vars.alacritty-custom}";
  # browser = "chromium-browser";
  browser = "${config.programs.chromium.package}/bin/chromium-browser";
  vars = import ./vars.nix { inherit pkgs config; };
  # filemanager = "thunar";
  thunar-custom = import ../../apps/file-managers/thunar.nix { inherit pkgs config; };
  # filemanager = "${_ config.thunar-custom.package}";
  filemanager = "";
  modkey = vars.mod;
  # browser = "vivaldi";

  sxhkd_helper = pkgs.writeScriptBin "sxhkd_helper" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.gawk}/bin/awk '/^[a-z]/ && last {print "<small>",$0,"\t",last,"</small>"} {last=""} /^#/{last=$0}' ~/.config/sxhkd/sxhkdrc |
    column -t -s $'\t' |
    ${pkgs.rofi}/bin/rofi -dmenu -i -markup-rows -no-show-icons'';
in
{
  "${modkey} + Return" = "${terminal}"; # Terminal
  "${modkey} + shift + Return" = "${terminal} --class='termfloat'"; # Terminal
  "alt + shift + Return" = "${terminal} --class='Alacritty','floating'"; # Terminal
  "${modkey} + b" = "${browser}"; # web-browser
  "${modkey} + shift + b" = "${browser} --new-window https://youtube.com/"; # web-browser
  "${modkey} + shift + p" = "${browser} --private-window"; # web-browser
  "${modkey} + e" = "${filemanager}";
  "${modkey} + @space" = "rofi -show drun"; # program launcher
  # calculator
  "F1" = "rofi -show calc -modi calc --no-show-match --no-sort -lines 2";
  # emoji
  "F2" = "rofi -show emoji -modi emoji";
  "alt + @slash" = "${sxhkd_helper}/bin/sxhkd_helper";

  # make sxhkd reload its configuration files:
  "ctrl + alt + escape" = ''
    pkill -USR1 -x sxhkd; \
    bspc wm -r; \
    polybar-msg cmd restart; \
    dunstify "Reload all configuration." -u low
  '';

  # quit bspwm
  "${modkey} + alt + q" = ''
    systemctl --user stop bspwm-session.target; \
    bspc quit
  '';

  ### Bspwm hotkeys
  #to change tabs ig
  # Switch to recent window
  # "alt + Tab" = "bspc node -f last.local";
  "${modkey},alt + {_,shift + }Tab" = "bspc node -f {next,prev}.local";
  "${modkey} + ctrl + {q,r}" = "bspc {quit,wm -r}"; # quit | restart
  "${modkey} + m" = "bspc desktop -l next"; # Alternate between the tiled and monocle layout
  "${modkey} + {_, alt + }m" = "bspc node -f {next, prev}.local.!hidden.window";
  "${modkey} + {_,shift + }{Left,Down,Up,Right}" = "bspc node -{f,s} {west, south,north,east}"; # Send the window to another edge of the screen
  "${modkey} + equal" = "bspc node @/ --equalize"; # Make split ratios equal
  "${modkey} + minus" = "bspc node @/ --balance"; # Make split ratios balanced
  "${modkey} + d" = ''
    bspc query --nodes -n focused.tiled && state=floating || state=tiled; \
        bspc node --state \~$state
  '';
  # rotate
  "${modkey} + r" = "bspc node @/ -R 90";
  "${modkey} + f" = "bspc node --state \~fullscreen"; # Toggle fullscreen of window
  "${modkey} + {_,shift + }q" = "bspc node -{c,k}"; # Close and kill
  "${modkey} + k" = "bspc desktop -l next"; # alternate between the tiled and monocle layout
  "alt + shift + g" = "bspc config window_gap 5";
  "alt + g" = "bspc config window_gap 0";
  # change window gap
  "${modkey} + {minus,equal}" = "bspc config -d focused window_gap $((`bspc config -d focused window_gap` {+,-} 2 ))";
  "${modkey} + g" = "bspc node -s biggest.window"; # Swap the current node and the biggest node
  "${modkey} + shift + g" = "bspc node -s biggest.window"; # Swap the current node and the biggest node

  # Alt - Move workspaces
  # "${modkey} + {Left,Right}" = "bspc desktop -f {prev,next}.local"; # Focus the next/previous desktop in the current monitor
  # "${modkey} + {_,shift +}{1-9,0}" = "bspc {desktop -f,node -d} '{1-9,10}'"; # Focus or send to the given desktop
  "${modkey} + shift + {Left,Right}" = "bspc node -d {prev,next}.local --follow"; # Send and follow to previous or next desktop

  ####################
  ### States flags ###
  ####################

  "${modkey} + shift + {t,h,f}" = "bspc node -t '~{tiled,pseudo_tiled,floating,fullscreen}'";
  "alt + f" = ''bspc node -t "~"{floating,tiled}'';
  "${modkey} + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}"; # set the node flags

  # set the node flags
  "${modkey} + ctrl + {x,y,z}" = "bspc node -g {locked,sticky,private}";

  ##################
  ### Focus/swap ###
  ##################

  # focus the node in the given direction
  "${modkey} + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";

  # focus the node for the given path jump
  "${modkey} + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}";

  # focus the next/previous node in the current desktop
  "${modkey} + {_,shift + }c" = "bspc node -f {prev,next}.local";

  # Focus left/right occupied desktop
  "${modkey} + {Left,Right}" = "bspc desktop --focus {prev,next}.occupied";

  # Focus left/right desktop
  "ctrl + alt + {Left,Right}" = "bspc desktop --focus {prev,next}";

  # Focus left/right desktop
  "ctrl + alt + {Up, Down}" = "bspc desktop --focus {prev,next}";

  # Focus left/right occupied desktop
  "${modkey} + {Up,Down}" = "bspc desktop --focus {prev,next}.occupied";
  # focus the next/previous desktop in the current monitor
  "${modkey} + bracket{left,right}" = "bspc desktop -f {prev,next}.local";

  # focus the last node/desktop
  "${modkey} + {grave,Tab}" = "bspc {node,desktop} -f last";

  # focus the older or newer node in the focus history
  "${modkey} + {o,i}" = ''
    bspc wm -h off; \
    bspc node {older,newer} -f; \
    bspc wm -h on
  '';

  # Focus or send to the given desktop
  "${modkey} + {_,shift + }{1-9,0}" = '' bspc {desktop -f,node -d} '^{1-9,10}' '';

  #################
  ### Preselect ###
  #################

  # preselect the direction
  "${modkey} + alt + {h,j,k,l}" = "bspc node -p {west,south,north,east}";

  # preselect the ratio
  "${modkey} + ctrl + {1-9}" = "bspc node -o 0.{1-9}";

  # Cancel the preselect
  # For context on syntax: https://github.com/baskerville/bspwm/issues/344
  "${modkey} + alt + {_,shift + }Escape" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel";

  "${modkey} + shift + Escape" = "bspc node -p cancel"; # cancel the preselection for the focused node

  # Set the node flags
  "${modkey} + ctrl + {m,x,s,p}" = "bspc node -g {marked,locked,sticky,private}";

  # Send the newest marked node to the newest preselected node
  "${modkey} + y" = "bspc node newest.marked.local -n newest.!automatic.local";

  ###################
  ### Move/Resize ###
  ###################

  # expand a window by moving one of its side outward
  "ctrl + alt +  {Left,Down,Up,Right}" = ''
    bspc node -z {left -20 0 || bspc node -z right -20 0, \
      bottom 0 20 || bspc node -z top 0 20,\
      top 0 -20 || bspc node -z bottom 0 -20,\
      right 20 0 || bspc node -z left 20 0}
  '';

  # move a floating window
  "${modkey} + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

  "alt + o" = "polybar-msg cmd toggle";
  "alt + shift +x" = "i3lock-fancy -p";

  # contract a window by moving one of its side inward
  "${modkey} + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";

  # move a floating window
  #"${modkey} + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}"

  ## Move floating windows
  "alt + shift + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

  ####################
  ### Control Keys ###
  ####################

  XF86AudioMute = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle%";
  # XF86AudioMute = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle%";
  XF86AudioRaiseVolume = "exec --no-startup-id ${_ pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
  XF86AudioLowerVolume = "exec --no-startup-id ${_ pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
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
  # "${modkey} + l" = "exec ${_ pkgs.systemd}/bin/loginctl lock-session";
  "${modkey} + n" = "exec ${pkgs.xdg-utils}/bin/xdg-open http://";

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
#   super + alt + m
#   	${terminal} ${pkgs.cmus}/bin/cmus

#   # file managment
#   super + e
#   	${filemanager}
#   super + alt + e
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
#   super + alt + b
#   	brave
#   super + i
#   	gtk-launch msedge-bdinhfjgphhmaolbmhcmidoadmkngbng-Default.desktop
#   super + alt + g
#   	microsoft-edge-dev github.com/druxorey
#   super + alt + y
#   	microsoft-edge-dev youtube.com
#   super + alt + w
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
#   super + alt + {7,8,9,0}
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
#   super + alt + {h,j,k,l}
#   	bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

#   # contract a window by moving one of its side inward
#   super + alt + shift + {h,j,k,l}
#   	bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

#   # move a floating window
#   super + {Left,Down,Up,Right}
#   	bspc node -v {-20 0,0 20,0 -20,20 0}
# '';
