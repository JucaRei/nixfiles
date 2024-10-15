{ config, isInstall, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
in
{
  imports = [ ./greetd.nix ];
  environment = {
    # Enable HEIC image previews in Nautilus
    pathsToLink = [ "share/thumbnailers" ];
    homeBinInPath = true;
    sessionVariables = {
      # Make sure the cursor size is the same in all environments
      HYPRCURSOR_SIZE = 24;
      HYPRCURSOR_THEME = "catppuccin-mocha-blue-cursors";
      NIXOS_OZONE_WL = 1;
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    };
    variables = mkIf (config.features.graphics.backend == "wayland" && config.features.graphics.gpu == "hybrid-nvidia") {
      NVD_GPU = 1;
    };
    systemPackages =
      with pkgs // pkgs.gnome;
      lib.optionals isInstall [
        hyprpicker
        # Enable HEIC image previews in Nautilus
        libheif
        libheif.out
        unstable.monitorets
        gnome-font-viewer
        nautilus # file manager
        zenity
        alacritty
        polkit_gnome
        wdisplays # display configuration
        wlr-randr
        unstable.catppuccin-cursors
      ];
  };

  programs = {
    dconf.profiles.user.databases = [{
      settings = with lib.gvariant; {
        "org/gnome/desktop/interface" = {
          clock-format = "24h";
          color-scheme = "prefer-dark";
          cursor-size = mkInt32 24;
          cursor-theme = "catppuccin-mocha-blue-cursors";
          document-font-name = "Work Sans 11";
          font-name = "Work Sans 11";
          gtk-theme = "catppuccin-mocha-blue-standard";
          gtk-enable-primary-paste = true;
          icon-theme = "Papirus-Dark";
          monospace-font-name = "FiraCode Nerd Font Mono Medium 12";
          text-scaling-factor = mkDouble 1.0;
        };

        "org/gnome/desktop/sound" = {
          theme-name = "freedesktop";
        };

        "org/gtk/gtk4/Settings/FileChooser" = {
          clock-format = "24h";
        };

        "org/gtk/Settings/FileChooser" = {
          clock-format = "24h";
        };
      };
    }];
    file-roller = {
      enable = isInstall;
      package = pkgs.gnome.nautilus;
    };
    gnome-disks.enable = isInstall;
    hyprland = {
      enable = true;
      systemd.setPath.enable = true;
    };
    nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };
    seahorse.enable = isInstall;
    udevil.enable = true;
  };
  security = {
    pam.services.hyprlock = { };
    polkit = {
      enable = true;
    };
  };

  services = {
    devmon.enable = true;
    gnome = {
      gnome-keyring.enable = isInstall;
      sushi.enable = isInstall;
    };
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      configPackages = [ pkgs.hyprland ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        (xdg-desktop-portal-gtk.override {
          # Use the upstream default so this won't conflict with the xapp portal.
          buildPortalsInGnome = false;
        })
      ];
      config = {
        common = {
          default = [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };
  };
}
