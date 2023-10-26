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


  environment = {
    systemPackages = with pkgs.libsForQt5; [
      # System-Wide Packages
      bismuth # Dynamic Tiling
      packagekit-qt # Package Updater
    ];
  };
}
