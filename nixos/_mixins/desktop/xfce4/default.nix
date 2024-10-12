{ lib, pkgs, config, ... }:
let
  inherit (lib) mkDefault;
in
{
  environment = {
    #   # Add some packages to complete the XFCE desktop
    systemPackages = with pkgs.xfce // pkgs // pkgs.mate // pkgs.xorg; [
      elementary-xfce-icon-theme
      atril
      gparted
      orage
      xfconf
      galculator
      xfce4-pulseaudio-plugin
      xfce4-whiskermenu-plugin
      xfce4-weather-plugin
      xclip
      xkill
      (writeShellApplication {
        name = "xfce4-panel-toggle";
        runtimeInputs = [ xfce.xfconf ];
        text = ''
          for num in {0,1}
          do
            current=$(xfconf-query -c xfce4-panel -p /panels/panel-"$num"/autohide-behavior)
            if [[ current -eq 1 ]]; then next=0; else next=1; fi
            xfconf-query -c xfce4-panel -p /panels/panel-"$num"/autohide-behavior -s $next
          done
        '';
      })
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
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };
    xfconf.enable = mkDefault true;
    nm-applet.enable = true;
  };

  # Enable services to round out the desktop
  services = {
    colord.enable = true;
    blueman.enable = true;
    touchegg.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "xfce";
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
}
