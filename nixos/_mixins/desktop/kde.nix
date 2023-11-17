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
          autoNumlock = true;

          settings = {
            Theme = {
              CursorTheme = "layan-border_cursors";
            };
          };
        };
        # defaultSession = "plasmawayland";
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
      videoDrivers = [
        "fbdev" # The fbdev (Framebuffer Device) driver is a generic framebuffer driver that provides access to the frame buffer of the display hardware.
        # "modesetting"     # The modesetting driver is a generic driver for modern video hardware that relies on kernel modesetting (KMS) to set the display modes and manage resolution and refresh rate.
        # "amdgpu"          # This is the open-source kernel driver for AMD graphics cards. It's part of the AMDGPU driver stack and provides support for newer AMD GPUs.
        # "nouveau"         # Nouveau is an open-source driver for NVIDIA graphics cards. It aims to provide support for NVIDIA GPUs and is an alternative to the proprietary NVIDIA driver
        # "radeon"          # The Radeon driver is an open-source driver for AMD Radeon graphics cards. It provides support for older AMD GPUs.
      ];
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
    systemPackages = (with pkgs.libsForQt5; [
      # System-Wide Packages
      bismuth # Dynamic Tiling
      packagekit-qt # Package Updater
      kaccounts-integration
      kaccounts-providers
    ]) ++ (with pkgs; [
      libportal-qt5
    ]);
  };
}
