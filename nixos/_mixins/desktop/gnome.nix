{ config, lib, pkgs, ... }: {

  environment = {
    ### Exclude Packages
    gnome.excludePackages = with pkgs; ([
      gnome-tour
      baobab
      gnome-console
      gnome-text-editor
      evolutionWithPlugins
    ])
    ++ (with pkgs.gnome;[
      gnome-maps
      geary
      gnome-music
      yelp
      gnome-characters
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

    systemPackages = with pkgs; [
      gnome.dconf-editor
      usbimager
      yaru-theme
      loupe
      marker
      blackbox-terminal
    ];
  };

  services = {
    xserver = {
      enable = true;
      # modules = [ pkgs.xf86_input_wacom ]; # Both needed for wacom tablet usage
      # wacom.enable = true;

      displayManager = {
        gdm = {
          enable = true; # Display Manager
          settings = {
            greeter.IncludeAll = true;
          };
          wayland = false; # only x11
        };
        defaultSession = "gnome";
        hiddenUsers = [ "nobody" ];
      };
      desktopManager.gnome = {
        enable = true; # Window Manager
        extraGSettingsOverridePackages = [ pkgs.nautilus-open-any-terminal ];
        extraGSettingsOverrides = ''
          [org.gnome.desktop.peripherals.touchpad]
          tap-to-click=true
        '';
      };
    };
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
    gnome = {
      gnome-user-share.enable = true;
      gnome-online-accounts.enable = false;
      gnome-initial-setup.enable = false;
      # gnome-browser-connector = {
      #   enable = false;
      # };
      gnome-remote-desktop = {
        enable = true;
      };
      sushi = {
        enable = true;
      };

      # disabled
      # install extensions declaratively with home-manager dconf options
      # gnome-browser-connector.enable = false;
    };
  };

  programs = {
    evolution.enable = lib.mkForce false;
    gnupg.agent.pinentryFlavor = "gnome3";
  };

  security.pam.services.gdm.enableGnomeKeyring = true;

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      # extraPortals = with pkgs; lib.mkForce [ xdg-desktop-portal-gnome ];
      config = {
        common = { default = [ "gnome" ]; };
        gnome = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };
  };
}
