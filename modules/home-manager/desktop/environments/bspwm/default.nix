{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf;
  isNixOS = osConfig != null;
in
{
  imports = [
    ./bspwm.nix
    ./sxhkd.nix
    ./polybar
    ./picom.nix
    ./dunst.nix
    ./rofi.nix
    ./packages.nix
  ];

  config = mkIf config.desktop.bspwm.enable {
    desktop.display-servers.backend = "x11";

    # --- Programas Padrão do BSPWM ---
    system.programs = {
      file-manager.thunar.enable = true;
      tools.flameshot.enable = true;
    };

    # --- Tema e Aparência GTK (Catppuccin Mocha + Papirus Dark) ---
    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin-Mocha-Standard-Blue-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "standard";
          tweaks = [ "rimless" ];
          variant = "mocha";
        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Catppuccin-Mocha-Dark-Cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 24;
      };
      font = {
        name = "Inter";
        size = 10;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-cursor-theme-size = 24;
      };
      gtk4 = {
        theme = config.gtk.theme;
        extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };
    };

    home = {
      sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.local/share/applications"
      ];
    };

    xdg = {
      mimeApps.enable = true;
      systemDirs = {
        data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
        config = [ "/etc/xdg" ];
      };
    };

    # Enable generic Linux target for non-NixOS
    targets.genericLinux.enable = mkIf (!isNixOS) true;
  };
}
