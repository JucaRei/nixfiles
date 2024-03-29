_: {
  services = {
    sxhkd = {
      enable = true;
      keybindings = {
        ### Apps put applications selected
        # "super + Return" = "alacritty"; # terminal emulator
        # "super + @space" = "rofi -show drun -show-icons"; # program launcher
        # "super + Escape" = "pkill -USR1 -x sxhkd"; # make sxhkd reload its configuration files
        # "super + e" = "nemo";
        # "super + b" = "thorium";

        # Bspwm hotkeys
        "super + alt + {q,r}" = "bscp {quit,wm -r}"; # quit/restart bspwm
        "super + {_,shift +}{Left,Right,Up,Down}" = "bspc node -{f,s} {west,east,north,south}"; # Focus or move node in given direction
        "super + {t,h,f}" = "bspc node -t '~{tiled,floating,fullscreen}'"; # Toggle between initial state and new state
        # "alt + {F4, Shift + F4}" = "bspc node -{c,k}"; # close and kill
        "super + w" = "bspc node -{c,k}"; # close and kill
        "super + m" = "bspc desktop -l next"; # alternate between the tiled and monocle layout
        "super + y" = "bspc node newest.marked.local -n newest.!automatic.local"; # # send the newest marked node to the newest preselected node
        "super + g" = "bspc node -s biggest.window"; # swap the current node and the biggest window

        # Alt - Move workspaces
        "alt + {Left,Right}" = "bspc desktop -f {prev,next}.local"; # Focus the next/previous desktop in the current monitor
        "alt + {_,shift +}{1-9,0}" = "bspc {desktop -f,node -d} '{1-9,10}'"; # Focus or send to the given desktop
        "alt + shift + {Left,Right}" = "bspc node -d {prev,next}.local --follow"; # Send and follow to previous or next desktop

        # State/flags
        # "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}"; # set the window state
        "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}"; # set the node flags

        # Focus/Swap
        "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}"; # focus the node in the given direction
        "super + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}"; # focus the node for the given path jump
        "super + {_,shift + }c" = "bspc node -f {next,prev}.local.!hidden.window"; # focus the next/previous window in the current desktop
        "super + bracket{left,right}" = "bspc desktop -f {prev,next}.local"; # focus the next/previous desktop in the current monitor
        "super + {grave,Tab}" = "bspc {node,desktop} -f last"; # focus the last node/desktop
        "super + {o,i}" = ''
          bspc wm -h off; 
           bspc node {older,newer} -f; 
           bspc wm -h on''; # focus the older or newer node in the focus history
        # "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'"; # focus or send to the given desktop

        # Preselect
        "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}"; # preselect the direction
        "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}"; # preselect the ratio
        "super + ctrl + space" = "bspc node -p cancel"; # cancel the preselection for the focused node
        "super + ctrl + shift + space" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel"; # cancel the preselection for the focused desktop

        # Move/Resize
        # "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}"; # expand a window by moving one of its side outward
        # "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}"; # contract a window by moving one of its side inward
        # "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}"; ## move a floating window

        # Control - Resize
        "control + super +  {Left,Down,Up,Right}" = ''
          bspc node -z {left -20 0 || bspc node -z right -20 0, \
                        bottom 0 20 || bspc node -z top 0 20,\
                        top 0 -20 || bspc node -z bottom 0 -20,\
                        right 20 0 || bspc node -z left 20 0}
        '';

        # Play music
        "XF86AudioPlay" = "playerctl play";

        # Pause music
        "XF86AudioPause" = "playerctl pause";

        # Music next
        "XF86AudioNext" = "playerctl next";

        # Music previous
        "XF86AudioPrev" = "playerctl previous";

        # Screenshot Area
        "Print" = "$HOME/Pictures/Screenshots --area-cb";

        # Screenshot Full
        "shift + Print" = "$HOME/Pictures/Screenshots --full-cb";

        # Switch windows
        "alt + Tab" = "bash ~/.config/rofi/window-switcher/window-switcher.sh";

        # Save screenshot to file with clipboard
        "ctrl + shift + Print" = "$HOME/Pictures/Screenshots --full";

        # Screenshot Area and save it
        "ctrl + Print" = "$HOME/Pictures/Screenshots - -area";

        # XF86 Keys
        "XF86AudioMute" = "pactl list sinks | grep -q Mute:.no && pactl set-sink-mute 0 1 || pactl set-sink-mute 0 0"; # Toggle mute audio
        "XF86AudioRaiseVolume" = "pactl -- set-sink-volume 0 +2%"; # Raise volume
        "XF86AudioLowerVolume" = "pactl -- set-sink-volume 0 -2%"; # Lower volume
        "XF86AudioMicMute" = "pactl set-source-mute 1 toggle"; # Toggle mute mic audio
        "XF86KbdBrightnessUp" = "kbdlight up 2";
        "XF86KbdBrightnessDown" = "kbdlight down 2";
        #"XF86MonBrightnessUp" = "xbacklight -inc 2"; # Brightness down
        #"XF86MonBrightnessDown" = "xbacklight -dec 2"; # Brightness down
        "XF86MonBrightnessUp" = "light -A 2"; # Brightness up
        "XF86MonBrightnessDown" = "light -U 2"; # Brightness down
        # "XF86MonBrightnessDown" = "light -U  5"; # Brightness down
        # "XF86MonBrightnessUp" = "light -A 5";

        # Volume Up
        # "XF86AudioRaiseVolume" = "amixer sset Master 5%+ && $HOME/.config/eww/Misc/scripts/volume";

        # Volume Down
        # "XF86AudioLowerVolume" = "amixer sset Master 5%- && $HOME/.config/eww/Misc/scripts/volume";

        # Volume Mute
        # "XF86AudioMute" = "amixer sset Master toggle && $HOME/.config/eww/Misc/scripts/volume";

        # Brightness Up
        # "XF86MonBrightnessUp" = "brightnessctl s 20+ && $HOME/.config/eww/Misc/scripts/brightness";

        # Brightness Down
        # "XF86MonBrightnessDown" = "brightnessctl s 20- && $HOME/.config/eww/Misc/scripts/brightness";

        # Toggle right click context menu.
        "~button3" = "xqp 0 $(xdo id -N Bspwm -n root) && jgmenu_run";
      };
    };
  };
}
