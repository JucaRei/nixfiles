{ config, lib, pkgs, username, ... }:
with lib.hm.gvariant;

{
  imports = [
    ### Import selected theme
    # ./themes/default
    ./themes/everforest

    ### Keybindings for all
    # ./sxhkd.nix
  ];
  xsession = {
    enable = true;
    numlock.enable = true;
    windowManager.bspwm = {
      enable = true;
      alwaysResetDesktops = true;
      rules = {
        "mpv" = {
          state = "floating";
          center = true;
        };
      };
    };
  };
  home = {
    packages = with pkgs; [
      pamixer
      # gnome.gvfs
      gnome3.gvfs
      cifs-utils
      lm_sensors
      lxappearance
      archiver
      imagemagick
      blueberry
      xclip
      lsof
      xdo
      wmctrl
      mate.mate-polkit
      brightnessctl
      acpi

      # i3lock-fancy

      # kitty
      # yad
      # gnome.nautilus
      # gnome.nautilus-python
      # gnome.sushi
      # gnome.file-roller
      # nautilus-open-any-terminal
      # cinnamon.nemo-with-extensions
      # gnome3.nautilus


      # gtk_engines
      # gtk-engine-murrine
      # parcellite
      # gpick
      # tint2
      # moreutils
      # xbindkeys-config
      # recode
      # plank
      # redshift
      # glava
      # pomodoro

      # i3lock-color
      # networkmanager_dmenu
      # conky
      # zscroll
      # rnnoise-plugin
      # jgmenu
      # maim

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

    sessionVariables = {
      # EDITOR = "nvim";
      # BROWSER = "${browser}";
      # TERMINAL = "${terminal}";
      GLFW_IM_MODULE = "ibus";
      LIBPROC_HIDE_KERNEL = "true"; # prevent display kernel threads in top
      QT_QPA_PLATFORMTHEME = "gtk3";
      TERM = "xterm";
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
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
