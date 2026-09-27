{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    desktop = {
      display-servers.backend = "x11";
      display-managers.name = mkDefault "lightdm";
    };

    services = {
      xserver = {
        enable = true;
        displayManager.session = [
          {
            manage = "window";
            name = "dwm";
            start = ''
              if [ -f "$HOME/.local/bin/start-dwm" ]; then
                exec "$HOME/.local/bin/start-dwm"
              elif [ -f "$HOME/.xsession" ]; then
                exec "$HOME/.xsession"
              else
                exec dwm
              fi
            '';
          }
        ];
      };
      displayManager.defaultSession = mkDefault "dwm";
      blueman.enable = mkDefault true;
      udev.packages = [ pkgs.brightnessctl ];
    };

    security.polkit.enable = true;
    programs.dconf.enable = true;

    environment = {
      pathsToLink = [
        "/share/themes"
        "/share/icons"
        "/share/mime"
        "/share/desktop-directories"
      ];
      systemPackages = with pkgs; [
        # Window manager básico e fallback no nível do sistema
        dwm
        dmenu
        slstatus

        # Autenticação e Polkit
        polkit_gnome

        # Utilitários X11
        brightnessctl
        libnotify
        networkmanagerapplet
        feh
        picom
      ];
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };
  };
}
