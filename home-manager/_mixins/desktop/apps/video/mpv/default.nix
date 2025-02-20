{ pkgs, lib, modulesPath, inputs, username, config, hostname, ... }:
let
  inherit (lib) mkIf mkForce mkEnableOption;
  inherit (pkgs.stdenv) isLinux;
  cfg = config.desktop.apps.video.mpv;
  anime4k = pkgs.anime4k;

  ### Use's from unstable
  mpv-unstable = pkgs.unstable.mpv-unwrapped.wrapper {
    mpv = pkgs.unstable.mpv-unwrapped.override {
      vapoursynthSupport = true;
      cddaSupport = true; # Support for playing CDs with `mpv cdda:///dev/sr0`
      waylandSupport = true;
      jackaudioSupport = true; # Add jack support to mpv.
      ## webp support
      x11Support = true;
      pipewireSupport = true;
      sdl2Support = true;
      vaapiSupport = true;
      vdpauSupport = true;
      ffmpeg = pkgs.unstable.ffmpeg_7-full;
    };
    youtubeSupport = true;
    extraMakeWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      "${pkgs.unstable.vapoursynth-mvtools}/lib/vapoursynth"
    ];
    scripts = with pkgs.unstable.mpvScripts; [
      # thumbnail
      thumbfast # High-performance on-the-fly thumbnailer.
      mpris
      uosc # Adds a minimalist but highly customisable GUI.
      #modernz # Sleek and modern OSC for mpv designed to enhance functionality by adding more features, all while preserving the core standards of mpv's OSC
      # builtins.autoload # Automatically load playlist entries before and after the currently playing file, by scanning the directory.
      # builtins.acompressor # Script to toggle and control ffmpeg's dynamic range compression filter
      quality-menu # Userscript for MPV that allows you to change youtube video quality (ytdl-format) on the fly
      # webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents. It provides an osd overlay to show info/progress.
      autodeint # Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by key bind.
      sponsorblock
      mpv-cheatsheet # MPV script for looking up keyboard shortcuts
      # (subserv.override { port = 1337; secondary = false; })
      # (subserv.override { port = 1338; secondary = true; })
    ]
      # ++ mkIf (desktop == "gnome") [ inhibit-gnome ]
    ;
  };

  # From version 24.05
  mpv-oldstable = pkgs.unstable.mpv-unwrapped.wrapper {
    mpv = pkgs.oldstable.mpv-unwrapped.override {
      vapoursynthSupport = true;
      cddaSupport = true; # Support for playing CDs with `mpv cdda:///dev/sr0`
      waylandSupport = true;
      jackaudioSupport = true; # Add jack support to mpv.
      # webp support
      x11Support = true;
      pipewireSupport = true;
      sdl2Support = true;
      vaapiSupport = true;
      vdpauSupport = true;
    };
    youtubeSupport = true;
    extraMakeWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      "${pkgs.vapoursynth-mvtools}/lib/vapoursynth"
    ];
    scripts = with pkgs.mpvScripts; [
      # thumbnail
      thumbfast # High-performance on-the-fly thumbnailer.
      mpris
      uosc # Adds a minimalist but highly customisable GUI.
      #modernz # Sleek and modern OSC for mpv designed to enhance functionality by adding more features, all while preserving the core standards of mpv's OSC
      # builtins.autoload # Automatically load playlist entries before and after the currently playing file, by scanning the directory.
      # builtins.acompressor # Script to toggle and control ffmpeg's dynamic range compression filter
      quality-menu # Userscript for MPV that allows you to change youtube video quality (ytdl-format) on the fly
      # webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents. It provides an osd overlay to show info/progress.
      autodeint # Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by key bind.
      sponsorblock
      mpv-cheatsheet # MPV script for looking up keyboard shortcuts
      # (subserv.override { port = 1337; secondary = false; })
      # (subserv.override { port = 1338; secondary = true; })
    ]
      # ++ mkIf (desktop == "gnome") [ inhibit-gnome ]
    ;
  };


