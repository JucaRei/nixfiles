{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./packages.nix
  ];

  config = lib.mkIf config.desktop.hyprland.enable {
    desktop.display-servers.backend = "wayland";

    # Programas padrão do ambiente
    system.programs = {
      file-manager.thunar.enable = lib.mkDefault (
        !config.system.programs.file-manager.nautilus.enable
        && !config.system.programs.file-manager.nemo.enable
        && !config.system.programs.file-manager.pcmanfm.enable
      );
    };

    # Tema e Aparência GTK (Catppuccin Mocha + Papirus Dark)
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
        name = "catppuccin-mocha-dark-cursors";
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
      sessionVariables = {
        GTK_THEME = config.gtk.theme.name;
        XCURSOR_THEME = config.gtk.cursorTheme.name;
        XCURSOR_SIZE = toString config.gtk.cursorTheme.size;
        HYPRCURSOR_THEME = config.gtk.cursorTheme.name;
        HYPRCURSOR_SIZE = toString config.gtk.cursorTheme.size;
      };
      file = {
        ".themes/${config.gtk.theme.name}".source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";
        ".themes/Catppuccin-Mocha-Standard-Blue-Dark".source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";
        ".local/share/themes/${config.gtk.theme.name}".source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";
        ".local/share/themes/Catppuccin-Mocha-Standard-Blue-Dark".source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";

        ".icons/${config.gtk.cursorTheme.name}".source =
          "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
        ".icons/Catppuccin-Mocha-Dark-Cursors".source =
          "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
        ".icons/default/index.theme".text = ''
          [Icon Theme]
          Name=Default
          Comment=Default Cursor Theme
          Inherits=${config.gtk.cursorTheme.name}
        '';
        ".local/share/icons/${config.gtk.cursorTheme.name}".source =
          "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
        ".local/share/icons/Catppuccin-Mocha-Dark-Cursors".source =
          "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
      };
    };
  };
}
