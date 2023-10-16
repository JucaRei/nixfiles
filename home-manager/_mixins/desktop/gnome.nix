#
# Gnome Home-Manager Configuration
#
# Dconf settings can be found by running "$ dconf watch /"
#

{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{


  home = {
    packages = with pkgs; [
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.blur-my-shell
      gnomeExtensions.removable-drive-menu
      gnomeExtensions.dash-to-panel
      gnomeExtensions.battery-indicator-upower
      gnomeExtensions.just-perfection
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.workspace-indicator-2
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.gsconnect # kdeconnect enabled in default.nix
      gnomeExtensions.pip-on-top
      gnomeExtensions.pop-shell
      gnomeExtensions.forge
      # gnomeExtensions.fullscreen-avoider
      # gnomeExtensions.dash-to-dock

      gnome3.gvfs
      gnome3.nautilus
    ];

    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
    };
  };
}
