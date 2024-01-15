{ pkgs, lib, config, ... }:
with lib.hm.gvariant;
let
  nixGL = import ../../../../lib/nixGL.nix { inherit config pkgs; };

  config = import ../../config/mpv/mpv-config1.nix {inherit config;};

  mpvgl = pkgs.wrapMpv
    (pkgs.mpv-unwrapped.override {
      # webp support
      ffmpeg = pkgs.ffmpeg_5-full;
    })
    {
      scripts = with pkgs.mpvScripts; [
        thumbnail
        mpris
        acompressor
        # thumbfast
        sponsorblock
      ]
      # Custom scripts
      ++ (with pkgs;[
        # anime4k
        # dynamic-crop
        # modernx
        # nextfile
        ## subselect
        # subsearch
        # thumbfast
      ]);
    };

in
{
  # home.packages = with pkgs; [ mpv ];

  programs.mpv = lib.mkMerge [
    {
      enable = true;
      # package = pkgs.mpv;
      # package = pkgs.wrapMpv
      #   (pkgs.mpv-unwrapped.override {
      #     # webp support
      #     ffmpeg = pkgs.ffmpeg_5-full;
      #   })
      #   {
      #     scripts = with pkgs.mpvScripts; [
      #       thumbnail
      #       mpris
      #       acompressor
      #       thumbfast
      #       sponsorblock
      #     ];
      #   };
      package = (nixGL mpvgl);
      config = config;
    }
  ];

  xdg = {
    configFile =
      let
        kvFormat = pkgs.formats.keyValue { };
        font = "FiraCode Nerd Font";
      in
      {
        "mpv/script-opts/chapterskip.conf".text = "categories=sponsorblock>SponsorBlock";
        "mpv/script-opts/sub-select.json".text = builtins.toJSON [
          {
            blacklist = [ "signs" "songs" "translation only" "forced" ];
          }
          {
            alang = "*";
            slang = "eng";
          }
        ];
        "mpv/mpv.conf".source = ../../config/mpv/mpv.conf;
        "mpv/script-opts/console.conf".source = kvFormat.generate "mpv-script-opts-console" {
          font = font;
        };
        # "mpv/script-opts/osc.conf".source = kvFormat.generate "mpv-script-opts-osc" {
        #   seekbarstyle = "diamond";
        # };
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
    desktopEntries.mpv = {
      type = "Application";
      name = "mpv";
      genericName = "Video Player";
      exec = "${pkgs.mpv}/bin/mpv %U";
      categories = [ "Application" ];
      mimeType = [ "video/mp4" ];
    };
  };
  xdg.mimeApps.defaultApplications = {
    "application/mxf" = "mpv.desktop";
    "application/sdp" = "mpv.desktop";
    "application/smil" = "mpv.desktop";
    "application/streamingmedia" = "mpv.desktop";
    "application/vnd.apple.mpegurl" = "mpv.desktop";
    "application/vnd.ms-asf" = "mpv.desktop";
    "application/vnd.rn-realmedia" = "mpv.desktop";
    "application/vnd.rn-realmedia-vbr" = "mpv.desktop";
    "application/x-cue" = "mpv.desktop";
    "application/x-extension-m4a" = "mpv.desktop";
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
}
