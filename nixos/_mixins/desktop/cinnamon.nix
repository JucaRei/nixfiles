{ config, pkgs, lib, ... }: {
  imports = [ ../config/qt/qt-style.nix ];
  services = {
    xserver = {
      enable = true;
      displayManager = {
        lightdm = {
          enable = true;
          greeters = {
            slick = {
              theme.name = "Mint-Y-Sand";
              iconTheme.name = "Mint-Y-Sand";
              draw-user-backgrounds = true;
            };
          };
        };
      };
      desktopManager = { cinnamon = { enable = true; }; };
    };
    redshift = {
      enable = true;
      temperature = {
        day = 5500;
        night = 3000;
      };
    };
    geoclue2.enable = true;
    cinnamon.apps.enable = true;
    gnome = { evolution-data-server = { enable = lib.mkDefault false; }; };
  };
  environment = {
    systemPackages = (with pkgs; [ blueberry ]) ++ (with pkgs.cinnamon; [
      nemo
      nemo-with-extensions
      nemo-python
      nemo-fileroller
      warpinator
      mint-y-icons
      mint-x-icons
      mint-artwork
      cinnamon-common
      cinnamon-session
      cinnamon-screensaver
      cinnamon-menus
      cinnamon-gsettings-overrides
      cinnamon-desktop
    ]);
    cinnamon.excludePackages = (with pkgs; [ orca xplayer ])
      ++ (with pkgs.cinnamon; [ cinnamon-translations pix ])
      ++ (with pkgs.gnome;
        [
          geary
          # gnome-disk-utility
        ]);
  };
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      ## 23.05
      # extraPortals = [
      #   (pkgs.xdg-desktop-portal-gtk.override {
      #     # Use the upstream default so this won't conflict with the xapp portal.
      #     buildPortalsInGnome = false;
      #   })
      # ];
      ## 23.11
      config = {
        common = { default = [ "xapp" ]; };
        cinnamon = {
          default = [ "xapp" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "xapp" ];
        };
      };
    };
  };
}
