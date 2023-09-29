{ pkgs, ... }:

{
  programs.mpv = {
    # https://github.com/mpv-player/mpv/blob/9cddd73f67f11dba2f2921124e2c39c77af01651/etc/input.conf
    bindings = {
      MBTN_LEFT_DBL = "cycle fullscreen"; # toggle fullscreen
      MBTN_RIGHT = "cycle pause"; # toggle pause/playback mode

      RIGHT = "seek 5"; # seek 5 seconds forward
      LEFT = "seek -5"; # seek 5 seconds backward
      UP = "seek 60"; # seek 1 minute forward
      DOWN = "seek -60"; # seek 1 minute backward

      "Shift+RIGHT" = "no-osd seek 1 exact"; # seek exactly 1 second forward
      "Shift+LEFT" = "no-osd seek -1 exact"; # seek exactly 1 second backward

      "Ctrl+RIGHT" = "add chapter 1"; # seek to the next chapter
      "Ctrl+LEFT" = "add chapter -1"; # seek to the previous chapter

      "Ctrl+Shift+RIGHT" = "playlist-next"; # skip to the next file
      "Ctrl+Shift+LEFT" = "playlist-prev"; # skip to the previous file

      "[" = "multiply speed 1/1.1"; # decrease the playback speed
      "]" = "multiply speed 1.1"; # increase the playback speed

      q = "quit";
      Q = "quit-watch-later"; # exit and remember the playback position

      ESC = "set fullscreen no"; # leave fullscreen

      SPACE = "cycle pause"; # toggle pause/playback mode

      i = "script-binding stats/display-stats-toggle"; # toggle displaying information and statistics

      "`" = "script-binding console/enable"; # open the console

      z = "add sub-delay 0.1"; # shift subtitles 100 ms earlier
      Z = "add sub-delay -0.1"; # delay subtitles by 100 ms

      "9" = "add volume -5";
      "0" = "add volume 5";

      m = "cycle mute"; # toggle mute

      v = "cycle sub-visibility"; # hide or show the subtitles

      h = "cycle audio"; # switch audio track
      H = "cycle audio down"; # switch audio track backwards

      j = "cycle sub"; # switch subtitle track
      J = "cycle sub down"; # switch subtitle track backwards

      f = "cycle fullscreen"; # toggle fullscreen

      l = ''cycle-values loop-file "inf" "no"''; # toggle infinite looping

      POWER = "quit";
      PLAY = "cycle pause"; # toggle pause/playback mode
      PAUSE = "cycle pause"; # toggle pause/playback mode
      PLAYPAUSE = "cycle pause"; # toggle pause/playback mode
      PLAYONLY = "set pause no"; # unpause
      PAUSEONLY = "set pause yes"; # pause
      STOP = "quit";
      FORWARD = "seek 60"; # seek 1 minute forward
      REWIND = "seek -60"; # seek 1 minute backward
      NEXT = "playlist-next"; # skip to the next file
      PREV = "playlist-prev"; # skip to the previous file
      VOLUME_UP = "add volume 5";
      VOLUME_DOWN = "add volume -5";
      MUTE = "cycle mute"; # toggle mute
      CLOSE_WIN = "quit";

      "Ctrl+h" = "cycle-values hwdec vaapi-copy no"; # toggle hardware decoding

      F8 = "show-text \${playlist}"; # show the playlist
      F9 = "show-text \${track-list}"; # show the list of video, audio and sub tracks
    };
    config = {
      cscale = "ewa_lanczos";
      dscale = "ewa_lanczos";
      demuxer-max-bytes = "1GiB";
      drm-vrr-enabled = "auto";
      fullscreen = "";
      gpu-api = "vulkan";
      # HDR is not implemented on Wayland.
      hdr-compute-peak = "no";
      hdr-contrast-recovery = "0.0";
      hwdec = "vaapi-copy";
      keep-open = "yes";
      no-input-default-bindings = "";
      profile = "gpu-hq";
      scale = "ewa_lanczos";
      scale-blur = "0.981251";
      script-opts = ''ytdl_hook-exclude="%.mkv$|%.mp4$",ytdl_hook-try_ytdl_first=yes'';
      slang = "en-orig,zh-CN,zh-TW,zh-HK,zh-SG,zh-Hans,zh-Hant,chi,zho,zh";
      sub-auto = "fuzzy";
      subs-fallback = "default";
      subs-with-matching-audio = "yes";
      vo = "gpu-next";
      ytdl-raw-options = "yes-playlist=";
    };
    enable = true;
    scripts = with pkgs.mpvScripts; [
      autoload
      mpris
    ];
  };
}
