{ config, pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    desktop = {
      display-servers.backend = "x11";
      display-managers.name = "lightdm";
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
      pathsToLink = [
        "/share/xfce4"
        "/share/themes"
        "/share/mime"
        "/share/desktop-directories"
        "/share/gtksourceview-2.0"
      ];
    };

    services = {
      xserver.desktopManager.xfce = {
        enable = true;
        enableWaylandSession = mkDefault false;
        enableScreensaver = mkDefault false;
      };
      displayManager = {
        defaultSession = "xfce";
        xrdp.defaultWindowManager = "xfce4-session";
      };
      touchegg.enable = mkDefault true;
      blueman.enable = mkDefault true;
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
