{ config, desktop, hostname, inputs, lib, pkgs, platform, username, ... }:
let
  isWorkstation = if (desktop != null) then true else false;
  isServer = if (hostname == "DietPi") then true else false;
in
{
  # sha512crypt
  users.users.juca = {
    description = "Reinaldo P Jr";
    hashedPassword = "$6$A5gukqBVeM3eJblr$K6L1kxSDvJJjy6.LVx78d1QojtmGJBwpI3MPvc52h8H/Avg0KQW/uG6QazLiuoC2vGZ79nq3czvj96hEdSLUf1";
  };

  environment = {
    # Desktop environment applications/features I don't use or want
    gnome.excludePackages = with pkgs; ([
      gnome-tour
      baobab
      gnome-console
      gnome-text-editor
    ]) ++
    (with pkgs.gnome; [
      epiphany.geary
      gnome-music
      yelp
      gnome-terminal
      gnome-disk-utility
      gnome-system-monitor
      epiphany # web browser
      gnome-music
      gnome-system-monitor
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-initial-setup
      totem
    ]);

    mate.excludePackages = with pkgs.mate; [
      caja-dropbox
      eom
      mate-themes
      mate-netbook
      mate-icon-theme
      mate-backgrounds
      mate-icon-theme-faenza
    ];

    pantheon.excludePackages = with pkgs.pantheon; [
      elementary-code
      elementary-music
      elementary-photos
      elementary-videos
      epiphany
    ];

    systemPackages =
      (with pkgs; [
        _1password
        lastpass-cli
      ] ++ lib.optionals (isWorkstation) [
        _1password-gui
        gnome.dconf-editor
        libreoffice
        usbimager
        yaru-theme
      ] ++ lib.optionals (isWorkstation && (desktop == "gnome" || desktop == "pantheon")) [
        loupe
        marker
      ] ++ lib.optionals (isWorkstation && (desktop == "mate" || desktop == "pantheon")) [
        tilix
      ] ++ lib.optionals (isWorkstation && desktop == "gnome") [
        blackbox-terminal
        gnome-extension-manager
        gnomeExtensions.start-overlay-in-application-view
        gnomeExtensions.tiling-assistant
        gnomeExtensions.vitals
      ]) ++ (with pkgs.unstable; lib.optionals
        (isWorkstation) [
        fractal
        pika-backup
        # telegram-desktop
      ]);
  };

  systemd.tmpfiles.rules = [
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];

  programs.dconf.user.databases = [{
    settings = with lib.gvariant; lib.mkIf (isWorkstation) { };
  }];
}
