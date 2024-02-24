{ config, lib, pkgs, username, hostname, ... }:
with lib.hm.gvariant; {
  imports = [
    ### Import selected theme
    # ./themes/default
    ./themes/everforest
  ];

  config = {
    xsession = {
      enable = true;
      numlock.enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          alwaysResetDesktops = true;
        };
      };
    };
    home = {
      packages = with pkgs; [
        # Default packages for ALL
        pamixer
        gnome3.gvfs
        cifs-utils
        lm_sensors
        lxappearance
        archiver
        imagemagick
        xclip
        lsof
        xdo
        wmctrl
        mate.mate-polkit
        brillo
        kbdlight
        acpi

        # i3lock-fancy

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
        # XDG_CACHE_HOME = "\${HOME}/.cache";
        # XDG_CONFIG_HOME = "\${HOME}/.config";
        # XDG_BIN_HOME = "\${HOME}/.local/bin";
        # XDG_DATA_HOME = "\${HOME}/.local/share";
      };
      sessionPath = [ "$HOME/.local/bin" ];

      # Without systemd (Voidlinux - Runit)
      # file = {
      #   ".xinitrc" = {
      #     text = ''
      #       #!/usr/bin/env bash

      #       DEFAULT_SESSION="bspwm" &

      #       Redirect errors to a file in user's home directory if we can
      #       for errfile in "$HOME/.wm-errors" "${TMPDIR-/tmp}/wm-$USER" "/tmp/wm-$USER"
      #       do
      #           if ( cp /dev/null "$errfile" 2> /dev/null )
      #           then
      #               chmod 600 "$errfile"
      #               exec > "$errfile" 2>&1
      #               break
      #           fi
      #       done &

      #       # Define Xresources
      #       userresources=$HOME/.Xresources &

      #       # Merge what is available
      #       if [ -f "$userresources" ]; then
      #           xrdb -merge "$userresources"
      #       fi &

      #       if [ -d /etc/X11/xinit/xinitrc.d ]; then
      #         for f in /etc/X11/xinit/xinitrc.d/*; do
      #           [ -x "$f" ] && . "$f"
      #         done
      #         unset f
      #       fi &

      #       if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
      #         export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
      #         dbus-daemon --session --nofork --nopidfile --address="$DBUS_SESSION_BUS_ADDRESS" &
      #       fi &

      #       exec bspwm
      #     '';
      #     executable = true;
      #   };
      #   # ".startx" = {
      #   #   text = ''
      #   #     startx ~/.xinitrc session
      #   #   '';
      #   #   executable = true;
      #   # };

      #   # ".xsession" = {
      #   #   text = ''
      #   #     #!/usr/bin/env bash
      #   #     bspwm -c /home/${username}/.config/bspwm/bspwmrc

      #   #     #     #XDG DATA DIR
      #   #     #     export XDG_DATA_DIRS="$HOME/.local/share/applications"

      #   #     #     # XDG USER DIR
      #   #     #     mkdir -p /tmp/$\{USER}-runtime && chmod -R 0700 /tmp/$\{USER}-runtime &
      #   #     #     export XDG_RUNTIME_DIR=/tmp/$\{USER}-runtime
      #   #     #     export XDG_RUNTIME_DIR="/var/lib/flatpak/exports/share"
      #   #     #     export XDG_RUNTIME_DIR="/home/juca/.local/share/flatpak/exports/share"

      #   #     exec dbus-run-session bspwm
      #   #   '';
      #   #   executable = true;
      #   # };
      #   # ".dmrc" = {
      #   #   text = ''
      #   #     [Desktop]
      #   #     Session=lightdm=xsession
      #   #   '';
      #   # };
      # };
      # ".xprofile" = {
      #   text =
      #     ''
      #       if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
      #         export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
      #         dbus-daemon --session --nofork --nopidfile --address="$DBUS_SESSION_BUS_ADDRESS" &
      #       fi &

      #       exec bspwm
      #     '';
      #   executable = true;
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
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    dconf.settings = {
      "ca/desrt/dconf-editor" = { show-warning = false; };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "adaptive";
        left-handed = false;
        natural-scroll = false;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = true;
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
    };
  };
}
