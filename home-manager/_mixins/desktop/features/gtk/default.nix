{ config, lib, pkgs, desktop, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf mkDefault;
  buttonLayout = if config.wayland.windowManager.hyprland.enable then "appmenu" else "close,minimize,maximize";
in
lib.mkIf isLinux {
  # TODO: Migrate to Colloid-gtk-theme 2024-06-18 or newer; now has catppuccin colors
  # - https://github.com/vinceliuice/Colloid-gtk-theme/releases/tag/2024-06-18
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/interface" = {
      color-scheme = mkDefault "prefer-dark";
      cursor-size = 24;
      cursor-theme = mkDefault "catppuccin-mocha-blue-cursors";
      gtk-theme = mkDefault "catppuccin-mocha-blue-standard";
      icon-theme = mkDefault "Papirus-Dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "${buttonLayout}";
      theme = mkDefault "catppuccin-mocha-blue-standard";
    };

    "org/mate/desktop/interface" = {
      gtk-decoration-layout = "${buttonLayout}";
      gtk-theme = mkDefault "catppuccin-mocha-blue-standard";
      icon-theme = mkDefault "Papirus-Dark";
    };

    "org/mate/desktop/peripherals/mouse" = {
      cursor-size = mkInt32 24;
      cursor-theme = mkDefault "Catppuccin-Mocha-Blue-Cursors";
    };

    "org/mate/marco/general" = {
      button-layout = "${buttonLayout}";
      theme = mkDefault "catppuccin-mocha-blue-standard";
    };

    "org/pantheon/desktop/gala/appearance" = mkIf (desktop == "pantheon" || desktop == "gnome") {
      button-layout = "${buttonLayout}";
    };
  };

  gtk = {
    cursorTheme = {
      name = mkDefault "catppuccin-mocha-blue-cursors";
      package = pkgs.catppuccin-cursors.mochaBlue;
      size = 24;
    };
    enable = true;
    font = {
      name = mkDefault "Work Sans 12";
      package = pkgs.work-sans;
    };
    gtk2 = {
      configLocation = "${config.xdg.configHome}/.gtkrc-2.0";
      extraConfig = mkDefault ''
        gtk-application-prefer-dark-theme = 1
        gtk-button-images = 1
        gtk-decoration-layout = "${buttonLayout}"
      '';
    };
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = mkDefault 1;
        gtk-button-images = mkDefault 1;
        gtk-decoration-layout = "${buttonLayout}";
      };
    };
    gtk4 = {
      extraConfig = {
        gtk-decoration-layout = "${buttonLayout}";
      };
    };
    iconTheme = {
      name = mkDefault "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "blue";
      };
    };
    theme = {
      name = mkDefault "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "mocha";
      };
    };
  };
  home = {
    packages = with pkgs; [ papirus-folders ];
    pointerCursor = {
      name = mkDefault "catppuccin-mocha-blue-cursors";
      package = pkgs.catppuccin-cursors.mochaBlue;
      size = 24;
      gtk.enable = mkDefault true;
      x11.enable = mkDefault true;
    };
  };
}
