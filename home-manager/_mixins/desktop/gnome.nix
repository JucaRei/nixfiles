{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  home = {
    packages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.user-themes
      # gnomeExtensions.aylurs-widgets
      gnomeExtensions.hide-activities-button
      gnome.mutter
      gnomeExtensions.battery-indicator-upower
      gnomeExtensions.bluetooth-quick-connect
      gnome-extension-manager
      gnome.libgnome-keyring
      gnomeExtensions.forge
      gnomeExtensions.gsconnect # kdeconnect enabled in default.nix
      gnomeExtensions.dash-to-dock
      # gnomeExtensions.tray-icons-reloaded
      # gnomeExtensions.removable-drive-menu
      # gnomeExtensions.dash-to-panel
      # gnomeExtensions.battery-indicator-upower
      # gnomeExtensions.caffeine
      # gnomeExtensions.workspace-indicator-2
      # gnomeExtensions.bluetooth-quick-connect
      # gnomeExtensions.pip-on-top
      # gnomeExtensions.pop-shell
      # gnomeExtensions.fullscreen-avoider

      gnome3.gvfs
      gnome3.nautilus
    ];

    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
    };
  };

  # GTK Configuration
  gtk = {
    enable = true;
    font = {
      package = pkgs.fira;
      name = "Fira 10";
    };
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-light-solid-pink";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
  };
  dconf = {
    settings = {
      
    };
  };
}
