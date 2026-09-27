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
        windowManager.dwm.enable = true;
      };
      displayManager.defaultSession = mkDefault "none+dwm";
      blueman.enable = mkDefault true;
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
