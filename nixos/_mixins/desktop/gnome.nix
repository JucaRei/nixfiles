#
# Gnome configuration
#

{ config, lib, pkgs, ... }: {

  imports = [
    ../apps/terminal/tilix.nix
  ];

  programs = {
    dconf.enable = true;
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    calls = {
      enable = false;
    };
    gnupg.agent.pinentryFlavor = "gnome3";
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
          wayland = false; #only x11
        };
        defaultSession = "gnome";
      };
      desktopManager.gnome = {
        enable = true; # Window Manager
        extraGSettingsOverridePackages = [
          pkgs.nautilus-open-any-terminal
        ];
      };
    };
    # udev.packages = with pkgs; [
    #   gnome.gnome-settings-daemon
    # ];
    gnome = {
      gnome-user-share.enable = true;
      gnome-online-accounts.enable = false;
      gnome-initial-setup.enable = false;
      gnome-browser-connector = {
        enable = false;
      };
      gnome-remote-desktop = {
        enable = true;
      };
      sushi = {
        enable = true;
      };
    };
  };

  security.pam.services.gdm.enableGnomeKeyring = true;

  environment = {
    systemPackages = with pkgs; [
      # Packages installed
      gnome.dconf-editor
      gnome.adwaita-icon-theme
      gnome.gnome-tweaks
      nautilus-open-any-terminal
      # qogir-icon-theme
      gnome.nautilus-python
      libnotify
      # yaru-theme
      gthumb
      gparted
      gnomeExtensions.appindicator
      gnomeExtensions.window-is-ready-remover
    ];
    gnome.excludePackages = (with pkgs; [
      # Gnome ignored packages
      gnome-tour
      gnome-console
      gnome-text-editor
    ]) ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-font-viewer
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      yelp # Help view
      gnome-characters
      gnome-disk-utility
      gnome-music
      gnome-system-monitor
      totem
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      gnome-contacts
      gnome-maps
      gnome-initial-setup
    ]);

    sessionVariables = {
      NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
    };

    pathsToLink = [
      "/share/nautilus-python/extensions"
    ];
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; lib.mkForce [ xdg-desktop-portal-gnome ];
    };
  };
}
