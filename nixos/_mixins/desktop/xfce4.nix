{ inputs, lib, pkgs, ... }: {
  imports = [
    ../config/qt/qt-style.nix
    ../apps/terminal/tilix.nix
  ];

  # Exclude MATE themes. Yaru will be used instead.
  # Don't install mate-netbook or caja-dropbox
  environment = {
    xfce.excludePackages = with pkgs; [

    ];

    # Add some packages to complete the MATE desktop
    systemPackages = with pkgs; [
      elementary-xfce-icon-theme
      gparted
      gthumb
      networkmanagerapplet
      xdotool
      xfce.catfish
      xfce.orage
      xfce.gigolo
      xfce.xfce4-appfinder
      xfce.xfce4-clipman-plugin
      xfce.xfce4-fsguard-plugin
      xfce.xfce4-genmon-plugin
      xfce.xfce4-netload-plugin
      xfce.xfce4-panel
      xfce.xfce4-session
      xfce.xfce4-settings
      xfce.xfce4-systemload-plugin
      xfce.xfce4-power-manager
      xfce.xfce4-terminal
      xfce.xfce4-screensaver
      xfce.xfce4-screenshooter
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-systemload-plugin
      xfce.xfce4-weather-plugin
      xfce.xfce4-whiskermenu-plugin
      xfce.xfce4-xkb-plugin
      xorg.xev
      xsel
      zuki-themes
      # inputs.nix-software-center.packages.${system}.nix-software-center
    ];
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
    xfconf.enable = true;
    nm-applet.enable = true;
    seahorse.enable = true;
    # system-config-printer.enable = true;
  };

  # Enable services to round out the desktop
  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
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
  # security.pam.services.gdm.enableGnomeKeyring = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}
