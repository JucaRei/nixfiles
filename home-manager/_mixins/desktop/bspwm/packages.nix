{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkDefault getExe getExe';
  isSystemd = if ("${pkgs.ps}/bin/ps --no-headers -o comm 1" == "systemd") then false else true; # check if is systemd system or not
  bspwm_pkg = "${getExe' config.xsession.windowManager.bspwm.package "bspwm"}"; # get bspwm executable path

in
{
  config = {
    desktop.apps = {
      terminal = {
        alacritty = {
          enable = true;
        };
      };
    };

    home = {
      packages = with pkgs // pkgs.xorg; [
        ### Utilities for bspwm
        xinit
        libXcomposite
        libXinerama
        xprop
        libxcb
        xdpyinfo
        xkill
        xsetroot
        xrandr
        xclip
        bc
        killall

        usbutils # usb utilities

        qgnomeplatform # QPlatformTheme for a better Qt application inclusion in GNOME
        libsForQt5.qtstyleplugin-kvantum # SVG-based Qt5 theme engine plus a config tool and extra theme
        qt5.qttools
        qt6Packages.qtstyleplugin-kvantum
        lxappearance-gtk2
        libsForQt5.qt5ct
        gtk-engine-murrine


        dialog # display dialog boxes from shell
        zenity # dialog for gtk
        at-spi2-atk

        lm_sensors
        libwebp # Tools and library for the WebP image format
        imagemagick

        jgmenu

        # System
        xdg-utils
        xdg-user-dirs # create xdg user dirs
        xdg-desktop-portal-gtk
      ];

      shellAliases = { is_picom_on = "${getExe' pkgs.procps "pgrep"} -x 'picom' > /dev/null && echo 'on' || echo 'off'"; };

      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        TERMINAL = "alacritty";
        GLFW_IM_MODULE = "ibus";
        TERM = "xterm-256color";
        QT_STYLE_OVERRIDE = mkDefault ""; # fix qt-override
      };

      file = {
        ".local/share/applications/bspwm.desktop" = mkIf (!isSystemd) {
          text = ''
            [Desktop Entry]
            Name=bspwm
            Comment=Binary space partitioning window manager
            Exec=${bspwm_pkg}
            Type=Application
          '';
        };

        ".xinitrc" = mkIf (!isSystemd) {
          executable = true;
          text = ''
            #!${pkgs.stdenv.shell}

            userresources=$HOME/.Xresources
            usermodmap=$HOME/.Xmodmap
            sysresources=/etc/X11/xinit/.Xresources
            sysmodmap=/etc/X11/xinit/.Xmodmap

            # Make sure this is before the 'exec' command or it won't be sourced.
            [ -f /etc/xprofile ] && . /etc/xprofile
            [ -f ~/.xprofile ] && . ~/.xprofile

            # merge in defaults and keymaps

            if [ -f $sysresources ]; then
                ${getExe pkgs.xorg.xrdb} -merge $sysresources
            fi

            if [ -f $sysmodmap ]; then
                ${getExe pkgs.xorg.xmodmap}xmodmap $sysmodmap
            fi

            if [ -f "$userresources" ]; then
                ${pkgs.xorg.xrdb}/bin/xrdb -merge "$userresources"
            fi

            if [ -f "$usermodmap" ]; then
                ${pkgs.xorg.xmodmap}/bin/xmodmap "$usermodmap"
            fi

            # ↓ https://nixos.wiki/wiki/Using_X_without_a_Display_Manager
            if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
              eval $(${getExe' pkgs.dbus "dbus-launch"} --exit-with-session --sh-syntax)
            fi
            ${getExe' pkgs.systemdMinimal "systemctl"} --user import-environment DISPLAY XAUTHORITY

            if command -v ${getExe' pkgs.dbus "dbus-update-activation-environment"} > /dev/null 2>&1; then
              ${getExe' pkgs.dbus "dbus-update-activation-environment"} DISPLAY XAUTHORITY
            fi

            # start some nice programs

            if [ -d /etc/X11/xinit/xinitrc.d ] ; then
              for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
                [ -x "$f" ] && . "$f"
              done
              unset f
            fi

            eval "$(${getExe' pkgs.gnome-keyring "gnome-keyring-daemon"} --start)"
            export SSH_AUTH_SOCK
            ${getExe' pkgs.dbus "dbus-update-activation-environment"} DISPLAY XAUTHORITY

            # exec ${getExe' pkgs.dbus "dbus-launch"} --autolaunch=$(cat /var/lib/dbus/machine-id) bspwm
            exec ${pkgs.dbus}/bin/dbus-launch --exit-with-session ${bspwm_pkg} &
          '';
        };
      };
    };

    programs = {
      feh = {
        enable = true;
        package = pkgs.feh;
        keybindings = {
          prev_img = [
            # "h"
            "Left"
          ];
          next_img = [
            "Right"
          ];
          zoom_in = "plus";
          zoom_out = "minus";
        };
      };
    };

    services = {
      playerctld = {
        enable = true;
        package = pkgs.playerctl;
      };
    };
  };
}
