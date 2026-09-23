{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.multimedia.rhythmbox;
in
{
  options.system.programs.multimedia.rhythmbox = {
    enable = mkEnableOption "Rhythmbox music player";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.rhythmbox ];

    dconf.settings = {
      "org/gnome/rhythmbox/plugins" = {
        active-plugins = [
          "rb"
          "power-manager"
          "mpris"
          "iradio"
          "generic-player"
          "audiocd"
          "android"
        ];
      };

      "org/gnome/rhythmbox/podcast" = {
        download-interval = "manual";
      };

      "org/gnome/rhythmbox/rhythmdb" = {
        locations = [ "file://${config.xdg.userDirs.music}" ];
        monitor-library = true;
      };

      "org/gnome/rhythmbox/sources" = {
        browser-views = "genres-artists-albums";
        visible-columns = [
          "rating"
          "post-time"
          "duration"
          "track-number"
          "album"
          "genre"
          "beats-per-minute"
          "play-count"
          "artist"
        ];
      };

      "org/gnome/rhythmbox/interface" = {
        show-sidebar = true;
        show-toolbar = true;
        show-tree-view = true;
        show-tab-bar = true;
        show-lyrics-view = true;
      };
    };
  };

}
