{ pkgs, ... }:
let
  terminal = "xfce4-terminal";
in
{
  services = {
    sxhkd = {
      enable = true;
      extraConfig = ''
        # swap the current node and the biggest window
        #super + g
          #	bspc node -s biggest.window

        # Reload polybar
        super + shift + r
          killall polybar \
          while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done \
          polybar main -c $HOME/.config/polybar/config.ini &

        ###############################################
        ################### state/flags ###############
        ###############################################

        # set the window state
        super + {t,shift + t,s,f}
          bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

        # set the node flags
        super + ctrl + {m,x,y,z}
          bspc node -g {marked,locked,sticky,private}

        ###############################################
        ################# focus/swap ##################
        ###############################################

        # focus the node in the given direction
        super + {_,shift + }{h,j,k,l}
          bspc node -{f,s} {west,south,north,east}

        # focus the node for the given path jump
        #super + {p,b,comma,period}
          #	bspc node -f @{parent,brother,first,second}

        # focus the next/previous window in the current desktop
        super + {_,shift + } n
          bspc node -f {next,prev}.local.!hidden.window

        #super + {Left,Right}
        # focus the next/previous desktop in the current monitor
        super + {_,shift + } bracket{left,right}
          bspc {desktop -f,node -d} {prev,next}.local

        # focus the older or newer node in the focus history
        super + {o,i}
          bspc wm -h off; \
          bspc node {older,newer} -f; \
          bspc wm -h on

        # focus or send to the given desktop
        super + {_,shift + }{1-9,0}
          bspc {desktop -f,node -d} '^{1-9,10}'
        ###############################################
        ################## preselect ##################
        ###############################################

        # preselect the direction
        super + ctrl + {h,j,k,l}
          bspc node -p {west,south,north,east}

        # preselect the ratio
        super + ctrl + {1-9}
          bspc node -o 0.{1-9}

        # cancel the preselection for the focused desktop
        super + ctrl + space
          bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

        # cancel the preselection for the focused node
        super + ctrl + shift + space
          bspc node -p cancel

        ###############################################
        ################ move/resize ##################
        ###############################################

        # expand a window by moving one of its side outward
        #super + alt + {h,j,k,l}
          #	bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

        # contract a window by moving one of its side inward
        super + alt + shift + {h,j,k,l}
          STEP=20; SELECTION={1,2,3,4}; \
          bspc node -z $(echo "right -$STEP 0,top 0 $STEP,bottom 0 -$STEP,left $STEP 0" | cut -d',' -f$SELECTION)

        # Expand/contract a window by moving one of its side outward/inward
        super + alt + {h,j,k,l}
          STEP=20; SELECTION={1,2,3,4}; \
          bspc node -z $(echo "left -$STEP 0,bottom 0 $STEP,top 0 -$STEP,right $STEP 0" | cut -d',' -f$SELECTION) || \
          bspc node -z $(echo "right -$STEP 0,top 0 $STEP,bottom 0 -$STEP,left $STEP 0" | cut -d',' -f$SELECTION)


        # move a floating window
        super + {Left,Down,Up,Right}
          bspc node -v {-20 0,0 20,0 -20,20 0}
      '';
      keybindings = {
        ### Apps ###
        "super + Return" = "${terminal}"; # Terminal
        "super + t" = "firefox"; # Browser
        "super + e" = "pcmanfm"; # file manager
        "super + Escape" = "pkill -USR1 -x sxhkd"; # make sxhkd reload its configuration files
        "super + @space" = "rofi -show drun -show-icons"; # program launcher
        "Print" = "flameshot gui"; # Screenshots

        ### Bspwm ###
        "super + {_,shift + }w" = "bspc node -{c,k}"; # Close or Kill
        "super + alt + {q,r}" = "bspc {quit,wm -r}"; # Exit WM / reload
        "super + m " = "bspc desktop -l next"; # alternate between the tiled and monocle layout
        "super + y" = "bspc node -n newest.!automatic"; ## send the focused node to the newest preselected node

        ### Commands ###
        "alt + w" = ''feh --randomize --bg-fill $(find ~/Pictures/wallpaper/. -name "*.png" | shuf -n1)'';

        ### Hardware ###
        "XF86AudioRaiseVolume" = "pamixer -i 5";
        "XF86AudioLowerVolume" = "pamixer -d 5";
        "XF86AudioMute" = "pamixer -t";
        "XF86AudioMicMute" = "pamixer --default-source -t";
        "XF86MonBrightnessUp" = "light -A 5";
        "XF86MonBrightnessDown" = "light -U 5";
        "XF86AudioPlay" = "mpc -q toggle";
        "XF86AudioNext" = "mpc -q next";
        "XF86AudioPrev" = "mpc -q prev";
      };
    };
  };
}
