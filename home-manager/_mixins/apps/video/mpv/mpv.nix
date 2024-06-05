{ pkgs, lib, unstable, ... }:
let
  kvFormat = pkgs.formats.keyValue { };
  font = "FiraCode Nerd Font";

  mpv-unstable = pkgs.unstable.wrapMpv
    (pkgs.unstable.mpv-unwrapped.override {
      vapoursynthSupport = true;
      cddaSupport = true; # Support for playing CDs with `mpv cdda:///dev/sr0`
      waylandSupport = true;
      jackaudioSupport = true; # Add jack support to mpv.
      # webp support
      ffmpeg = pkgs.unstable.ffmpeg_5-full;
    })
    {
      extraMakeWrapperArgs = [
        "--prefix"
        "LD_LIBRARY_PATH"
        ":"
        "${pkgs.unstable.vapoursynth-mvtools}/lib/vapoursynth"
      ];
      scripts = with pkgs.unstable.mpvScripts;
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
          sponsorblock
        ];
    };
in
{
  # imports = [ ./mpv-config.nix ];
  programs.mpv = {
    enable = true;
    # package = pkgs.mpv-patched;
    package = mpv-unstable;
    scriptOpts = {
      chapterskip = {
        categories = "sponsorblock>SponsorBlock";
      };
      sub-select = {
        text = builtins.toJSON [
          { blacklist = [ "signs" "songs" "translation only" "forced" ]; }
          {
            alang = "*";
            slang = "pt_BR,en,eng,de,deu,ger";
          }
        ];
      };
      console = {
        font = "JetBrainsMono Nerd Font";
      };
      stats = {
        font = "JetBrainsMono Nerd Font";
        font_mono = "JetBrainsMono Nerd Font Mono";
        font_color = "#C6BD0A";
        border_color = "#1E0B00";
        plot_bg_border_color = "#D900EA";
        plot_bg_color = "#331809";
        plot_color = "#D900EA";
      };
    };
  };

  home = {
    file = {
      ".config/mpv/vapoursynth/motion-based-interpolation.vpy" = { source = ../../../config/mpv/vapoursynth/motion-based-interpolation.vpy; };
      ".config/mpv/input.conf" = {
        text = ''
          ALT+d cycle deband
          MBTN_MID no-osd cycle pause
          tab script-binding uosc/flash-ui
          p script-binding webtorrent/toggle-info
          ctrl+d script-binding autodeint/autodeint
          ALT+b script-binding autosub/download_subs
          MOUSE_BTN2 script-binding uosc/menu-blurred
          ALT+a script-message-to uosc show-submenu-blurred "File"
          ALT+z script-message-to uosc show-submenu-blurred "Audio"
          ALT+x script-message-to uosc show-submenu-blurred "Subtitles"
          ALT+s script-message-to uosc show-submenu-blurred "Video > Shaders"

          ### UOSC Menu Config ###

          h script-binding memo-history                                                               #! File > History
          / script-binding console/enable                                                             #! File > Console
          # script-binding uosc/playlist                                                              #! File > Playlist
          # script-binding uosc/open-config-directory                                                 #! File > Settings
          ALT+c script-binding uosc/chapters                                                          #! File > Chapters
          b script-binding uosc/open-file                                                             #! File > Open File
          # script-binding uosc/show-in-directory                                                     #! File > Open in File Explorer

          # apply-profile Deband-Medium                                                               #! Video > Filters > Deband (Medium)
          # apply-profile Deband-Strong                                                               #! Video > Filters > Deband (Strong)
          n cycle-values glsl-shaders "~~/shaders/nlmeans_HQ.glsl" "~~/shaders/nlmeans_L_HQ.glsl" ""  #! Video > Shaders > Denoise
          # change-list glsl-shaders toggle ~~/shaders/adasharp.glsl                                  #! Video > Shaders > Sharpen > Sharpen
          # change-list glsl-shaders toggle ~~/shaders/NVSharpen.glsl                                 #! Video > Shaders > Sharpen > SharpenNV
          # change-list glsl-shaders toggle ~~/shaders/CAS.glsl                                       #! Video > Shaders > Sharpen > SharpenCAS
          # change-list glsl-shaders toggle ~~/shaders/adasharpA.glsl                                 #! Video > Shaders > Line Art > Sharpen
          # change-list glsl-shaders toggle ~~/shaders/A4K_Thin.glsl                                  #! Video > Shaders > Line Art > Thin Line
          # change-list glsl-shaders toggle ~~/shaders/A4K_Dark.glsl                                  #! Video > Shaders > Line Art > Dark Line
          # change-list glsl-shaders toggle ~~/shaders/F8.glsl                                        #! Video > Shaders > Neural Scaler > FSRCNNX 8
          # change-list glsl-shaders toggle ~~/shaders/ravu_L_ar_r4.hook                              #! Video > Shaders > Neural Scaler > Ravu Lite ar r4
          # change-list glsl-shaders toggle ~~/shaders/ravu_Z_ar_r3.hook ; no-osd set cscale-antiring 0 ; set dscale-antiring 0 ; set cscale-antiring 0 #! Video > Shaders > Neural Scaler > Ravu Zoom ar r3
          # change-list glsl-shaders toggle ~~/shaders/F8_LA.glsl                                     #! Video > Shaders > Neural Scaler > FSRCNNX Line Art
          # change-list glsl-shaders toggle ~~/shaders/A4K_Upscale_L.glsl                             #! Video > Shaders > Neural Scaler > Anime4K Upscale L
          # change-list glsl-shaders toggle ~~/shaders/ssimsr.glsl                                    #! Video > Shaders > Generic Scaler > SSimSuperRes
          # change-list glsl-shaders toggle ~~/shaders/krigbl.glsl                                    #! Video > Shaders > Generic Scaler > KrigBilateral
          # change-list glsl-shaders toggle ~~/shaders/ssimds.glsl ; no-osd set linear-downscaling no #! Video > Shaders > Generic Scaler > SSimDownscaler
          # change-list glsl-shaders toggle ~~/shaders/FSR_EASU.glsl                                  #! Video > Shaders > Generic Scaler > AMD FidelityFX Super Resolution EASU
          ` script-binding sview/shader-view                                                          #! Video > Shaders > Show Loaded Shaders
          Ctrl+1 apply-profile Upscale-M                                                              #! Video > Shaders > Profiles > Upscale Medium
          Ctrl+2 apply-profile Upscale-Q                                                              #! Video > Shaders > Profiles > Upscale Quality
          Ctrl+3 apply-profile Upscale-P                                                              #! Video > Shaders > Profiles > Upscale Performance
          Ctrl+4 apply-profile Enhance-LA                                                             #! Video > Shaders > Profiles > Enhance Line Art
          Ctrl+5 apply-profile UpscaleLA-M                                                            #! Video > Shaders > Profiles > Upscale Line Art Medium
          Ctrl+6 apply-profile UpscaleLA-Q                                                            #! Video > Shaders > Profiles > Upscale Line Art Quality
          c change-list glsl-shaders clr all                                                          #! Video > Shaders > Clear All
          g cycle interpolation                                                                       #! Video > Interpolation
          # script-binding uosc/video                                                                 #! Video > Select Video Track

          F1 af toggle "lavfi=[loudnorm=I=-14:TP=-3:LRA=4]" ; show-text "$\{af}"                       #! Audio > Dialogue
          # af clr ""                                                                                 #! Audio > Clear Filters
          # script-binding afilter/toggle-eqr                                                         #! Audio > Toggle Equalizer
          a cycle audio-normalize-downmix                                                             #! Audio > Toggle Normalize
          # script-binding afilter/toggle-dnm                                                         #! Audio > Toggle Normalizer
          # script-binding afilter/toggle-drc                                                         #! Audio > Toggle Compressor
          # script-binding uosc/audio                                                                 #! Audio > Select Audio Track

          y script-binding uosc/load-subtitles                                                        #! Subtitles > Load
          Y script-binding uosc/subtitles                                                             #! Subtitles > Select
          Alt+l add sub-scale +0.05                                                                   #! Subtitles > Bigger
          Alt+k add sub-scale -0.05                                                                   #! Subtitles > Smaller
          z add sub-delay -0.1                                                                        #! Subtitles > Decrease Sub Delay
          Z add sub-delay  0.1                                                                        #! Subtitles > Increase Sub Delay

          ### Audio
          WHEEL_UP add volume 2
          WHEEL_DOWN add volume -2
          #Ctrl+up add volume +2
          #Ctrl+down add volume -2
          + add audio-delay 0.100
          - add audio-delay -0.100
        '';
      };
    };
  };

  # Xdg entries
  xdg = {
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
        "video/ts" = "mpv.desktop";
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
