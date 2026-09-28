{
  config,
  lib,
  pkgs,
  ...
}:
let
  gtkThemeName = "catppuccin-mocha-blue-standard+rimless";
  gtkThemePkg = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard";
    tweaks = [ "rimless" ];
    variant = "mocha";
  };
  iconThemeName = "Papirus-Dark";
  iconThemePkg = pkgs.papirus-icon-theme;
  cursorThemeName = "catppuccin-mocha-dark-cursors";
  cursorThemePkg = pkgs.catppuccin-cursors.mochaDark;
  cursorThemeSize = 24;
in
{
  imports = [
    ./dwm.nix
    ./picom.nix
    ./dunst.nix
    ./rofi.nix
    ./packages.nix
  ];

  config = lib.mkIf config.desktop.dwm.enable {
    desktop.display-servers.backend = "x11";

    # Programas Padrão integrados
    system.programs = {
      terminal = {
        enable = lib.mkDefault true;
        name = lib.mkDefault "alacritty";
      };
      file-manager = {
        default = lib.mkDefault "thunar";
        thunar.enable = lib.mkDefault (
          !config.system.programs.file-manager.nautilus.enable
          && !config.system.programs.file-manager.nemo.enable
          && !config.system.programs.file-manager.pcmanfm.enable
        );
      };
      tools.flameshot.enable = true;
    };

    # Desativar geração de symlinks read-only do settings.ini pelo Home Manager
    # para permitir que o motor de temas do dwm-titus (theme-apply.sh e QML) edite os arquivos
    gtk.enable = lib.mkForce false;

    home.packages = [
      gtkThemePkg
      iconThemePkg
      cursorThemePkg
    ];

    xresources.properties = {
      "Xcursor.theme" = cursorThemeName;
      "Xcursor.size" = cursorThemeSize;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = gtkThemeName;
        icon-theme = iconThemeName;
        cursor-theme = cursorThemeName;
        cursor-size = cursorThemeSize;
        font-name = "Inter 10";
      };
    };

    home = {
      sessionVariables = {
        GTK_THEME = gtkThemeName;
        XCURSOR_THEME = cursorThemeName;
        XCURSOR_SIZE = toString cursorThemeSize;
      };
      file = {
        ".themes/${gtkThemeName}".source =
          "${gtkThemePkg}/share/themes/${gtkThemeName}";
        ".local/share/themes/${gtkThemeName}".source =
          "${gtkThemePkg}/share/themes/${gtkThemeName}";
        ".icons/${cursorThemeName}".source =
          "${cursorThemePkg}/share/icons/${cursorThemeName}";
        ".local/share/icons/${cursorThemeName}".source =
          "${cursorThemePkg}/share/icons/${cursorThemeName}";
      };
    };
  };
}
