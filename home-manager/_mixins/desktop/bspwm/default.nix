{ config, lib, pkgs, username, ... }:
with lib.hm.gvariant;
{
  imports = [
    ./sxhkd/sxhkd.nix
    ./dunst/dunst.nix
  ];
  xsession = {
    enable = true;
    numlock.enable = true;
    windowManager.bspwm = {
      enable = true;
      alwaysResetDesktops = true;
      startupPrograms = [
        "pgrep -x sxhkd > /dev/null || sxhkd &"
        "xfce4-power-manager &"
        "xsetroot -cursor_name left_ptr &"
        # "flameshot"
        "dunst"
        "nm-applet --indicator"
        "polybar &"
        # "sleep 2s;polybar -q main"
      ];
      extraConfig = ''
        bspc monitor -d 1 2 3 4 5

        bspc config border_width         0
        bspc config window_gap          20
        bspc config border_radius	15

        bspc config normal_border_color \#c0caf5
        bspc config active_border_color \#c0caf5
        bspc config focused_border_color \#c0caf5

        bspc config split_ratio          0.52
        bspc config borderless_monocle   true
        bspc config gapless_monocle      true

        bspc rule -a Peek state=floating
        bspc rule -a kitty state=floating
        bspc config external_rules_command "$HOME/.config/bspwm/scripts/external-rules"
        bspc rule -a conky-manager2 state=floating
        bspc rule -a Kupfer.py focus=on
        bspc rule -a Screenkey manage=off
        bspc rule -a Plank manage=off border=off locked=on focus=off follow=off layer=above
        bspc rule -a Rofi state=floating
        bspc rule -a GLava state=floating layer=below sticky=true locked=true border=off focus=off center=true follow=off rectangle=1920x1080+0+0
      '';
    };
  };
  home = {
    packages = with pkgs; [
      kitty
      gnome.nautilus
      gnome.nautilus-python
      gnome.sushi
      nautilus-open-any-terminal
      lxappearance
      gnome.file-roller
      gtk_engines
      gtk-engine-murrine
      imagemagick
      parcellite
      xclip
      gpick
      tint2
      moreutils
      recode
      plank
      redshift
      glava
      tokyo-night-gtk
      lsof
      xdo
      wmctrl
      i3lock-color
      networkmanager_dmenu
      conky
      zscroll
      rnnoise-plugin
      jgmenu
      mate.mate-polkit
      yaru-theme
      brightnessctl
      acpi
      playerctl
      maim
      feh
      rofi
      rofi-calc
      picom
      papirus-icon-theme
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
      BROWSER = "thorium";
      # TERMINAL = "kitty";
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
}
