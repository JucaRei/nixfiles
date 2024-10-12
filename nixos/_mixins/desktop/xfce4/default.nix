{ lib, pkgs, config, ... }: {

  environment = {
    #   # Add some packages to complete the XFCE desktop
    systemPackages = with pkgs; [
      elementary-xfce-icon-theme
      tilix
      gparted
      xfce.xfconf
    ];
    pathsToLink = [
      "/share/xfce4"
      "/share/themes"
      "/share/mime"
      "/share/desktop-directories"
      "/share/gtksourceview-2.0"
    ];
    variables.GIO_EXTRA_MODULES = [ "${pkgs.xfce.gvfs}/lib/gio/modules" ];
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
    xfconf.enable = lib.mkDefault true;
    nm-applet.enable = true;
  };

  # Enable services to round out the desktop
  services = {
    # xserver = {
    #   updateDbusEnvironment = true;
    # };
    blueman.enable = true;
    xserver = {
      enable = true;
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

      desktopManager = { xfce.enable = true; };
    };
  };
}
