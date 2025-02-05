{ lib, pkgs, ... }:
let
  inherit (lib) mkIf;

  apps = with pkgs; [
    gnome-usage

    gnome-extension-manager
    gnome-tweaks
    # glide-media-player # video player
    decibels # audio player
    papers # document viewer
  ];

  extensions = with pkgs.gnomeExtensions; [
    appindicator
    dash-to-dock
    emoji-copy
    just-perfection
    logo-menu
    wireless-hid
    wifi-qrcode
    workspace-switcher-manager
    start-overlay-in-application-view
    tiling-assistant
    vitals
  ];
in
