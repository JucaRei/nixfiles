{ pkgs
, lib
, config
, username
, ...
}:
with lib.hm.gvariant; let
  nixGL = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
  mpvgl =
    pkgs.wrapMpv
      (pkgs.mpv-unwrapped.override {
        vapoursynthSupport = true;
        # webp support
        ffmpeg = pkgs.ffmpeg_7-full;
      })
      {
        extraMakeWrapperArgs = [
          "--prefix"
          "LD_LIBRARY_PATH"
          ":"
          "${pkgs.vapoursynth-mvtools}/lib/vapoursynth"
        ];
        scripts = with pkgs.mpvScripts;
          [
            # thumbnail
            thumbfast # High-performance on-the-fly thumbnailer.
            autoload # Automatically load playlist entries before and after the currently playing file, by scanning the directory.
            mpris
            uosc # Adds a minimalist but highly customisable GUI.
            acompressor
            webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents. It provides an osd overlay to show info/progress.
            inhibit-gnome
            autodeint # Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by key bind.
            # thumbfast
            sponsorblock
          ];
      };
in
{
  imports = [ ./mpv-config.nix ];
  programs = {
    mpv = {
      enable = true;
      # package = nixGL mpvgl;
      package = nixGL pkgs.unstable.mpv;
    };
  };


  # Xdg entries
  xdg = {
    desktopEntries.mpv = {
      type = "Application";
      name = "mpv";
      genericName = "Multimedia Player";
      exec = "umpv %U";
      icon = "mpv";
      categories = [ "AudioVideo" "Audio" "Video" "Player" "TV" ];
      comment = "Play movies and songs";
      mimeType = [ "video/mp4" ];
    };
    mimeApps = {
      defaultApplications = lib.mkForce {
        "application/mxf" = "mpv.desktop";
        "application/sdp" = "mpv.desktop";
        "application/smil" = "mpv.desktop";
        "application/streamingmedia" = "mpv.desktop";
        "application/vnd.apple.mpegurl" = "mpv.desktop";
        "application/vnd.ms-asf" = "mpv.desktop";
        "application/vnd.rn-realmedia" = "mpv.desktop";
        "application/vnd.rn-realmedia-vbr" = "mpv.desktop";
        "application/x-cue" = "mpv.desktop";
        # "application/x-extension-m4a" = "mpv.desktop";
        "application/x-extension-mp4" = "mpv.desktop";
        "application/x-matroska" = "mpv.desktop";
        "application/x-mpegurl" = "mpv.desktop";
        "application/x-ogm" = "mpv.desktop";
        "application/x-ogm-video" = "mpv.desktop";
        "application/x-shorten" = "mpv.desktop";
        "application/x-smil" = "mpv.desktop";
        "application/x-streamingmedia" = "mpv.desktop";
        "video/3gp" = "mpv.desktop";
        "video/3gpp" = "mpv.desktop";
        "video/3gpp2" = "mpv.desktop";
        "video/avi" = "mpv.desktop";
        "video/divx" = "mpv.desktop";
        "video/dv" = "mpv.desktop";
        "video/fli" = "mpv.desktop";
        "video/flv" = "mpv.desktop";
        "video/mkv" = "mpv.desktop";
        "video/mp2t" = "mpv.desktop";
        "video/mp4" = "mpv.desktop";
        "video/mp4v-es" = "mpv.desktop";
        "video/mpeg" = "mpv.desktop";
        "video/msvideo" = "mpv.desktop";
        "video/ogg" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "video/vnd.divx" = "mpv.desktop";
        "video/vnd.mpegurl" = "mpv.desktop";
        "video/vnd.rn-realvideo" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-avi" = "mpv.desktop";
        "video/x-flc" = "mpv.desktop";
        "video/x-flic" = "mpv.desktop";
        "video/x-flv" = "mpv.desktop";
        "video/x-m4v" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/x-mpeg2" = "mpv.desktop";
        "video/x-mpeg3" = "mpv.desktop";
        "video/x-ms-afs" = "mpv.desktop";
        "video/x-ms-asf" = "mpv.desktop";
        "video/x-ms-wmv" = "mpv.desktop";
        "video/x-ms-wmx" = "mpv.desktop";
        "video/x-ms-wvxvideo" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/x-ogm" = "mpv.desktop";
        "video/x-ogm+ogg" = "mpv.desktop";
        "video/x-theora" = "mpv.desktop";
        "video/x-theora+ogg" = "mpv.desktop";
      };
    };
  };
}
