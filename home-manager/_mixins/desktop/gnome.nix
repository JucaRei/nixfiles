{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  home = {
    packages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.user-themes
      # gnomeExtensions.aylurs-widgets
      gnomeExtensions.hide-activities-button
      gnomeExtensions.caffeine
      gnome.mutter
      gnomeExtensions.battery-indicator-upower
      gnomeExtensions.bluetooth-quick-connect
      gnome-extension-manager
      gnome.libgnome-keyring
      gnomeExtensions.forge
      gnomeExtensions.gsconnect # kdeconnect enabled in default.nix
      gnomeExtensions.dash-to-dock
      # gnomeExtensions.tray-icons-reloaded
      # gnomeExtensions.removable-drive-menu
      # gnomeExtensions.dash-to-panel
      # gnomeExtensions.battery-indicator-upower
      # gnomeExtensions.workspace-indicator-2
      # gnomeExtensions.bluetooth-quick-connect
      # gnomeExtensions.pip-on-top
      # gnomeExtensions.pop-shell
      # gnomeExtensions.fullscreen-avoider

      gnome3.gvfs
      gnome3.nautilus
    ];

    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
    };
  };

  # GTK Configuration
  gtk = {
    enable = true;
    font = {
      package = pkgs.fira;
      name = "Fira 10";
    };
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-light-solid-pink";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
  };
  dconf = {
    settings = {
      "org/gnome/desktop/background" = {
        picture-uri = "file:///" + ../config/wallpapers/122.jpg;
      };
      "org/gnome/desktop/interface" = {
        clock-format = "24h";
        clock-show-weekday = true;
        show-battery-percentage = true;
      };
      "org/gnome/gnome-session" = {
        auto-save-session = true;
      };
      "org/gnome/mutter" = {
        center-new-windows = true;
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-user-extensions = [ ];
        disable-extension-version-validation = true;
        enabled-extensions = [
          "dash-to-dock@micxgx.gmail.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "Hide_Activities@shay.shayel.org"
          "caffeine@patapon.info"
          "blur-my-shell@aunetx"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        # position
        dock-position = "BOTTOM";
        dock-fixed = false;
        extend-height = false;
        # icons
        dash-max-icon-size = 48;
        icon-size-fixed = true;
        show-apps-at-top = true;
        # clicking
        click-action = "previews";
        scroll-action = "cycle-windows";
        shift-click-action = "launch";
        middle-click-action = "minimise";
        shift-middle-click-action = "launch";
        running-indicator-dominant-color = true;
        running-indicator-style = "DASHES";
        # visibility
        intellihide = true;
        isolate-workspaces = true;
        autohide = true;
        autohide-in-full-screen = true;
        require-pressure-to-show = true;
        # transparency
        transparency-mode = "FIXED";
        background-opacity = 0.1;
      };
      "org/gnome/shell/extensions/blur-my-shell" = {
        blur-dash = false;
        blur-panel = false;
        brightness = 0.75;
        sigma = 25;
      };
      "org/gnome/shell/extensions/user-theme" = {
        name = "WhiteSur-light-solid-pink";
      };
    };
  };
}
