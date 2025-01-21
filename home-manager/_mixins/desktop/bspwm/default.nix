{ pkgs, config, lib, hostname, ... }@args:
let
  inherit (lib) getExe getExe' mkDefault mkIf;
  _ = getExe;
  __ = getExe';

  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; }; # if is non-nixos system
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  hasSystemd = if ("${pkgs.ps}/bin/ps --no-headers -o comm 1" == "systemd") then false else true; # check if is systemd system or not

  random-walls = "${pkgs.procps}/bin/watch -n 600 ${pkgs.feh}/bin/feh --randomize --bg-fill '$HOME/Pictures/wallpapers/*'"; # wallpapers from system

  dual-workspace =
    let
      bspc-bin = "${_ config.xsession.windowManager.bspwm.package}";
    in
    pkgs.writeShellScriptBin "dual-workspace" ''
      #!${pkgs.stdenv.shell}

        external=$(${pkgs.xorg.xrandr}/bin/xrandr --query | grep '^HDMI-1-0 connected')
        vm=$(${pkgs.xorg.xrandr}/bin/xrandr --query | grep '^Virtual-1 connected')
        if [[ $HOSTNAME == nitro && $external = *\ connected* ]]; then
                ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
                ${bspc-bin} monitor HDMI-1-0 -d I III V VII IX
                ${bspc-bin} monitor eDP-1 -d II IV VI VIII X
        elif [[ $HOSTNAME == anubis && $vm = *\ connected* ]]; then
                ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --primary --mode 1920x1080
                ${bspc-bin} monitor -d I II III IV V VI VII VIII IX X
        elif  [[ $HOSTNAME == anubis && $external = *\ connected* ]]; then
                ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1366x768 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
                ${bspc-bin} monitor HDMI-1 -d I III V VII IX
                ${bspc-bin} monitor eDP-1 -d II IV VI VIII X
        else
                ${bspc-bin} monitor -d I II III IV V VI VII VIII IX X
        fi
    '';
in
{
  config = {
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
        libweb # Tools and library for the WebP image format
        imagemagick

        jgmenu

        # system
        xdg-utils
        xdg-user-dirs # create xdg user dirs
        xdg-desktop-portal-gtk
      ];

      shellAliases = { is_picom_on = "${__ pkgs.procps "pgrep"} -x 'picom' > /dev/null && echo 'on' || echo 'off'"; };

      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        TERMINAL = "alacritty";
        GLFW_IM_MODULE = "ibus";
        TERM = "xterm-256color";
        QT_STYLE_OVERRIDE = mkDefault ""; # fix qt-override
      };

      file =
        let
          windowMan = "${_ config.xsession.windowManager.bspwm.package}"; # get bspwm executable path
        in
        {
          ".local/share/applications/bspwm.desktop" = mkIf (!hasSystemd) {
            text = ''
              [Desktop Entry]
              Name=bspwm
              Comment=Binary space partitioning window manager
              Exec=${windowMan}
              Type=Application
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
