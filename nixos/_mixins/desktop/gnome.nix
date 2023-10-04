#
# Gnome configuration
#

{ config, lib, pkgs, ... }: {

  imports = [
    ../apps/terminal/tilix.nix
  ];

  programs = {
    dconf.enable = true;
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  services = {
    xserver = {
      enable = true;
      # modules = [ pkgs.xf86_input_wacom ]; # Both needed for wacom tablet usage
      # wacom.enable = true;

      displayManager = {
        gdm.enable = true; # Display Manager
        defaultSession = "gnome";
      };
      desktopManager.gnome.enable = true; # Window Manager
    };
    udev.packages = with pkgs; [
      gnome.gnome-settings-daemon
    ];

    # Disable some core OS services
    # evolution-data-server.enable = mkForce false;
    # gnome-online-accounts.enable = false;
    # gnome-online-miners.enable = lib.mkForce false;
    # tracker.enable = false;
    # tracker-miners.enable = false;
  };

  security.pam.services.gdm.enableGnomeKeyring = true;

  environment = {
    systemPackages = with pkgs; [
      # Packages installed
      gnome.dconf-editor
      gnome.gnome-tweaks
      gnome.adwaita-icon-theme
      gnome.mutter
      gnome.libgnome-keyring
      libnotify
      yaru-theme
      gthumb
      gparted
      gnomeExtensions.appindicator
      gnomeExtensions.window-is-ready-remover
    ];
    gnome.excludePackages = (with pkgs; [
      # Gnome ignored packages
      gnome-tour
      gnome-console
    ]) ++ (with pkgs.gnome; [
      # gedit
      epiphany
      gnome-disk-utility
      gnome-music
      gnome-system-monitor
      geary
      totem
      gnome-characters
      tali
      iagno
      hitori
      atomix
      yelp
      gnome-contacts
      gnome-initial-setup
    ]);
  };
}
