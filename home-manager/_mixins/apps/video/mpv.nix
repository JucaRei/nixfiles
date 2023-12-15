{ pkgs, lib, config, ... }:
with lib.hm.gvariant;
let
  nixGL = import ../../../../lib/nixGL.nix { inherit config pkgs; };

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
        thumbfast
        sponsorblock
      ]
      # Custom scripts
      ++ (with pkgs;[
        anime4k
        dynamic-crop
        modernx
        nextfile
        subselect
        subsearch
        thumbfast
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
      config = {
        alang = "jp,jpn,ja,Japanese,japanese,en,eng,pt_BR";
        profile = "gpu-hq";
        video-sync = "display-resample";
        vo = "gpu";
        hwdec = "auto";
        screenshot-directory = "~/Pictures/mpv-screenshots/";
        screenshot-format = "png";
        watch-later-directory = "${config.xdg.cacheHome}/mpv-watch-later/";
        cache-dir = "${config.xdg.cacheHome}/mpv";
        ytdl-format = "bestvideo[height<=?1080][vcodec!=?vp9]+bestaudio/best";
        save-position-on-quit = true;
        osd-font = "Bitstream Vera Sans";
        # osc = "no";
        # osd-bar = "no";
        force-window = "yes";

        # Video Settings
        geometry = "50%:50%"; # force starting with centered window

        # don't allow a new window to have a size larger than 80% of the screen size
        autofit-larger = "80%x80%";

        # Do not close the window on exit.
        keep-open = "yes";

        ### Audio ###
        volume = 60;
        volume-max = 200;
        audio-file-auto = "fuzzy"; #Load external audio with (almost) the same name as the video
        audio-exclusive = "yes";
        audio-channels = "stereo,5.1,7.1";
        subs-with-matching-audio = "no"; #Won't ignore subtitles tagged as "Forced"
        audio-spdif = "ac3,dts,eac3,dts-hd,truehd";
        af = "acompressor=ratio=4,loudnorm";
        audio-delay = "+0.084"; #Useful if you're watching with your headphones on PC, but output the video on your Television with a long HDMI cable (counter the delay)

        ### SUBs ###
        slang = "pt_BR,en,eng,de,deu,ger";
        demuxer-mkv-subtitle-preroll = "yes"; #Forces showing subtitles while seeking through the video
        blend-subtitles = "yes";
        sub-gauss = "1.0";
        sub-gray = "yes";
        sub-ass-vsfilter-blur-compat = "yes"; # Backward compatibility for vsfilter fansubs
        sub-ass-scale-with-window = "no"; # May have undesired effects with signs being misplaced.
        sub-auto = "fuzzy"; # external subs don't have to match the file name exactly to autoload
        embeddedfonts = "yes"; # use embedded fonts for SSA/ASS subs
        sub-fix-timing = "no"; # do not try to fix gaps (which might make it worse in some cases). Enable if there are scenebleeds.

        script-opts = "chapterskip-skip=opening;ending;sponsorblock";
      };

      bindings = {
        # Basics
        "BS" = "cycle pause";
        "SPACE" = "cycle pause";
        "\\" = "set speed 1.0";
        # "PGUP" = "add chapter -1";
        # "PGDWN" = "add chapter 1";
        "Alt+ENTER" = "cycle fullscreen";
        "Alt+x" = "quit-watch-later";
        "1" = "cycle border";
        "Ctrl+a" = "cycle ontop";
        n = ''show-text ''${media-title}'';
        MBTN_LEFT = "cycle pause";
        MBTN_LEFT_DBL = "cycle fullscreen";
        MBTN_RIGHT = "ignore";

        # Video
        v = "cycle sub-visibility";
        "Ctrl+LEFT" = "sub-seek -1";
        "Ctrl+RIGHT" = "sub-seek 1";
        PGUP = "playlist-next; write-watch-later-config";
        PGDWN = "playlist-prev; write-watch-later-config";
        "Alt+1" = "set window-scale 0.5";
        "Alt+2" = "set window-scale 1.0";
        "Alt+3" = "set window-scale 2.0";
        "Alt+i" = "screenshot";
        s = "ignore";
        "Ctrl+h" = "add chapter -1";
        "Ctrl+j" = "repeatable playlist-prev";
        "Ctrl+k" = "repeatable playlist-next";
        "Ctrl+l" = "add chapter 1";
        "J" = "cycle sub";
        "L" = "ab_loop";
        "shift+LEFT" = "script-binding previousfile";
        "shift+RIGHT" = "script-binding nextfile";

        # Audio
        UP = "add volume +2";
        DOWN = "add volume -2";
        WHEEL_UP = "add volume +2";
        WHEEL_DOWN = "add volume -2";
        "+" = "add audio-delay 0.100";
        "-" = "add audio-delay -0.100";
        a = "cycle audio";
        "Shift+a" = "cycle audio down";
        "Ctrl+M" = "cycle mute";
        "=" = ''af toggle "lavfi=[pan=1c|c0=0.5*c0+0.5*c1]" ; show-text "Audio mix set to Mono"'';

        # Frame-step
        ">" = "frame-step";
        "<" = "frame-back-step";

        "O" = "cycle osc; cycle osd-bar";

        # Seek to timestamp
        "ctrl+t" = ''script-message-to console type "set time-pos "'';
      };
    }

    # anime 4k
    # (lib.optionalAttrs config.anime4k.enable
    (
      let
        shaderList = files: (
          lib.pipe ([ "Clamp_Highlights" ] ++ files) [
            (map (s: "${pkgs.mpv-anime4k}/share/mpv/shaders/Anime4K_" + s + ".glsl"))
            (arr: lib.concatStringsSep ":" arr)
          ]
        );
        setShaders = text: files: ''no-osd change-list glsl-shaders set "${shaderList files}"; show-text "Anime4K: ${text} (HQ)"'';
      in
      {
        config = {
          # Optimized shaders for higher-end GPU: Mode A (HQ)
          # glsl-shaders = ''"~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_VL.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"'';
        };
        bindings = {
          # clear shaders
          "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
          # Optimized shaders for higher-end GPU:
          "CTRL+1" = setShaders "Mode A" [
            "Restore_CNN_VL"
            "Upscale_CNN_x2_VL"
            "AutoDownscalePre_x2"
            "AutoDownscalePre_x4"
            "Upscale_CNN_x2_M"
          ];
          "CTRL+2" = setShaders "Mode B" [
            "Restore_CNN_Soft_VL"
            "Upscale_CNN_x2_VL"
            "AutoDownscalePre_x2"
            "AutoDownscalePre_x4"
            "Upscale_CNN_x2_M"
          ];
          "CTRL+3" = setShaders "Mode C" [
            "Upscale_Denoise_CNN_x2_VL"
            "AutoDownscalePre_x2"
            "AutoDownscalePre_x4"
            "Upscale_CNN_x2_M"
          ];
          "CTRL+4" = setShaders "Mode A+A" [
            "Restore_CNN_VL"
            "Upscale_CNN_x2_VL"
            "Restore_CNN_M"
            "AutoDownscalePre_x2"
            "AutoDownscalePre_x4"
            "Upscale_CNN_x2_M"
          ];
          "CTRL+5" = setShaders "Mode B+B" [
            "Restore_CNN_Soft_VL"
            "Upscale_CNN_x2_VL"
            "AutoDownscalePre_x2"
            "AutoDownscalePre_x4"
            "Restore_CNN_Soft_M"
            "Upscale_CNN_x2_M"
          ];
          "CTRL+6" = setShaders "Mode C+A" [
            "Upscale_Denoise_CNN_x2_VL"
            "AutoDownscalePre_x2"
            "AutoDownscalePre_x4"
            "Restore_CNN_M"
            "Upscale_CNN_x2_M"
          ];
        };
      }
    )
    # )
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
}
