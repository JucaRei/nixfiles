{ desktop, lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkOption types optionals;
  cfg = config.desktop.features.xdg;
in
{
  options = {
    desktop.features.xdg = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Whether xdg defaults for desktops.";
      };
    };
  };
  config = mkIf cfg.enable {
    xdg = {
      portal = {
        configPackages = [ ] ++ optionals (desktop == "hyprland") [
          pkgs.hyprland
        ];
        extraPortals = optionals (desktop == "gnome") [
          pkgs.xdg-desktop-portal-gnome
        ] ++ optionals (desktop == "hyprland") [
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ] ++ optionals (desktop == "mate" || desktop == "cinnamon") [
          pkgs.xdg-desktop-portal-xapp
          pkgs.xdg-desktop-portal-gtk
        ] ++ optionals (desktop == "pantheon") [
          pkgs.pantheon.xdg-desktop-portal-pantheon
          pkgs.xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [ "gtk" ];
          };
          gnome = mkIf (desktop == "gnome" || desktop == "bspwm") {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
          hyprland = mkIf (desktop == "hyprland") {
            default = [ "hyprland" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
          x-cinnamon = mkIf (desktop == "mate" || desktop == "cinnamon") {
            default = [ "xapp" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
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
