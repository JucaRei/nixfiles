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
        windowManager.bspwm.enable = true;
      };
      displayManager.defaultSession = mkDefault "none+bspwm";
      touchegg.enable = mkDefault true;
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
        # Window manager & hotkeys
        bspwm
        sxhkd
        polybar
        rofi
        picom
        dunst
        feh

        # Authentication & Polkit
        polkit_gnome

        # Audio & Volume
        pavucontrol
        pamixer
        playerctl

        # Utilities
        brightnessctl
        flameshot
        xclip
        xsel
        xdotool
        libnotify
        networkmanagerapplet

        # Terminal & File manager
        alacritty
        thunar
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
