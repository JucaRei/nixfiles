{ config, lib, pkgs, username, ... }:
with lib.hm.gvariant;

{
  imports = [
    ./themes/default
    # ./themes/everforest
    ./sxhkd.nix
  ];
  xsession = {
    enable = true;
    numlock.enable = true;
    windowManager.bspwm = {
      enable = true;
      alwaysResetDesktops = true;
      startupPrograms = [
        # "killall -9 picom sxhkd dunst xfce4-power-manager ksuperkey eww oneko sct"
        "pgrep -x sxhkd > /dev/null || sxhkd"
        "xfce4-power-manager"
        "xsetroot -cursor_name left_ptr"
        # "flameshot"
        "dunst -config $HOME/.config/dunst/dunstrc"
        "nm-applet --indicator"
        # "picom --config $HOME/.config/picom/picom.conf"
        #"sleep 2s;polybar -q bar"        #"sleep 2s;polybar -q bar"
        "sleep 2s;polybar -q main"
      ];
      extraConfig = ''
        #!/bin/bash

        # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1' | awk '{print $1}')
        # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1-0' | awk '{print $1}')
        # EXTERNAL_MONITOR=$(xrandr | grep 'HDMI-1-1' | awk '{print $1}')
        EXTERNAL_MONITOR=$(xrandr | grep 'HDMI' | awk '{print $1}')
        INTERNAL_MONITOR=$(xrandr | grep 'eDP1' | awk '{print $1}')
        # INTERNAL_MONITOR=$(xrandr | grep 'eDP1' | awk '{print $1}')
        # INTERNAL_MONITOR=$(xrandr | grep 'eDP-1' | awk '{print $1}')
        if [[ $1 == 0 ]]; then
            if [[ $(xrandr -q | grep "$\{EXTERNAL_MONITOR} connected") ]]; then
                bspc monitor "$EXTERNAL_MONITOR" -d 1 2 3 4 5 6 7 8 9 0
                bspc monitor "$INTERNAL_MONITOR" -d 10
                bspc wm -O "$EXTERNAL_MONITOR" "$INTERNAL_MONITOR"
            else
                bspc monitor "$INTERNAL_MONITOR" -d 1 2 3 4 5 6 7 8
            fi
        fi

        workspaces() {
          name=1
          for monitor in `bspc query -M`; do
            #bspc monitor "$\{monitor}" -n "$name" -d '一' '二' '三' '四' '五' '六' '七'
            bspc monitor $\{monitor} -n "$name" -d I II III IV V VI VII VIII IX X
            let name++
          done
        }

        workspaces

        # bspc monitor -d 1 2 3 4 5 6 7 8

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
      rules = {
        "mpv" = {
          state = "floating";
          center = true;
        };
        "nemo" = {
          state = "floating";
          center = true;
        };
      };
    };
  };
  home = {
    packages = with pkgs; [
      # pamixer
      # i3lock-fancy

      # kitty
      flameshot
      # yad
      # gnome.nautilus
      # gnome.nautilus-python
      # gnome.sushi
      # gnome.file-roller
      # nautilus-open-any-terminal
      cinnamon.nemo
      # cinnamon.nemo-with-extensions
      cinnamon.nemo-fileroller
      jq
      nordic
      lm_sensors
      archiver
      lxappearance
      # gtk_engines
      # gtk-engine-murrine
      imagemagick
      # parcellite
      blueberry
      xclip
      # gpick
      kbdlight
      # tint2
      # moreutils
      # xbindkeys-config
      # recode
      # plank
      # redshift
      # glava
      tokyo-night-gtk
      lsof
      st
      bc
      # pomodoro
      xdo
      wmctrl
      # i3lock-color
      # networkmanager_dmenu
      # conky
      # zscroll
      # rnnoise-plugin
      # jgmenu
      mate.mate-polkit
      yaru-theme
      brightnessctl
      acpi
      playerctl
      # maim
      feh
      picom
      papirus-icon-theme
      pulseaudio-control

      # Fonts
      cantarell-fonts
      cascadia-code
      hasklig
      inconsolata
      meslo-lgs-nf
      font-awesome
      hack-font
      inter
      twemoji-color-font
      (nerdfonts.override {
        fonts = [ "DroidSansMono" "LiberationMono" "Iosevka" "Hasklig" "JetBrainsMono" "FiraCode" ];
      })
    ];

    pointerCursor = {
      package = pkgs.papirus-icon-theme;
      # package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };

    sessionVariables = {
      # EDITOR = "nvim";
      # BROWSER = "${browser}";
      # TERMINAL = "${terminal}";
      GLFW_IM_MODULE = "ibus";
      LIBPROC_HIDE_KERNEL = "true"; # prevent display kernel threads in top
      QT_QPA_PLATFORMTHEME = "gtk3";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  systemd.user.services.polkit-agent = {
    Unit = {
      Description = "launch authentication-agent-1";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = ''
        ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1
      '';
      # Environment = [ "WAYLAND_DISPLAY=wayland-0" "LANG=ja_JP.UTF-8" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
  fonts = {
    fontconfig = {
      enable = true;
    };
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      left-handed = false;
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
  };

}
