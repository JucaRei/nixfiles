{ config, hostname, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.audio.rhythmbox;
in
{
  options.desktop.apps.audio.rhythmbox = {
    enable = mkEnableOption "Enables rhythmbox.";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ rhythmbox ];
    };

    dconf.settings = with lib.hm.gvariant; {
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
        locations = [ "file://${config.home.homeDirectory}/Media/Music" ];
        monitor-library = true;
      };

      "org/gnome/rhythmbox/sources" = {
        browser-views = "genres-artists-albums";
        visible-columns = [
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
    };
  };
}
