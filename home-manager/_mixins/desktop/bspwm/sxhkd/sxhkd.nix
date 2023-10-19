_: {
  services = {
    sxhkd = {
      enable = true;
      keybindings = {
        "super + Return" = "kitty"; # terminal emulator
        "super + @space" = "rofi -show drun -show-icons"; # program launcher
        "super + Escape" = "pkill -USR1 -x sxhkd"; # make sxhkd reload its configuration files

        # Bspwm hotkeys
        "super + alt + {q,r}" = "bscp {quit,wm -r}"; #quit/restart bspwm
        "alt + {F4, Shift + F4}" = "bspc node -{c,k}"; # close and kill
        "super + m" = "bspc desktop -l next"; # alternate between the tiled and monocle layout
        "super + y" = "bspc node newest.marked.local -n newest.!automatic.local"; ## send the newest marked node to the newest preselected node
        "super + g" = "bspc node -s biggest.window"; # swap the current node and the biggest window

        # State/flags
        "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}"; # set the window state
        "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}"; # set the node flags

        # Focus/Swap
        "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}"; # focus the node in the given direction
        "super + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}"; # focus the node for the given path jump
        "super + {_,shift + }c" = "bspc node -f {next,prev}.local.!hidden.window"; # focus the next/previous window in the current desktop
        "super + bracket{left,right}" = "bspc desktop -f {prev,next}.local"; # focus the next/previous desktop in the current monitor
        "super + {grave,Tab}" = "bspc {node,desktop} -f last"; # focus the last node/desktop
        "super + {o,i}" = "bspc wm -h off; \n bspc node {older,newer} -f; \n bspc wm -h on"; # focus the older or newer node in the focus history
        "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'"; # focus or send to the given desktop

        # Preselect
        "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}"; # preselect the direction
        "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}"; # preselect the ratio
        "super + ctrl + space" = "bspc node -p cancel"; # cancel the preselection for the focused node
        "super + ctrl + shift + space" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel"; # cancel the preselection for the focused desktop

        # Move/Resize
        "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}"; # expand a window by moving one of its side outward
        "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}"; # contract a window by moving one of its side inward
        "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}"; ## move a floating window

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
        # Volume Up
        "XF86AudioRaiseVolume" = "amixer sset Master 5%+ && $HOME/.config/eww/Misc/scripts/volume";

        # Volume Down
        "XF86AudioLowerVolume" = "amixer sset Master 5%- && $HOME/.config/eww/Misc/scripts/volume";

        # Volume Mute
        "XF86AudioMute" = "amixer sset Master toggle && $HOME/.config/eww/Misc/scripts/volume";

        # Brightness Up
        "XF86MonBrightnessUp" = "brightnessctl s 20+ && $HOME/.config/eww/Misc/scripts/brightness";

        # Brightness Down
        "XF86MonBrightnessDown" = "brightnessctl s 20- && $HOME/.config/eww/Misc/scripts/brightness";

        # Toggle right click context menu.
        "~button3" = "xqp 0 $(xdo id -N Bspwm -n root) && jgmenu_run";
      };
    };
  };
}