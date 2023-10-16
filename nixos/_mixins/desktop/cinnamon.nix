{ config, pkgs, ... }: {
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
      desktopManager = {
        cinnamon = {
          enable = true;
        };
      };
    };
    redshift = {
      enable = true;
    };
    geoclue2.enable = true;
  };
  environment = {
    systemPackages = (with pkgs; [
      blueberry
    ])
    ++ (with pkgs.cinnamon; [
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
    cinnamon.excludePackages = (with pkgs; [
      orca
    ])
    ++ (with pkgs.cinnamon; [
      # cinnamon-spice-updater
    ]);
  };
  xdg = {
    portal = {
      enable = true;
      extraPortals = [
        (pkgs.xdg-desktop-portal-gtk.override {
          # Use the upstream default so this won't conflict with the xapp portal.
          buildPortalsInGnome = false;
        })
      ];
    };
  };
}
