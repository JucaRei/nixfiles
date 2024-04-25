{ pkgs, config, lib, ... }: {
  gtk = {
    enable = true;
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = "gtk-theme-name=Fluent-Dark\n gtk-icon-theme-name=Papirus-Dark\n gtk-font-name=Fira Sans";
    };
    # gtk3 = {
    #   "gtk-theme-name" = "Fluent-Dark";
    #   "gtk-icon-theme-name" = "Papirus-Dark";
    #   "gtk-cursor-theme-name" = "volantes_cursors";
    #   "gtk-fallback-icon-theme" = "gnome";
    #   # "gtk-application-prefer-dark-theme" = "true";
    #   "gtk-xft-hinting" = 1;
    #   "gtk-xft-hintstyle" = "hintfull";
    #   "gtk-xft-rgba" = "none";
    # };
    # gtk4 = {
    #   gtk-theme-name = "Fluent-Dark";
    #   gtk-icon-theme-name = "Papirus-Dark";
    #   gtk-cursor-theme-name = "volantes_cursors";
    # };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Fluent-Dark";
      package = pkgs.fluent;
    };
    cursorTheme = {
      name = "volantes_cursors";
      package = pkgs.volantes-cursors;
      size = 24;
    };
    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };
  };

  # qt = {
  # enable = true;
  # platformTheme = lib.mkForce "gtk";
  # style = "gtk2";
  # };

  xdg = {
    configFile = {
      "Fluent-Dark-kvantum" = {
        recursive = true;
        target = "Kvantum/Fluent-Dark";
        source = ../../../config/kvantum/Fluent-Dark;
      };
      "kvantum.kvconfig" = {
        text = ''
          [General]
          theme=Fluent-Dark
        '';
        target = "Kvantum/kvantum.kvconfig";
      };
    };
  };
}
