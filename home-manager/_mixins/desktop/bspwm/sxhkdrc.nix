{ pkgs, config, lib, ... }:
let
  _ = lib.getExe;
  terminal = "${_ pkgs.alacritty}";
  filemanager = "${_ pkgs.thunar}";
  mod = "super";
in
{
  keybindings = {
    "${mod} + Return" = "${terminal}";
  };
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

  #   # alternate between the tiled and monocle layout
  #   super + m
  #   	bspc desktop -l next

  #   # send the newest marked node to the newest preselected node
  #   super + y
  #   	bspc node newest.marked.local -n newest.!automatic.local


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
}
