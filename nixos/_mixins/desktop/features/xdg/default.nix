{ desktop, lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkOption types optionals;
  cfg = config.desktop.features.xdg;
  xapps = (desktop == "xfce4") || (desktop == "mate") || (desktop == "cinnamon");
in
{
  options = {
    desktop.features.xdg = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = "Whether xdg defaults for desktop.";
      };
    };
  };
  config = mkIf cfg.enable {
    xdg = {
      portal = {

        configPackages = [ ] ++ optionals (desktop == "hyprland") [
          pkgs.hyprland
        ];

        extraPortals = with pkgs; [ ]
          ++ optionals (desktop == "gnome") [
          xdg-desktop-portal-gnome
        ] ++ optionals (desktop == "budgie") [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ] ++ optionals (desktop == "hyprland") [
          xdg-desktop-portal-hyprland
        ] ++ optionals (xapps) [
          xdg-desktop-portal-xapp
          (xdg-desktop-portal-gtk.override {
            # Use the upstream default so this won't conflict with the xapp portal.
            buildPortalsInGnome = false;
          })
        ] ++ optionals (desktop == "pantheon") [
          pantheon.xdg-desktop-portal-pantheon
        ];

        config = {
          common = {
            default = [ "gtk" ];
          };
          gnome = mkIf (desktop == "gnome") {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
          # bspwm = (desktop == "bspwm") {
          #   default = [ "gnome" "gtk" ];
          #   "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          # };
          # budgie = (desktop == "budgie") {
          #   default = [ "gnome" "gtk" ];
          #   "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          # };
          hyprland = mkIf (desktop == "hyprland") {
            default = [ "hyprland" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
          x-cinnamon = mkIf (desktop == "cinnamon") {
            default = [ "xapp" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
          # mate = mkIf (desktop == "mate") {
          #   default = [ "xapp" "gtk" ];
          #   "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          # };
          # xfce = mkIf (desktop == "xfce4") {
          #   default = [ "xapp" "gtk" ];
          #   "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          # };
          pantheon = mkIf (desktop == "pantheon") {
            default = [ "pantheon" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
        enable = true;
        xdgOpenUsePortal = true;
      };
      terminal-exec = {
        enable = true;
        settings = {
          default = [ ]
            ++ optionals (desktop == "gnome") [
            "com.raggesilver.BlackBox.desktop"
          ] ++
            optionals (desktop == "budgie") [
              "com.gexperts.Tilix.desktop"
            ];
        };
      };
    };
    # Fix xdg-portals opening URLs: https://github.com/NixOS/nixpkgs/issues/189851
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };
}
