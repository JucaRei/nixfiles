{
  config,
  lib,
  pkgs,
  ...
}:
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

  config = lib.mkIf config.desktop.bspwm.enable {
    desktop.display-servers.backend = "x11";

    # --- Programas Padrão do BSPWM ---
    system.programs = {
      file-manager.thunar.enable = lib.mkDefault (
        !config.system.programs.file-manager.nautilus.enable
        && !config.system.programs.file-manager.nemo.enable
        && !config.system.programs.file-manager.pcmanfm.enable
      );
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

    xresources.properties = {
      "Xcursor.theme" = config.gtk.cursorTheme.name;
      "Xcursor.size" = config.gtk.cursorTheme.size;
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
      "org/blueman/general" = {
        notification-daemon = true;
      };
    };

    services.stalonetray = {
      enable = true;
      config = {
        background = "#2b2f37";
        decorations = "none";
        dockapp_mode = "none";
        geometry = "5x1-16+44";
        max_geometry = "8x1-16+44";
        grow_gravity = "NW";
        icon_gravity = "NE";
        icon_size = 20;
        slot_size = 24;
        sticky = true;
        skip_taskbar = true;
        window_type = "dock";
        window_layer = "top";
        kludges = "force_icons_size";
      };
    };

    # Recarregar automaticamente o Stalonetray ao rodar switch-home se habilitado
    home.activation.reloadStalonetray = lib.mkIf config.services.stalonetray.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD systemctl --user restart stalonetray 2>/dev/null || (${pkgs.procps}/bin/pkill -x stalonetray 2>/dev/null && ${pkgs.stalonetray}/bin/stalonetray 2>/dev/null || true) &
      ''
    );

    home = {
      sessionVariables = {
        GTK_THEME = config.gtk.theme.name;
        XCURSOR_THEME = config.gtk.cursorTheme.name;
        XCURSOR_SIZE = toString config.gtk.cursorTheme.size;
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
