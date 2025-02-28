{ pkgs, lib, config, hostname, ... }:
let
  vars = import ../vars.nix { inherit pkgs config hostname; };
  # isNitro = if (hostname == "nitro") then "1920x1080" else "1366x768";
  isNitrO = if (hostname == "nitro") then "${vars.mod}" else "${vars.modAlt}";

  inherit (lib) getExe getExe';

  bspc = lib.getExe' config.xsession.windowManager.bspwm.package "bspc";
  exe = getExe;
  exe' = getExe';
in
{
  services = {
    sxhkd = {
      enable = true;
      package = pkgs.sxhkd;
      keybindings = {
        ### terminal emulator ###
        "${vars.mod} + Return" = "alacritty";
        "${vars.mod} + shift + Return" = "${vars.terminal} --class='termfloat'";
        ### Browser ###
        "${vars.mod} + b" = "${vars.browser}";
        "${vars.mod} + shift + b" = lib.mkDefault "${vars.browser} --new-window https://youtube.com/"; # web-browser
        "${vars.mod} + shift + p" = lib.mkDefault "${vars.browser} --private-window"; # private window
        ### File Manager ###
        "${vars.mod} + e" = lib.mkDefault "${vars.filemanager}";
        ### Picom ###
        "${vars.modAlt} + shift + p" = "${exe pkgs.picom-toggle}"; # Enable/Disable Picom
        ### BSP-Layout ###
        "${vars.modAlt} + shift + v" = "${exe pkgs.bsp-layout} next";
        "${vars.modAlt} + shift + b" = "${exe pkgs.bsp-layout} previous";
        ### Rofi ###
        "${vars.modAlt} + @space" = "${exe config.programs.rofi.package} -config -no-lazy-grab -show drun -modi drun -theme $HOME/.config/rofi/configurations/Themes/Forest/launcher.rasi"; # program launcher
        "F1" = "${exe config.programs.rofi.package} -show calc -modi calc --no-show-match --no-sort -lines 2"; # calculator
        "F3" = "${exe config.programs.rofi.package} -show emoji -modi emoji"; # emoji
        ### Reload Configuration ###
        "${vars.modAlt} + Escape" = "${exe' pkgs.procps "pkill"} -USR1 -x sxhkd; ${bspc} wm -r; ${pkgs.libnotify}/bin/notify-send 'Sxhkd & Polybar' 'Reloaded config'";
        ### Quit BSPWM ###
        "${vars.mod} + ${vars.modAlt} + q" = ''
          systemctl --user stop bspwm-session.target; \
          ${bspc} quit
        '';
        ### BSPWM Hotkeys ###
        "${vars.mod},${vars.modAlt} + {_,shift + }Tab" = "${bspc} node -f {next,prev}.loca+l";
        "${vars.mod} + ctrl + q" = "${pkgs.systemdMinimal}/bin/systemctl --user stop bspwm-session.target; \\n
          ${bspc} quit";
        "${vars.mod} + ctrl + r" = "${bspc} wm -r"; # quit | restart
        "${vars.mod} + m" = "${bspc} desktop -l next"; # Alternate between the tiled and monocle layout
        "${vars.mod} + {_, ${vars.modAlt} + }m" = "${bspc} node -f {next, prev}.local.!hidden.window";
        "${vars.mod} + {_,shift + }{Left,Down,Up,Right}" = "${bspc} node -{f,s} {west, south,north,east}"; # Send the window to another edge of the screen
        # "${vars.mod} + equal" = "${bspc} node @/ --equalize"; # Make split ratios equal
        # "${vars.mod} + minus" = "${bspc} node @/ --balance"; # Make split ratios balanced
        "${vars.mod} + {minus,equal}" = "${bspc} config -d focused window_gap $((`${bspc} config -d focused window_gap` {+,-} 2 ))";
        "${isNitrO} + shift + d" = if (hostname != "nitro") then "bspc query --nodes -n focused.tiled && state=floating || state=tiled; bspc node --state \~$state" else "bspc query --nodes -n focused.tiled && set state floating || set state tiled; bspc node --state \~$state"; # Fish shell dont accept "="
        ### Rotate ###
        "${vars.mod} + f" = "${bspc} node --state \~fullscreen"; # Toggle fullscreen of window
        "${vars.mod} + {_,shift + }q" = "${bspc} node -{c,k}"; # Close and kill
        ### Window ###
        "${vars.mod} + k" = "${bspc} desktop -l next"; # ${vars.modAlt}ernate between the tiled and monocle layout
        "${vars.mod} + g" = "${bspc} node -s biggest.window"; # Swap the current node and the biggest window
        "${vars.mod} + shift + g" = "if [ \"$(${bspc} config window_gap)\" -eq 0 ]; then ${bspc} config window_gap 12; ${bspc} config border_width 2; else ${bspc} config window_gap 0; ${bspc} config border_width 0; fi";
        ### Move current window to a pre-selected space
        "${vars.mod} + shift + m" = "${bspc} node -n last.!automatic";
        "${vars.mod} + {_,shift} + {u,i}" = "${bspc} {monitor -f,node -m} {prev,next}"; # focus or send to the next monitor
        ### Move workspaces ###
        "${vars.mod} + shift + {Left,Right}" = "${bspc} node -d {prev,next}.local --follow"; # Send and follow to previous or next desktop
        ### State Flags ###
        "${vars.mod} + {t,shift + t,s,f}" = "${bspc} node -t {tiled,pseudo_tiled,floating,\~fullscreen}";
        "${vars.modAlt} + f" = ''${bspc} node -t "~"{floating,tiled}'';
        "${vars.mod} + ctrl + {m,x,y,z}" = "${bspc} node -g {marked,locked,sticky,private}"; # set the node flags
        ### Focus/Swap ###
        "${vars.mod} + {_,shift + }{h,j,k,l}" = "${bspc} node -{f,s} {west,south,north,east}"; # focus the node in the given direction
        "${vars.mod} + {p,b,comma,period}" = "${bspc} node -f @{parent,brother,first,second}"; # focus the node for the given path jump
        "${vars.mod} + {_,shift + }c" = "${bspc} node -f {prev,next}.local"; # focus the next/previous node in the current desktop
        "${vars.mod} + {Left,Right}" = "${bspc} desktop --focus {prev,next}.occupied"; # Focus left/right occupied desktop
        "ctrl + ${vars.modAlt} + {Left,Right}" = "${bspc} desktop --focus {prev,next}"; # Focus left/right desktop
        "ctrl + ${vars.modAlt} + {Up, Down}" = "${bspc} desktop --focus {prev,next}"; # Focus left/right desktop
        "${vars.mod} + {Up,Down}" = "${bspc} desktop --focus {prev,next}.occupied"; # Focus left/right occupied desktop
        "${vars.mod} + Left" = "${bspc} desktop -f prev.local";
        "${vars.mod} + Right" = "${bspc} desktop -f next.local";
        "${vars.mod} + {grave,Tab}" = "${bspc} {node,desktop} -f last"; # focus the last node/desktop
        "${vars.mod} + {o,i}" = ''
          ${bspc} wm -h off; \
          ${bspc} node {older,newer} -f; \
          ${bspc} wm -h on
        ''; # focus the older or newer node in the focus history
        "${vars.mod} + {1-9,0}" = "${bspc} desktop -f '^{1-9,10}'"; # Switch to different workspaces with back-and-forth support
        "${vars.modAlt} + m" = "${bspc} desktop -l next"; # alternate between the tiled and monocle layout
        ### Scratchpad
        "${vars.mod} + z" = "${bspc} node focused -t floating; ${bspc} node -d '^12'";
        "alt + Tab" = "${exe config.programs.rofi.package} -show window -window-thumbnail";
        "${vars.mod} + shift + {1-9,0}" = "${bspc} node -d '^{1-9,10}' --follow"; # Move windows to different workspaces
        "${vars.mod} + shift + equal" = "${bspc} node -m last --follow"; # Send to monitor
        ### Preselect ###
        "${vars.mod} + ${vars.modAlt} + {h,j,k,l}" = "${bspc} node -p {west,south,north,east}"; # preselect the direction
        "${vars.mod} + ctrl + {1-9}" = "${bspc} node -o 0.{1-9}"; # preselect the ratio
        # Cancel the preselect
        # For context on syntax: https://github.com/baskerville/bspwm/issues/344
        "${vars.mod} + ${vars.modAlt} + {_,shift + }Escape" = "${bspc} query -N -d | xargs -I id -n 1 ${bspc} node id -p cancel";
        "${vars.mod} + shift + Escape" = "${bspc} node -p cancel"; # cancel the preselection for the focused node
        # Set the node flags
        "${vars.mod} + ctrl + {m,x,s,p}" = "${bspc} node -g {marked,locked,sticky,private}";
        "${vars.mod} + y" = "${bspc} node @parent -R 90";
        "${vars.mod} + r" = "${bspc} node @focused:/ --rotate 90";
        "${vars.mod} + shift + r" = "${bspc} node @focused:/ --rotate 180";
        # Rotate tree
        "${vars.mod} + shift + {d,a}" = "${bspc} node @/ -C {forward,backward}";
        # Send the newest marked node to the newest preselected node
        "${vars.mod} + shift + y" = "${bspc} node newest.marked.local -n newest.!automatic.local";
        "${vars.mod} + s : {h,j,k,l}" = ''
          STEP=30; SELECTION={1,2,3,4}; \
          ${bspc} node -z $(echo "left -$STEP 0,bottom 0 $STEP,top 0 -$STEP,right $STEP 0" | cut -d',' -f$SELECTION) || \
          ${bspc} node -z $(echo "right -$STEP 0,top 0 $STEP,bottom 0 -$STEP,left $STEP 0" | cut -d',' -f$SELECTION)
        '';
        ### Helper ###
        #Show keybind cheatsheet";
        "${vars.modAlt} + F1" = "${config.programs.rofi.package}/bin/rofi  -dmenu -i -p 'Hotkeys 󰄾' < ${config.xdg.configHome}/sxhkd/sxhkdrc | ${pkgs.choose}/bin/choose -f ' => ' 2 | ${exe pkgs.bash}";
        ### jgmenu ###
        "~button3" = "${pkgs.xqp}/bin/xqp 0 $(${pkgs.xdo}/bin/xdo id -N Bspwm -n root) && ${pkgs.jgmenu}/bin/jgmenu --csv-file=$HOME/.config/jgmenu/scripts/menu.txt --config-file=$HOME/.config/jgmenu/jgmenurc";
        ### Move/Resize ###
        # expand a window by moving one of its side outward
        "ctrl + ${vars.modAlt} +  {Left,Down,Up,Right}" = ''
          ${bspc} node -z {left -20 0 || ${bspc} node -z right -20 0, \
            bottom 0 20 || ${bspc} node -z top 0 20,\
            top 0 -20 || ${bspc} node -z bottom 0 -20,\
            right 20 0 || ${bspc} node -z left 20 0}
        '';
        "${vars.mod} + {Left,Down,Up,Right}" = "${bspc} node -v {-20 0,0 20,0 -20,20 0}"; # move a floating window
        "${vars.modAlt} + o" = "${exe' config.service.polybar.package "polybar-msg"} cmd toggle";
        "${vars.modAlt} + shift +x" = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid -p";
        "${vars.mod} + ${vars.modAlt} + shift + {h,j,k,l}" = "${bspc} node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}"; # contract a window by moving one of its side inward
        "${vars.modAlt} + shift + {Left,Down,Up,Right}" = "${bspc} node -v {-20 0,0 20,0 -20,20 0}";

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

        # XF86AudioRaiseVolume = "${pkgs.orpheus_raise-volume}/bin/orpheus_raise-volume";
        # XF86AudioLowerVolume = "${pkgs.orpheus_lower-volume}/bin/orpheus_lower-volume";
        # XF86AudioMute = "${pkgs.orpheus_mute}/bin/orpheus_mute";

        ### Mac backlight ###
        # XF86KbdBrightnessUp = "exec ${pkgs.kbdlight}/bin/kbdlight up 5";
        # XF86KbdBrightnessDown = "exec ${pkgs.kbdlight}/bin/kbdlight down 5";

        ### Pamixer cmdline ###

        # XF86AudioMute = "${_ pkgs.pamixer}/bin/pamixer -t";
        # XF86AudioRaiseVolume = "${_ pkgs.pamixer}/bin/pamixer -i 2";
        # XF86AudioLowerVolume = "${_ pkgs.pamixer}/bin/pamixer -d 2"

        ### Acpilight ###

        # XF86MonBrightnessUp = "exec ${pkgs.acpilight}/bin/xbacklight -perceived -inc 5";
        # XF86MonBrightnessDown = "exec ${pkgs.acpilight}/bin/xbacklight -perceived -dec 5";

        ### Brillo ###

        # XF86MonBrightnessUp = "exec ${pkgs.dunst-light}/bin/pkgs.-light up";
        # XF86MonBrightnessDown = "exec ${pkgs.dunst-light}/bin/dunst-pkgs.light down";
        # XF86MonBrightnessUp = "exec ${pkgs.brillo}/bin/brillo -e -A 0.2";
        # XF86MonBrightnessDown = "exec ${pkgs.brillo}/bin/brillo -e -U 0.2";

        ### Xbacklight ###

        # XF86MonBrightnessUp = "${_ pkgs.xorg.xbacklight}/bin/xbacklight + 5";
        # XF86MonBrightnessDown = "${_ pkgs.xorg.xbacklight}/bin/xbacklight - 5";

        ### PlayerCtl ###

        # XF86AudioPlay = "${pkgs.playerctl}/bin/playerctl play";
        # XF86AudioPause = "${pkgs.playerctl}/bin/playerctl pause";
        # XF86AudioNext = "${pkgs.playerctl}/bin/playerctl next";
        # XF86AudioPrev = "${pkgs.playerctl}/bin/playerctl previous";
        # "${vars.mod} + l" = "exec ${_ pkgs.systemd}/bin/loginctl lock-session";
        # "${vars.mod} + n" = "exec ${pkgs.xdg-utils}/bin/xdg-open http://";

        ##################
        ### Screenshot ###
        ##################
        "Print" = "~/.config/rofi/configurations/scripts/screenshots.sh";
        "${vars.modAlt} + shift + 4" = "~/.config/rofi/configurations/scripts/screenshots.sh";
        # "Print" = "${screenshooter}/bin/screenshooter";
        # "Print" = "${pkgs.flameshot}/bin/flameshot gui";
        # "Print" = "${pkgs.rofi-screenshot}/bin/rofi-screenshot";
      };
    };
  };
}
