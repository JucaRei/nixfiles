{ pkgs, config, lib, ... }:
with lib;
{
  gtk = {
    enable = true;

    theme = mkForce {
      name = "spacx-gtk-theme palenight";
      package = pkgs.spacx-gtk-theme;
    };

    cursorTheme = mkForce {
      name = "Breeze_Hacked";
      package = pkgs.unstable.breeze-hacked-cursor-theme;
      size = 24;
    };

    iconTheme = mkForce {
      name = "Papirus Nord";
      package = pkgs.papirus-nord;
    };

    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = "gtk-can-change-accels = 1";
    };

    gtk3 = {
      extraConfig = {
        gtk-cursor-blink = false;
        gtk-recent-files-limit = 20;
      };
      # extraCss = '''';
    };

    gtk4 = {
      extraConfig = {
        gtk-cursor-blink = false;
        gtk-recent-files-limit = 20;
      };
      # extraCss = '''';
    };
  };

  home = {
    pointerCursor = mkForce {
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
