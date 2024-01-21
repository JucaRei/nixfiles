{ config, lib, pkgs, username, hostname, ... }:
with lib.hm.gvariant;
{
  imports = [
    ### Import selected theme
    # ./themes/default
    ./themes/everforest
  ];

  config = {
    xsession = {
      # Systemdless
      # enable = lib.mkIf (hostname != "zion" || "vm") true;
      enable = false;
      numlock.enable = true;
      windowManager.bspwm = {
        # enable = lib.mkIf (hostname != "zion" || "vm") true;
        enable = false;
        alwaysResetDesktops = true;
      };
    };
    home = {
      packages = with pkgs; [
        # Default packages for ALL
        bspwm
        numlockx
        pamixer
        gnome3.gvfs
        cifs-utils
        lm_sensors
        lxappearance
        archiver
        imagemagick
        # blueberry
        xclip
        lsof
        xdo
        wmctrl
        mate.mate-polkit
        brillo
        kbdlight
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
      ];

      sessionVariables = {
        GLFW_IM_MODULE = "ibus";
        LIBPROC_HIDE_KERNEL = "true"; # prevent display kernel threads in top
        QT_QPA_PLATFORMTHEME = "gtk3";
        "TERM" = "xterm";
        GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
      };
      sessionPath = [
        "$HOME/.local/bin"
      ];

      # Without systemd (Voidlinux - Runit)
      file = {
        ".xinitrc" = {
          text = ''
            #!/bin/sh
             ${pkgs.bspwm}/bin/bspwm -c /home/${username}/.config/bspwm/bspwmrc

                #XDG DATA DIR
                #  export XDG_DATA_DIRS="$HOME/.local/share/applications"

                # XDG USER DIR
                #  mkdir -p /tmp/$\{USER}-runtime && chmod -R 0700 /tmp/$\{USER}-runtime &
                #  export XDG_RUNTIME_DIR=/tmp/$\{USER}-runtime
                #  export XDG_RUNTIME_DIR="/var/lib/flatpak/exports/share"
                #  export XDG_RUNTIME_DIR="/home/juca/.local/share/flatpak/exports/share"

                 exec dbus-run-session ${pkgs.bspwm}/bin/bspwm
          '';
          executable = true;
        };
        ".startx" = {
          text = ''
            startx ~/.xinitrc session
          '';
          executable = true;
        };
      };

        # ".xsession" = {
        #   text = ''
        #     ${pkgs.bspwm}/bin/bspwm -c /home/${username}/.config/bspwm/bspwmrc

        #     #XDG DATA DIR
        #     export XDG_DATA_DIRS="$HOME/.local/share/applications"

        #     # XDG USER DIR
        #     mkdir -p /tmp/$\{USER}-runtime && chmod -R 0700 /tmp/$\{USER}-runtime &
        #     export XDG_RUNTIME_DIR=/tmp/$\{USER}-runtime
        #     export XDG_RUNTIME_DIR="/var/lib/flatpak/exports/share"
        #     export XDG_RUNTIME_DIR="/home/juca/.local/share/flatpak/exports/share"

        #     exec dbus-run-session bspwm
        #   '';
        #   executable = true;
        # };
        # ".dmrc" = {
        #   text = ''
        #     [Desktop]
        #     Session=lightdm=xsession
        #   '';
        # };
    };

    systemd.user.services.polkit-agent = lib.mkIf config.xsession.enable {
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
        # Environment = [ "WAYLAND_DISPLAY=wayland-0" "LANG=pt_BR.UTF-8" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
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
  };
}
