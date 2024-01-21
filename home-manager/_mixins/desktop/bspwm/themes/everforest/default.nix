{ pkgs, ... }:
let
  terminal = "alacritty";
  # terminal = "urxvtd";
  file-manager = "nautilus";
  browser = "thorium";
in
{
  imports = [
    ./dunst.nix
    ./picom.nix
    # ./xresources.nix
    # ./polybar.nix
    ../../../../apps/terminal/alacritty.nix
    # ../../../../apps/tools/spacefm.nix
    ./polybar-everforest.nix
    ./sxhkd_us-mac.nix
    ./rofi.nix
  ];

  config = {
    home = {
      file.".owm-key" = {
        text = ''
          3901194171bca9e5e3236048e50eb1a5
        '';
      };
      packages = with pkgs; [
        # st
        playerctl
        pcmanfm
        # pulseaudio-control
        # gnome.nautilus
        # gnome.sushi
        # nautilus-open-any-terminal
        gtk-engine-murrine

        # Fonts
        cascadia-code
        hasklig
        hack-font
        inter
        twemoji-color-font
        (nerdfonts.override {
          fonts = [
            "DroidSansMono"
            "LiberationMono"
            # "Iosevka"
            "Hasklig"
            "JetBrainsMono"
            "FiraCode"
          ];
        })
      ] ++ (with pkgs.unstable; [
        polybar-pulseaudio-control
      ]);

      file = {
        ".config/bspwm/bspwmrc" = {
          executable = true;
          text = ''

          bspc config 'border_width' '3'
          bspc config 'borderless_monocle' 'off'
          bspc config 'focus_follows_pointer' 'off'
          bspc config 'focused_border_color' '#81A1C1'
          bspc config 'gapless_monocle' 'off'
          bspc config 'normal_border_color' '#434C5E'
          bspc config 'pointer_action1' 'move'
          bspc config 'pointer_action2' 'resize_side'
          bspc config 'pointer_action3' 'resize_corner'
          bspc config 'pointer_modifier' 'mod4'
          bspc config 'presel_border_color' '#8FBCBB'
          bspc config 'presel_feedback_color' '#B48EAD'
          bspc config 'split_ration' '0.5'
          bspc config 'urgernt_border_color' '#88C0D0'
          bspc config 'window_gap' '8'

          bspc rule -r '*'
          bspc rule -a 'GLava' 'border=off' 'center=on' 'focus=off' 'follow=off' 'layer=below' 'locked=on' 'rectangle=1920x1080+0+0' 'state=floating' 'sticky=on'
          bspc rule -a 'Peek' 'state=floating'
          bspc rule -a 'Plank' 'border=off' 'manage=off'
          bspc rule -a 'conky-manager2' 'state=floating'
          bspc rule -a 'mpv' 'center=on' 'state=floating'

          # java gui fixes
          export _JAVA_AWT_WM_NONREPARENTING=1
          bspc rule -a sun-awt-X11-XDialogPeer state=floating

          # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1' | awk '{print $1}')
          EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1-0' | awk '{print $1}')
          # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1-1' | awk '{print $1}')
          # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI' | awk '{print $1}')
          # INTERNAL_MONITOR=$(xrandr | grep 'eDP1' | awk '{print $1}')
          INTERNAL_MONITOR=$(xrandr | grep 'Virtual-1' | awk '{print $1}')
          # INTERNAL_MONITOR=$(xrandr | grep 'eDP-1' | awk '{print $1}')
          if [[ $1 == 0 ]]; then
              if [[ $(xrandr -q | grep "$\{EXTERNAL_MONITOR} connected") ]]; then
                  bspc monitor "$EXTERNAL_MONITOR" -d 2 4 6 8 10
                  bspc monitor "$INTERNAL_MONITOR" -d 1 3 5 7 9
                  bspc wm -O "$EXTERNAL_MONITOR" "$INTERNAL_MONITOR"
              else
                  bspc monitor "$INTERNAL_MONITOR" -d 1 2 3 4 5 6 7 8
              fi
          fi

          workspaces() {
            name=1
            for monitor in `bspc query -M`; do
              # bspc monitor "$\{monitor}" -n "$name" -d '一' '二' '三' '四' '五' '六' '七'
              bspc monitor $\{monitor} -n "$name" -d I II III IV V VI VII VIII IX X
              let name++
            done
          }

          # workspace 1 (Terminals)
          declare -a terminal=()
          for i in $\{terminal[@]}; do
              bspc rule -a $i desktop='^1' follow=on focus=on; done

          # workspace 2 (Internet Browser)
          declare -a web=(discord spotify)
          for i in $\{web[@]}; do
              bspc rule -a $i desktop='^2' follow=on focus=on; done

          # workspace 3 (Files)
          declare -a filem=(Pcmanfm qBittorrent)
          for i in $\{filem[@]}; do
              bspc rule -a $i desktop='^3' follow=on focus=on; done

          # workspace 4 (Text Editor)
          declare -a office=(Code terminal)
          for i in $\{office[@]}; do
              bspc rule -a $i desktop='^4' follow=on focus=on; done

          workspaces

          #bspc config border_width                3
          #bspc config borderless_monocle          false
          #bspc config ga1pless_monocle            false
          #bspc config focused_border_color        "#81A1C1"
          #bspc config normal_border_color         "#434c5e"
          #bspc config urgent_border_color         "#88C0D0"
          #bspc config presel_border_color         "#8FBCBB"
          #bspc config presel_feedback_color       "#B48EAD"
          #bspc config window_gap                  8

          #bspc config split_ratio                 0.5
          #bspc config focus_follows_pointer       false

          #bspc config pointer_modifier 						mod4
          #bspc config pointer_action1 						move
          #bspc config pointer_action2 						resize_side
          #bspc config pointer_action3 						resize_corner

          #bspc config border_width         2
          #bspc config window_gap           8
          #bspc config border_radius	      12

          #bspc config normal_border_color \#c0caf5
          #bspc config active_border_color \#c0caf5
          #bspc config focused_border_color \#c0caf5

          #bspc config split_ratio          0.52
          #bspc config borderless_monocle   true
          #bspc config gapless_monocle      true

          #bspc rule -a Peek state=floating
          #bspc rule -a kitty state=floating
          #bspc config external_rules_command "$HOME/.config/bspwm/scripts/external-rules"
          #bspc rule -a conky-manager2 state=floating
          #bspc rule -a Kupfer.py focus=on
          #bspc rule -a Screenkey manage=off
          #bspc rule -a Plank manage=off border=off locked=on focus=off follow=off layer=above
          #bspc rule -a Rofi state=floating
          #bspc rule -a GLava state=floating layer=below sticky=true locked=true border=off focus=off center=true follow=off rectangle=1920x1080+0+0

          killall -9 picom sxhkd dunst xfce4-power-manager ksuperkey eww oneko sct &
          sleep 1 &
          pgrep -x sxhkd > /dev/null || sxhkd &
          xsetroot -cursor_name left_ptr &
          dunst -config $HOME/.config/dunst/dunstrc &
          sleep 1; polybar -q bar &
          '';
        };
      };
    };

    # xsession.windowManager.bspwm = {
    #   startupPrograms = [
    #     "killall -9 picom sxhkd dunst xfce4-power-manager ksuperkey eww oneko sct"
    #     "sleep 1"
    #     "pgrep -x sxhkd > /dev/null || sxhkd"
    #     "xsetroot -cursor_name left_ptr"
    #     "dunst -config $HOME/.config/dunst/dunstrc"
    #     "sleep 1; polybar -q bar"
    #     # "${pkgs.spaceFM}/bin/spacefm -d"
    #   ];
    #   rules = {
    #     "mpv" = {
    #       state = "floating";
    #       center = true;
    #     };
    #     # "spacefm" = {
    #     #   state = "floating";
    #     #   center = true;
    #     # };
    #     "Peek" = {
    #       state = "floating";
    #     };
    #     "conky-manager2" = {
    #       state = "floating";
    #     };
    #     "Plank" = {
    #       manage = false;
    #       border = false;
    #     };
    #     "GLava" = {
    #       state = "floating";
    #       layer = "below";
    #       sticky = true;
    #       locked = true;
    #       border = false;
    #       focus = false;
    #       center = true;
    #       follow = false;
    #       rectangle = "1920x1080+0+0";
    #       # rectangle = "1366x768+0+0";
    #     };
    #   };
    #   extraConfig = ''
    #     # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1' | awk '{print $1}')
    #     EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1-0' | awk '{print $1}')
    #     # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1-1' | awk '{print $1}')
    #     # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI' | awk '{print $1}')
    #     # INTERNAL_MONITOR=$(xrandr | grep 'eDP1' | awk '{print $1}')
    #     INTERNAL_MONITOR=$(xrandr | grep 'Virtual-1' | awk '{print $1}')
    #     # INTERNAL_MONITOR=$(xrandr | grep 'eDP-1' | awk '{print $1}')
    #     if [[ $1 == 0 ]]; then
    #         if [[ $(xrandr -q | grep "$\{EXTERNAL_MONITOR} connected") ]]; then
    #             bspc monitor "$EXTERNAL_MONITOR" -d 2 4 6 8 10
    #             bspc monitor "$INTERNAL_MONITOR" -d 1 3 5 7 9
    #             bspc wm -O "$EXTERNAL_MONITOR" "$INTERNAL_MONITOR"
    #         else
    #             bspc monitor "$INTERNAL_MONITOR" -d 1 2 3 4 5 6 7 8
    #         fi
    #     fi

    #     workspaces() {
    #       name=1
    #       for monitor in `bspc query -M`; do
    #         # bspc monitor "$\{monitor}" -n "$name" -d '一' '二' '三' '四' '五' '六' '七'
    #         bspc monitor $\{monitor} -n "$name" -d I II III IV V VI VII VIII IX X
    #         let name++
    #       done
    #     }

    #     # workspace 1 (Terminals)
    #     declare -a terminal=()
    #     for i in $\{terminal[@]}; do
    #         bspc rule -a $i desktop='^1' follow=on focus=on; done

    #     # workspace 2 (Internet Browser)
    #     declare -a web=(discord spotify)
    #     for i in $\{web[@]}; do
    #         bspc rule -a $i desktop='^2' follow=on focus=on; done

    #     # workspace 3 (Files)
    #     declare -a filem=(Pcmanfm qBittorrent)
    #     for i in $\{filem[@]}; do
    #         bspc rule -a $i desktop='^3' follow=on focus=on; done

    #     # workspace 4 (Text Editor)
    #     declare -a office=(Code terminal)
    #     for i in $\{office[@]}; do
    #         bspc rule -a $i desktop='^4' follow=on focus=on; done

    #     workspaces

    #     #bspc config border_width                3
    #     #bspc config borderless_monocle          false
    #     #bspc config ga1pless_monocle            false
    #     #bspc config focused_border_color        "#81A1C1"
    #     #bspc config normal_border_color         "#434c5e"
    #     #bspc config urgent_border_color         "#88C0D0"
    #     #bspc config presel_border_color         "#8FBCBB"
    #     #bspc config presel_feedback_color       "#B48EAD"
    #     #bspc config window_gap                  8

    #     #bspc config split_ratio                 0.5
    #     #bspc config focus_follows_pointer       false

    #     #bspc config pointer_modifier 						mod4
    #     #bspc config pointer_action1 						move
    #     #bspc config pointer_action2 						resize_side
    #     #bspc config pointer_action3 						resize_corner

    #     #bspc config border_width         2
    #     #bspc config window_gap           8
    #     #bspc config border_radius	      12

    #     #bspc config normal_border_color \#c0caf5
    #     #bspc config active_border_color \#c0caf5
    #     #bspc config focused_border_color \#c0caf5

    #     #bspc config split_ratio          0.52
    #     #bspc config borderless_monocle   true
    #     #bspc config gapless_monocle      true

    #     #bspc rule -a Peek state=floating
    #     #bspc rule -a kitty state=floating
    #     #bspc config external_rules_command "$HOME/.config/bspwm/scripts/external-rules"
    #     #bspc rule -a conky-manager2 state=floating
    #     #bspc rule -a Kupfer.py focus=on
    #     #bspc rule -a Screenkey manage=off
    #     #bspc rule -a Plank manage=off border=off locked=on focus=off follow=off layer=above
    #     #bspc rule -a Rofi state=floating
    #     #bspc rule -a GLava state=floating layer=below sticky=true locked=true border=off focus=off center=true follow=off rectangle=1920x1080+0+0
    #   '';
    #   settings = {
    #     border_width = 3;
    #     borderless_monocle = false;
    #     gapless_monocle = false;
    #     focused_border_color = "#81A1C1";
    #     normal_border_color = "#434C5E";
    #     urgernt_border_color = "#88C0D0";
    #     presel_border_color = "#8FBCBB";
    #     presel_feedback_color = "#B48EAD";
    #     window_gap = 8;
    #     split_ration = "0.5";
    #     focus_follows_pointer = false;
    #     pointer_modifier = "mod4";
    #     pointer_action1 = "move";
    #     pointer_action2 = "resize_side";
    #     pointer_action3 = "resize_corner";
    #   };
    # };
    services = {
      sxhkd = {
        keybindings = {
          # Selected programs
          "super + Return" = "${terminal}"; # terminal emulator
          "super + @space" = "rofi -show drun -show-icons"; # program launcher
          "super + Escape" = "pkill -USR1 -x sxhkd"; # make sxhkd reload its configuration files
          "super + e" = "${file-manager}";
          "super + b" = "${browser}";
        };
      };
    };
  };
}
