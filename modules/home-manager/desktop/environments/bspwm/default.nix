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
      colorScheme = "dark";
      theme = {
        name = "catppuccin-mocha-blue-standard+rimless";
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

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = config.gtk.theme.name;
        icon-theme = config.gtk.iconTheme.name;
        cursor-theme = config.gtk.cursorTheme.name;
        cursor-size = config.gtk.cursorTheme.size;
        font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
      };
    };

    home = {
      sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.local/share/applications"
      ];
      sessionVariables = {
        GTK_THEME = config.gtk.theme.name;
      };
      file = {
        ".themes/${config.gtk.theme.name}".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";
        ".themes/Catppuccin-Mocha-Standard-Blue-Dark".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";
        ".local/share/themes/${config.gtk.theme.name}".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";
        ".local/share/themes/Catppuccin-Mocha-Standard-Blue-Dark".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";
      };
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
