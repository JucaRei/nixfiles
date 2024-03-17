# Gnome configuration
#
{ config
, lib
, pkgs
, ...
}: {
  imports = [ 
    # ../apps/terminal/tilix.nix 
  ];

  programs = {
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    calls = { enable = false; };
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
          wayland = false; # only x11
        };
        defaultSession = "gnome";
      };
      desktopManager.gnome = {
        enable = true; # Window Manager
        extraGSettingsOverridePackages = [ pkgs.nautilus-open-any-terminal ];
      };
    };
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
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
  location = {
    provider = "manual";
    latitude = -23.53938;
    longitude = -46.65253;
  };
}
