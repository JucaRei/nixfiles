{ inputs, lib, pkgs, config, ... }: {
  imports = [
    ../config/qt/qt-style.nix
    ../apps/terminal/tilix.nix
  ];

  # Exclude MATE themes. Yaru will be used instead.
  # Don't install mate-netbook or caja-dropbox
  # environment = {
  #   # Add some packages to complete the XFCE desktop
  #   systemPackages = with pkgs; [
  #     elementary-xfce-icon-theme
  #     gparted
  #     gthumb
  #     networkmanagerapplet
  #     xfce.catfish
  #     xfce.orage
  #     xfce.gigolo
  #     xfce.xfce4-appfinder
  #     xfce.xfce4-panel
  #     xfce.xfce4-session
  #     xfce.xfce4-settings
  #     xfce.xfce4-power-manager
  #     xfce.xfce4-terminal
  #     xfce.xfce4-screensaver
  #     xfce.xfce4-pulseaudio-plugin
  #     xfce.xfce4-systemload-plugin
  #     xfce.xfce4-weather-plugin
  #     xfce.xfce4-whiskermenu-plugin
  #     xfce.xfce4-xkb-plugin
  #     xsel
  #     zuki-themes
  #     # inputs.nix-software-center.packages.${system}.nix-software-center
  #   ];
  #   pathsToLink = [
  #     "/share/xfce4"
  #     "/share/themes"
  #     "/share/mime"
  #     "/share/desktop-directories"
  #     "/share/gtksourceview-2.0"
  #   ];
  #   variables.GIO_EXTRA_MODULES = [
  #     "${pkgs.xfce.gvfs}/lib/gio/modules"
  #   ];
  # };

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
    xfconf.enable = lib.mkDefault true;
    nm-applet.enable = true;
    seahorse.enable = true;
    dconf = {
      enable = lib.mkDefault false;
    };
    # system-config-printer.enable = true;
  };

  # Enable services to round out the desktop
  services = {
    # dbus = {
    #   packages = with pkgs; [ xfconf ];
    # };
    # xserver = {
    #   updateDbusEnvironment = true;
    # };
    upower.enable = config.powerManagement.enable;
    blueman.enable = true;
    # gnome.gnome-keyring.enable = true;
    # system-config-printer.enable = true;
    xserver = {
      enable = true;
      libinput = {
        touchpad = {
          middleEmulation = true;
        };
      };
      displayManager = {
        lightdm.enable = true;
        lightdm.greeters.gtk = {
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

      desktopManager = {
        xfce.enable = true;
      };
    };
  };
  sound = {
  	enable = true;
  	mediaKeys = {
  		enable = true;
  	};
  };
  # security.pam.services.gdm.enableGnomeKeyring = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}
