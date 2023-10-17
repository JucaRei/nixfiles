{ config, pkgs, lib, ... }:
with lib.hm.gvariant;
{
  services = {
    blueman-applet.enable = true;
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/com/github/marhkb/Pods/";
      saved-view = "/com/";
      show-warning = false;
      window-height = 500;
      window-is-maximized = false;
      window-width = 540;
    };

    "com/github/marhkb/Pods" = {
      is-maximized = false;
      last-used-connection = "7cfcef4c-6a83-4f66-b924-879e2eadd2a8";
      last-used-view = "images";
      window-height = 531;
      window-width = 755;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "zukitre-dark";
      icon-theme = "elementary-Xfce-dark";
    };

    "org/gnome/font-manager" = {
      compare-background-color = "rgb(255,255,255)";
      compare-foreground-color = "rgb(0,0,0)";
      compare-list = [ ];
      google-fonts-background-color = "rgb(255,255,255)";
      google-fonts-foreground-color = "rgb(0,0,0)";
      is-maximized = false;
      language-filter-list = [ ];
      selected-category = "0";
      selected-font = "7";
      window-position = mkTuple [ 910 159 ];
      window-size = mkTuple [ 900 600 ];
    };

    "org/gnome/rhythmbox/plugins" = {
      active-plugins = [ "rb" "power-manager" "mpris" "iradio" "generic-player" "audiocd" "android" ];
    };

    "org/gnome/rhythmbox/podcast" = {
      download-interval = "manual";
    };

    "org/gnome/rhythmbox/rhythmdb" = {
      locations = [ "file:///home/juca/Music" ];
      monitor-library = true;
    };

    "org/gnome/rhythmbox/sources" = {
      browser-views = "genres-artists-albums";
      visible-columns = [ "post-time" "duration" "track-number" "album" "genre" "beats-per-minute" "play-count" "artist" ];
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.2070000022649765 0.5170000195503235 ]) ];
      selected-color = mkTuple [ true 0.18039216101169586 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 159;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "descending";
      type-format = "category";
      window-position = mkTuple [ 404 98 ];
      window-size = mkTuple [ 1102 826 ];
    };

  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "elementary-Xfce-dark";
      package = pkgs.elementary-xfce-icon-theme;
    };
    theme = {
      name = "zukitre-dark";
      package = pkgs.zuki-themes;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home = {
    packages = with pkgs; [
      plank
    ];
  };
}
