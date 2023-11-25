# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/nm-applet/eap/982792b0-1607-4dfc-b2ca-6723cf4fa378" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
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

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 184;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 79 22 ];
      window-size = mkTuple [ 1205 721 ];
    };

    "org/nemo/window-state" = {
      sidebar-bookmark-breakpoint = 0;
      start-with-sidebar = true;
    };

  };
}
