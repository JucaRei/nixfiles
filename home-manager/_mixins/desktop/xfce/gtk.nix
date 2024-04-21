{ pkgs, config, ... }: {
  gtk = {
    enable = true;

    theme = {
      # name = "Adwaita";
      package = pkgs.deepin.deepin-icon-theme;
    };

    cursorTheme = {
      name = "Breeze_Hacked";
      package = pkgs.unstable.breeze-hacked-cursor-theme;
      size = 24;
    };

    iconTheme = {
      name = "Tela-icon-theme";
      package = pkgs.tela-icon-theme;
    };

    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = "gtk-can-change-accels = 1";
    };

    gtk3 = {
      extraConfig = ''gtk-can-change-accels = 1'';
      extraCss = '''';
    };

    gtk4 = {
      extraConfig = ''gtk-can-change-accels = 1'';
      extraCss = '''';
    };
  };

  home = {
    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.unstable.breeze-hacked-cursor-theme;
      name = "Breeze_Hacked";
      size = 24;
    };
  };

  # services = {
  #   trayer = {
  #     enable = true;
  #   };
  # };
}

# gtk = {
#   enable = true;
#   iconTheme = {
#     name = "Qogir-manjaro-dark";
#     package = pkgs.qogir-icon-theme;
#   };
#   theme = {
#     name = "zukitre-dark";
#     package = pkgs.zuki-themes;
#   };
#   gtk3.extraConfig = {
#     Settings = ''
#       gtk-application-prefer-dark-theme=1
#     '';
#   };
#   gtk4.extraConfig = {
#     Settings = ''
#       gtk-application-prefer-dark-theme=1
#     '';
#   };
# };
