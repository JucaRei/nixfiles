{ pkgs, lib, ... }:
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
        xfburn
        xfce4-dict
        xfce4-dev-tools
        xfce4-eyes-plugin
      ];
      pathsToLink = [
        "/share/xfce4"
        "/share/themes"
        "/share/icons"
        "/share/mime"
        "/share/desktop-directories"
        "/share/gtksourceview-2.0"
      ];
      systemPackages = with pkgs; [
        pavucontrol
        networkmanagerapplet
        xfce4-whiskermenu-plugin
        xfce4-pulseaudio-plugin
        xfce4-screenshooter
        xfce4-clipman-plugin
        xfce4-taskmanager
        xfce4-sensors-plugin
        xfce4-cpufreq-plugin
        xfce4-netload-plugin
        xfce4-docklike-plugin
        ristretto
        mousepad
        libnotify
      ];
    };

    services = {
      xserver = {
        enable = true;
        desktopManager.xfce = {
          enable = true;
          enableWaylandSession = mkDefault false;
          enableScreensaver = mkDefault false;
        };
      };
      touchegg = {
        enable = mkDefault true;
      };
      blueman = {
        enable = mkDefault true;
      };
    };
    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        configPackages = [ (pkgs.xfce4-session or pkgs.xfce.xfce4-session) ];
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-xapp
        ];
        config = {
          common = {
            xfce = [
              "xapp"
              "gtk"
            ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-xapp" ];
          };
        };
      };
    };
  };
}
