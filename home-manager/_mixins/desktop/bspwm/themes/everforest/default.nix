{ pkgs, ... }:
let
  terminal = "alacritty";
  file-manager = "nautilus";
  browser = "thorium";
in
{
  imports = [
    ./dunst.nix
    ./picom.nix
    ./xresources.nix
    # ./polybar.nix
    ./polybar-test.nix
    ./sxhkd_us-mac.nix
    ./rofi.nix
  ];

  home = {
    file.".owm-key" = {
      text = ''
        3901194171bca9e5e3236048e50eb1a5
      '';
    };
    packages = with pkgs; [
      # st
      pulseaudio-control
      gnome.nautilus
      gnome.sushi
      nautilus-open-any-terminal
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
    ];
  };

  xsession.windowManager.bspwm = {
    startupPrograms = [
      #"killall -9 picom sxhkd dunst xfce4-power-manager ksuperkey eww oneko sct"
      "pgrep -x sxhkd > /dev/null || sxhkd"
      "xsetroot -cursor_name left_ptr"
      "dunst -config $HOME/.config/dunst/dunstrc"
      "sleep 2; polybar -q bar"
    ];
    rules = {
      "mpv" = {
        state = "floating";
        center = true;
      };
    };
    extraConfig = ''
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

      workspaces

      bspc config border_width                3
      bspc config borderless_monocle          false
      bspc config ga1pless_monocle            false
      bspc config focused_border_color        "#81A1C1"
      bspc config normal_border_color         "#434c5e"
      bspc config urgent_border_color         "#88C0D0"
      bspc config presel_border_color         "#8FBCBB"
      bspc config presel_feedback_color       "#B48EAD"
      bspc config window_gap                  8

      bspc config split_ratio                 0.5
      bspc config focus_follows_pointer       false

      bspc config pointer_modifier 						mod4
      bspc config pointer_action1 						move
      bspc config pointer_action2 						resize_side
      bspc config pointer_action3 						resize_corner

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
    '';
  };
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
}
