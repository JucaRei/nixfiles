{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  features.graphics.backend = "x11";
  environment = {
    xfce.excludePackages = with pkgs.xfce // pkgs; [
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
    systemPackages = with pkgs.xfce // pkgs // pkgs.mate // pkgs.xorg // pkgs.gnome; [
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
    variables.GIO_EXTRA_MODULES = mkDefault [ "${pkgs.gnome.gvfs}/lib/gio/modules" ];
  };

  # Enable some programs to provide a complete desktop
  programs = {
    xfconf.enable = mkDefault true;
    nm-applet.enable = true;
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
      displayManager = {
        lightdm = {
          enable = true;
          greeters = {
            gtk = {
              enable = true;
              cursorTheme.name = "Yaru";
              cursorTheme.package = pkgs.yaru-theme;
              cursorTheme.size = 24;
              iconTheme.name = lib.mkDefault "Yaru-magenta-dark";
              iconTheme.package = pkgs.yaru-theme;
              theme.name = lib.mkDefault "Yaru-magenta-dark";
              theme.package = pkgs.yaru-theme;
              indicators = [
                "~session"
                "~host"
                "~spacer"
                "~clock"
                "~spacer"
                "~a11y"
                "~power"
              ];
              # https://github.com/Xubuntu/lightdm-gtk-greeter/blob/master/data/lightdm-gtk-greeter.conf
              extraConfig = ''
                # background = Background file to use, either an image path or a color (e.g. #772953)
                font-name = Work Sans 12
                xft-antialias = true
                xft-dpi = 96
                xft-hintstyle = slight
                xft-rgba = rgb

                active-monitor = #cursor
                # position = x y ("50% 50%" by default)  Login window position
                # default-user-image = Image used as default user icon, path or #icon-name
                hide-user-image = false
                round-user-image = false
                highlight-logged-user = true
                panel-position = top
                clock-format = %a, %b %d  %H:%M
              '';
            };
          };
        };
      };
      desktopManager = {
        xfce = {
          enable = true;
          enableXfwm = true;
        };
      };
    };
  };
  security.pam.services.lightdm.enableGnomeKeyring = true;
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
}
