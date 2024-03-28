# Gnome configuration
#
{ config, lib, pkgs, ... }: {
  imports = [
    # ../apps/terminal/tilix.nix
  ];

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
  location = {
    provider = "manual";
    latitude = -23.53938;
    longitude = -46.65253;
  };
}
