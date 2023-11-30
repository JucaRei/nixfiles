{ pkgs, ... }: {
  xsession = {
    enable = true;
    numlock.enable = true;
    windowManager = {
      bspwm = {
        enable = true;
        package = pkgs.bspwm-unstable;
        alwaysResetDesktops = true;
        startupPrograms = [
          "sxhkd"
          "flameshot"
          "dunst"
          "nm-applet --indicator"
          "sleep 2s;polybar -q main"
        ];
        monitors = {
          eDP1 = [
            "一"
            "二"
            "三"
            "四"
            "五"
            "六"
            "七"
            "八"
          ];
        };
        extraConfig = '''';
      };
    };
  };

  home = {
    packages = with pkgs; [
      rofi
      rofi-emoji
      haskellPackages.greenclip
      picom-jonaburg
      eww
      dunst
      wmctrl
      feh # A light-weight image viewer
      playerctl
      lm_sensors
      light
      brightnessctl
      zscroll # A text scroller for use with panels and shells
      neovim
      viewnior # Fast and simple image viewer
      yad # GUI dialog tool for shell scripts
      i3lock-color # A simple screen locker like slock
      xclip # Tool to access the X clipboard 
      maim # screenshot cmdline
      slop # Queries a selection from the user and prints to stdout
      gpick # Color picker
      stalonetray # Stand alone tray
      redshift # Screen color temperature
      gtk3
      sarasa-gothic # Font
      gtk-engine-murrine # gtk flexible engine
      gnome.gnome-themes-extra
    ];
  };
}
