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
        "sxhkd"
        # "flameshot"
        "dunst"
        "nm-applet --indicator"
        # "polybar"
        # "sleep 2s;polybar -q main"
      ];
      extraConfig = ''
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
