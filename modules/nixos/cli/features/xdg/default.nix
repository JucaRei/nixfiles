{ desktop, lib, ... }:
{
  programs.dconf.enable = lib.mkDefault true;
  xdg = {
    portal = {
      config = {
        common = {
          default = [ "gtk" ];
        };
        gnome = lib.mkIf
          (
            desktop == "gnome" ||
            desktop == "bspwm" ||
            desktop == "hyprland" ||
            desktop == "budgie"
          )
          {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        pantheon = lib.mkIf (desktop == "pantheon") {
          default = [ "pantheon" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        x-cinnamon = lib.mkIf (desktop == "mate" || desktop == "cinnamon" || desktop == "xfce") {
          default = [ "xapp" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        plasma = lib.mkIf
          (
            desktop == "kde" ||
            desktop == "hyprland" ||
            desktop == "lxqt"
          )
          {
            default = [ "kde" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "xdg-desktop-portal-kde" ];
          };
      };
      enable = true;
      xdgOpenUsePortal = true;
    };
    terminal-exec = {
      enable = true;
      settings = {
        default = [ "Alacritty.desktop" ];
      };
    };
  };
}
