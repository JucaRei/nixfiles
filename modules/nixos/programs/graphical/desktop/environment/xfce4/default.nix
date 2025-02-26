{ lib, pkgs, config, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = [ ../../display-manager/lightdm ];

  config = {
    programs = {
      graphical.desktop.backend = "x11";
      # Enable some programs to provide a complete desktop
      xfconf.enable = mkDefault true;
      nm-applet.enable = true;
    };

    environment = {
      xfce.excludePackages = with pkgs.xfce // pkgs; [
        orage
        amberol
        parole
        xfburn
        xarchiver
        xfce4-dict
        xfce4-dev-tools
        xfce4-mpc-plugin
        xfce4-taskmanager
        xfce4-eyes-plugin
        xfce4-verve-plugin
        xfce4-notes-plugin
        xfce4-sensors-plugin
        xfce4-cpufreq-plugin
        xfce4-netload-plugin
        xfce4-docklike-plugin
        xfce4-dockbarx-plugin
        xfce4-cpugraph-plugin
        xfce4-mailwatch-plugin
      ];
      #   # Add some packages to complete the XFCE desktop
      systemPackages = with pkgs // pkgs.xfce // pkgs // pkgs.mate // pkgs.xorg; [
        atril
        xfconf
        xfce4-pulseaudio-plugin
        xfce4-whiskermenu-plugin
        xfce4-weather-plugin
        xclip
        xkill
      ];
      pathsToLink = [
        "/share/xfce4"
        "/share/themes"
        "/share/mime"
        "/share/desktop-directories"
        "/share/gtksourceview-2.0"
      ];
      # variables.GIO_EXTRA_MODULES = mkDefault [ "${pkgs.gnome.gvfs}/lib/gio/modules" ];
    };

    # Enable services to round out the desktop
    services = {
      colord.enable = true;
      blueman.enable = true;
      touchegg.enable = true;
      # gnome.gnome-keyring.enable = true;
      displayManager = {
        defaultSession = "xfce";
      };
      xrdp.defaultWindowManager = "xfce4-session";
      xserver = {
        enable = true;
        desktopManager = {
          xfce = {
            enable = true;
            enableXfwm = true;
          };
        };
      };
    };
    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        configPackages = [ pkgs.xfce.xfce4-session ];
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-xapp
        ];
        config = {
          common = {
            xfce = [ "xapp" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-xapp" ];
          };
        };
      };
    };
  };
}
