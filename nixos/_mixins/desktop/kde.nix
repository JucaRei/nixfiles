{ config, lib, pkgs, username, ... }:
{

  programs = {
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager = {
        sddm = {
          enable = true; # Display Manager
        };
        defaultSession = "plasmawayland";
      };
      desktopManager.plasma5 = {
        enable = true; # Desktop Environment
        excludePackages = with pkgs.libsForQt5; [
          elisa
          khelpcenter
          # konsole
          oxygen
        ];
      };
    };
  };

  gtk = {
    enable = true;

    iconTheme.package = pkgs.catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "mauve";
    };
    iconTheme.name = "Papirus-Dark";

    theme.package = pkgs.catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      tweaks = [ "rimless" ];
      variant = "mocha";
    };
    theme.name = "Catppuccin-Mocha-Standard-Mauve-dark";

    cursorTheme.package = pkgs.catppuccin-cursors.mochaDark;
    cursorTheme.name = "Catppuccin-Mocha-Dark-Cursors";
    cursorTheme.size = 24;

    font.name = "Iosevka Comfy";
  };


  environment = {
    systemPackages = with pkgs.libsForQt5; [
      # System-Wide Packages
      bismuth # Dynamic Tiling
      packagekit-qt # Package Updater
    ];
  };
}