in
{
  disabledModules = [
    "${modulesPath}/programs/mpv.nix" # disable module from stable branch
  ];

  imports = [
    (inputs.home-manager_unstable + "/modules/programs/mpv.nix") # imports module from unstable branch
    # (inputs.home-manager_oldstable + "/modules/programs/mpv.nix") # imports module from oldstable branch
  ];



  options = {
    desktop.apps.video.mpv = {
      enable = mkEnableOption "Enable's mpv with some configs.";
    };
  };

  config = mkIf cfg.enable {
    home =
      let
        kvFormat = pkgs.formats.keyValue { };
        font = "FiraCode Nerd Font";
      in
      {
        packages = with pkgs; [
          # mpv-unstable
          font-dubai
        ];

        file = {
          #   ".config/mpv/script-opts/chapterskip.conf" = {
          #     text = "categories=sponsorblock>SponsorBlock";
          #   };

          #   ".config/mpv/script-opts/sub-select.json" = {
          #     text = builtins.toJSON [
          #       { blacklist = [ "signs" "songs" "translation only" "forced" ]; }
          #       {
          #         alang = "*";
          #         slang = "pt_BR,en,eng,de,deu,ger";
          #       }
          #     ];
          #   };

          #   ".config/mpv/script-opts/console.conf" = {
          #     # text = "font=FiraCode Nerd Font Retina";
          #     text = "font=FiraCode Nerd Font Retina";
          #   };

          #   ".config/mpv/script-opts/stats.conf" = {
          #     source = kvFormat.generate "mpv-script-opts-stats" {
          #       font = font;
          #       font_mono = font;
          #       #BBGGRR
          #       font_color = "C6BD0A";
          #       border_color = "1E0B00";
          #       plot_bg_border_color = "D900EA";
          #       plot_bg_color = "9";
          #       plot_color = "D900EA";
          #     };
          #   };

          #   ".config/mpv/vapoursynth/motion-based-interpolation.vpy" = {
          #     source = ./configs/vapoursynth/motion-based-interpolation.vpy;
          #   };

          #   ## ".config/mpv/input.conf" = builtins.readFile ./configs/input.conf;
          #   ".config/mpv/input.conf" = { source = ./configs/input.conf; };
          #   ".config/mpv/mpv.conf" = { source = ./configs/mpv.conf; };
          #   ".config/mpv/profiles.conf" = { source = ./configs/profiles.conf; };

          #   ".config/mpv/scripts/evfast.lua" = { source = ./configs/scripts/evfast.lua; };
          #   ".config/mpv/scripts/memo.lua" = { source = ./configs/scripts/memo.lua; };
          #   ".config/mpv/scripts/sview.lua" = { source = ./configs/scripts/sview.lua; };

          #   ".config/mpv/script-opts/evfast.conf" = { source = ./configs/scripts-opts/evfast.conf; };
          #   ".config/mpv/script-opts/memo.conf" = { source = ./configs/scripts-opts/memo.conf; };
          #   ".config/mpv/script-opts/thumbfast.conf" = { source = ./configs/scripts-opts/thumbfast.conf; };
          #   ".config/mpv/script-opts/uosc.conf" = { source = ./configs/scripts-opts/uosc.conf; };

          ".logs/mpv/mpv.log" = { source = config.lib.file.mkOutOfStoreSymlink ./configs/mpv.log; };
        };
      };
    programs = {
      mpv = {
        enable = true;
        package = mpv-unstable;
        # package = if (hostname == "rocinante") then mpv-oldstable else mpv-unstable;
        config = {
          volume = 65;
          volume-max = 150;
          # audio-spdif = "ac3,dts,eac3,dts-hd,truehd";
          # audio-channels = "stereo,5.1,7.1";
          audio-channels = "auto";
          subs-with-matching-audio = true; # Won't ignore subtitles tagged as "Forced"
          audio-delay = "+0.084"; #Useful if you're watching with your headphones on PC, but output the video on your Television with a long HDMI cable (counter the delay)
          # af = "acompressor=ratio=4,loudnorm";

          geometry = "50%:50%";

          input-ipc-server = "/tmp/mpvsocket";
          write-filename-in-watch-later-config = true;

          slang = "pt_BR,ptBR,en";
          alang = "ja,jpn,en,eng,enGB,de,pt_BR,ptBR";
          vlang = "ja,jpn,en,eng,enGB,de,pt_BR,ptBR";

          sub-auto = "fuzzy";
          sub-font = "Dubai";
          sub-fix-timing = true;
          sub-use-margins = "no";
          sub-scale-by-window = "yes";
          sub-scale-with-window = "no";
          sub-font-size = 42;
          # sub-color = "#FFFFFFFF";
          sub-color = "#F9F5E3";
          sub-border-color = "#151F30"; #"#E3371E"; #"#7282D9";
          sub-border-size = 2;
          sub-shadow-offset = 2;
          # sub-shadow-color = "#33000000";
          sub-shadow-color = "0.0/0.0/0.0";
          sub-spacing = 0.5;
          blend-subtitles = true;
          sub-gauss = 1.0;
          sub-gray = true;
          sub-ass-use-video-data = "all"; # Backward compatibility for vsfilter fansubs
          sub-ass-override = true;
          # sub-file-paths-append = "subtitles";
          sid = 1;

          fs = true;
          af-add = "dynaudnorm=g=5:f=250:r=0.9:p=0.5";
          log-file = "$HOME/.logs/mpv/mpv.log";

          gpu-context = mkIf (config.features.isWayland.enable) "waylandvk";

          # osd-font = config.fonts.sansSerif.name;
          osd-fractions = true;
          # hwdec = "auto";
          hwdec = "auto-safe";
          # hwdec = "vaapi";
          # vo = "gpu,dmabuf-wayland,wlshm,vdpau,xv,x11,sdl,drm,";
          # because ao=pipewire doesn't work for audio-only files for whatever reason...

          # profile = "gpu-hq";
          # gpu-context = "auto";

          ytdl-format = "(webm,mkv,mp4)[height<=?720]";
          ytdl-raw-options = "ignore-config=,sub-lang=en,write-auto-sub=";

          audio-file-auto = "fuzzy";
          audio-normalize-downmix = true;

          save-position-on-quit = true;
          watch-later-directory = "${config.xdg.stateHome}/mpv/watch_later";
          # cache-dir = "${config.xdg.cacheHome}/mpv";

          resume-playback-check-mtime = true;
          reset-on-next-file = "audio-delay,mute,pause,speed,sub-delay,video-aspect-override,video-pan-x,video-pan-y,video-rotate,video-zoom,volume";
          demuxer-mkv-subtitle-preroll = true;

          framedrop = false;
          cursor-autohide = 1000; # autohide the curser after 1

          dither-depth = "auto";
          temporal-dither = true;
          dither = "fruit";
          window-scale = 0.5;

          ordered-chapters = true;

          wayland-edge-pixels-pointer = mkIf (config.features.isWayland.enable) 0;
          wayland-edge-pixels-touch = mkIf (config.features.isWayland.enable) 0;

          osc = false;
          border = true;
          osd-bar = false;
          osd-bold = true;
          osd-font-size = 24;
          osd-font = "FiraCode Nerd Font Mono Retina";

          screenshot-format = "webp";
          screenshot-webp-lossless = true;
          screenshot-directory = "${config.home.homeDirectory}/Pictures/screenshots/mpv";
          screenshot-sw = true;

          input-default-bindings = false;
        };

        profiles = {
          "protocol.http" = {
            force-window = "immediate";
            hls-bitrate = "max"; # use max quality for HLS streams
            cache = true;
          };
          "protocol.https".profile = "protocol.http";

          # "extension.gif" = {
          #   cache = false;
          #   loop-file = true;
          # };

          # "extension.png" = {
          #   profile = "extension.gif";
          #   video-aspect-override = 0;
          # };

          # "extension.jpeg".profile = "extension.png";
          # "extension.jpg".profile = "extension.png";

          eye-cancer = {
            sharpen = 5;
            osd-font = "Comic Sans MS";
          };

          debian = {
            profile-cond = "os.getenv('HOSTNAME') == 'anubis'";
            brightness = 70;
            vo = mkForce "auto-safe"; # next-gpu
          };

          nitro = {
            profile-cond = "os.getenv('HOSTNAME') == 'nitro'";
            hwdec = "vaapi";
            vo = "gpu-next,gpu,vdpau,dmabuf-wayland,wlshm,xv,x11,sdl,drm,";
            audio-device = "pipewire";
            ao = "pulse,alsa,jack,pipewire,";
            pulse-latency-hacks = true;
            gpu-context = "auto";
            correct-pts = false;
            container-fps-override = 60;
          };

        };

        bindings = rec {
          # UOSC
          "<" = "script-binding uosc/prev";
          ">" = "script-binding uosc/next";
          m = "script-binding uosc/menu";
          o = "script-binding uosc/open-file";
          P = "script-binding uosc/items";

          # https://github.com/-player/mpv/blob/master/etc/input.conf
          R = "cycle_values window-scale 2 0.5 1"; # switch between 2x, 1/2, unresized window size
          r = "cycle_values video-rotate 90 180 270 0"; # Rotate video

          I = ''cycle-values vf "sub,lavfi=negate" ""''; # invert colors

          MBTN_LEFT_DBL = "cycle fullscreen";
          MBTN_RIGHT = "cycle pause";
          MBTN_BACK = "playlist-prev";
          MBTN_FORWARD = "playlist-next";
          WHEEL_DOWN = "seek -5";
          WHEEL_UP = "seek 5";
          WHEEL_LEFT = "seek -60";
          WHEEL_RIGHT = "seek 60";

          h = "no-osd seek -5 exact";
          LEFT = h;
          l = "no-osd seek 5 exact";
          RIGHT = l;
          j = "seek -30";
          DOWN = j;
          k = "seek 30";
          UP = k;

          H = "no-osd seek -1 exact";
          "Shift+LEFT" = "no-osd seek -1 exact";
          L = "no-osd seek 1 exact";
          "Shift+RIGHT" = "no-osd seek 1 exact";
          J = "seek -300";
          "Shift+DOWN" = "seek -300";
          K = "seek 300";
          "Shift+UP" = "seek 300";

          "Ctrl+LEFT" = "no-osd sub-seek -1";
          "Ctrl+h" = "no-osd sub-seek -1";
          "Ctrl+RIGHT" = "no-osd sub-seek 1";
          "Ctrl+l" = "no-osd sub-seek 1";
          "Ctrl+DOWN" = "add chapter -1";
          "Ctrl+j" = "add chapter -1";
          "Ctrl+UP" = "add chapter 1";
          "Ctrl+k" = "add chapter 1";

          "Alt+LEFT" = "frame-back-step";
          "Alt+h" = "frame-back-step";
          "Alt+RIGHT" = "frame-step";
          "Alt+l" = "frame-step";

          PGUP = "add chapter 1";
          PGDWN = "add chapter -1";

          u = "revert-seek";

          # Font Size
          KP7 = "add sub-scale -0.05";
          KP8 = "set sub-scale 1.0";
          KP9 = "add sub-scale +0.05";
          "Ctrl++" = "add sub-scale 0.5";
          "Ctrl+-" = "add sub-scale -0.5";
          "Shift+=" = "set sub-scale 0";
          # "CTRL++" = "add sub-font-size 1";
          # "CTRL+-" = "add sub-font-size -1";

          # Font cycle
          "Ctrl+s" =
            let
              fontA = "Dubai";
              fontB = "Fira Sans Condensed Italic";
            in
            # "cycle-values sub-font ' ${fontA} ' ' ${fontB} ' ' fontC ' [...]";
            "cycle-values sub-font ' ${fontA} ' ' ${fontB} '";

          q = "quit";
          Q = "quit-watch-later";
          "q {encode}" = "quit 4";
          p = "cycle pause";
          SPACE = p;
          f = "cycle fullscreen";

          n = "playlist-next";
          N = "playlist-prev";

          # o = "show-progress";
          O = "script-binding stats/display-stats-toggle";
          "`" = "script-binding console/enable";
          ":" = "script-binding console/enable";

          z = "add sub-delay -0.1";
          x = "add sub-delay 0.1";
          Z = "add audio-delay -0.1";
          X = "add audio-delay 0.1";

          "1" = "add volume -1";
          "2" = "add volume 1";
          "3" = "add contrast -1";
          "4" = "add contrast 1";
          "5" = "add brightness -1";
          "6" = "add brightness 1";
          "7" = "add saturation -1";
          "8" = "add saturation 1";
          "9" = "add gamma -1";
          "0" = "add gamma 1";
          s = "cycle sub";
          v = "cycle video";
          a = "cycle audio";
          S = ''cycle-values sub-ass-override "force" "no"'';
          PRINT = "screenshot";
          c = "add panscan 0.1";
          C = "add panscan -0.1";
          PLAY = "cycle pause";
          PAUSE = "cycle pause";
          PLAYPAUSE = "cycle pause";
          PLAYONLY = "set pause no";
          PAUSEONLY = "set pause yes";
          STOP = "stop";
          CLOSE_WIN = "quit";
          "CLOSE_WIN {encode}" = "quit 4";
          "Ctrl+w" = ''set hwdec "no"'';
          "[" = "multiply speed 1/1.1";
          "]" = "multiply speed 1.1";
          # T = "script-binding generate-thumbnails";

        } // (if hostname == "nitro" then {

          ### High
          #   # curl -sL https://github.com/bloc97/Anime4K/raw/master/md/Template/GLSL_Mac_Linux_High-end/input.conf | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e "s| |\" = ''|" -e "s|$|'';|"
          "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
          "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
          "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
          "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
          "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
          "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';
          "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
        } else {
          ### Low
          #   # curl -sL https://github.com/bloc97/Anime4K/raw/master/md/Template/GLSL_Mac_Linux_Low-end/input.conf | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e "s| |\" = ''|" -e "s|$|'';|"
          "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"'';
          "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"'';
          "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"'';
          "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"'';
          "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"'';
          "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"'';
          "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
        });

        scriptOpts = {
          # console.font = config.fonts.monospace.name;
          osc = {
            seekbarstyle = "knob"; # "diamond";
            seekbarkeyframes = false;
            seekrangestyle = "slider";
            vidscale = false;
            deadzonesize = 0.75;
            inmousemove = 4;
            valign = 0.9;
            timems = true;
            scalewindowed = 0.8;
            hidetimeout = 300;
            layout = "slimbox";
          };
          uosc = {
            opacity = "curtain=0,timeline=0.3";
            timeline_size = 30;
          };
          thumbfast = {
            hwdec = true;
            network = true;
            spawn_first = true;
            max_height = 250;
            max_width = 250;
          };
        };
      };
    };

    systemd.user.tmpfiles.rules = mkIf isLinux [
      "d ${config.home.homeDirectory}/.logs 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/.logs/mpv 0755 ${username} users - -"
    ];
  };
}
