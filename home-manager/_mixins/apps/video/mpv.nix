{ pkgs, lib, config, ... }:
with lib.hm.gvariant;
{
  # home.packages = with pkgs; [ mpv ];

  programs.mpv = {
    enable = true;
    package = pkgs.mpv;
    scripts = with pkgs.mpvScripts; [
      autoload
      mpris
    ];
    config = {
      alang = "jp,jpn,ja,Japanese,japanese,en,eng,pt_BR";
      profile = "gpu-hq";
      video-sync = "display-resample";
      vo = "gpu";
      hwdec = "auto";
      screenshot-directory = "~/Pictures/mpv-screenshots/";
      screenshot-format = "png";
      watch-later-directory = "${config.xdg.cacheHome}/mpv-watch-later/";
      ytdl-format = "bestvideo[height<=?1080][vcodec!=?vp9]+bestaudio/best";
      save-position-on-quit = true;
      osd-font = "Bitstream Vera Sans";

      # Video Settings
      geometry = "50%:50%"; # force starting with centered window

      # don't allow a new window to have a size larger than 80% of the screen size
      autofit-larger = "80%x80%";

      # Do not close the window on exit.
      keep-open = "yes";
    };

    # bindings = {
    #   # Basics
    #   SPACE = "cycle pause";
    #   "Alt+ENTER" = "cycle fullscreen";
    #   "Alt+x" = "quit-watch-later";
    #   "1" = "cycle border";
    #   "Ctrl+a" = "cycle ontop";
    #   n = ''show-text ''${media-title}'';
    #   MBTN_LEFT = "cycle pause";
    #   MBTN_LEFT_DBL = "cycle fullscreen";
    #   MBTN_RIGHT = "ignore";

    #   # Video
    #   v = "cycle sub-visibility";
    #   "Ctrl+LEFT" = "sub-seek -1";
    #   "Ctrl+RIGHT" = "sub-seek 1";
    #   PGUP = "playlist-next; write-watch-later-config";
    #   PGDWN = "playlist-prev; write-watch-later-config";
    #   "Alt+1" = "set window-scale 0.5";
    #   "Alt+2" = "set window-scale 1.0";
    #   "Alt+3" = "set window-scale 2.0";
    #   "Alt+i" = "screenshot";
    #   s = "ignore";

    #   # Audio
    #   UP = "add volume +5";
    #   DOWN = "add volume -5";
    #   WHEEL_UP = "add volume +5";
    #   WHEEL_DOWN = "add volume -5";
    #   "+" = "add audio-delay 0.100";
    #   "-" = "add audio-delay -0.100";
    #   a = "cycle audio";
    #   "Shift+a" = "cycle audio down";
    #   "Ctrl+M" = "cycle mute";
    #   "=" = ''af toggle "lavfi=[pan=1c|c0=0.5*c0+0.5*c1]" ; show-text "Audio mix set to Mono"'';

    #   # Frame-step
    #   ">" = "frame-step";
    #   "<" = "frame-back-step";

    #   # Seek to timestamp
    #   "ctrl+t" = ''script-message-to console type "set time-pos "'';
    # };
  };

  xdg.configFile =
    let
      kvFormat = pkgs.formats.keyValue { };
      font = "FiraCode Nerd Font";
    in
    {
      "mpv/mpv.conf".source = ../../config/mpv/mpv.conf;
      "mpv/script-opts/console.conf".source = kvFormat.generate "mpv-script-opts-console" {
        font = font;
      };
      "mpv/script-opts/osc.conf".source = kvFormat.generate "mpv-script-opts-osc" {
        seekbarstyle = "diamond";
      };
      "mpv/script-opts/stats.conf".source = kvFormat.generate "mpv-script-opts-stats" {
        font = font;
        font_mono = font;
        #BBGGRR
        font_color = "C6BD0A";
        border_color = "1E0B00";
        plot_bg_border_color = "D900EA";
        plot_bg_color = "331809";
        plot_color = "D900EA";
      };
    };
  # xdg.desktopEntries.mpv = {
  #   type = "Application";
  #   name = "mpv";
  #   genericName = "Video Player";
  #   exec = "${pkgs.mpv}/bin/mpv %U";
  #   categories = ["Application"];
  #   mimeType = ["video/mp4"];
  # };
}
