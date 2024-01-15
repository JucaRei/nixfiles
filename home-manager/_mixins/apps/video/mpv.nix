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
        uosc
        acompressor
        webtorrent-mpv-hook
        inhibit-gnome
        autodeint
        # thumbfast
        sponsorblock
      ]
      # Custom scripts
      ++ (with pkgs;[
        # anime4k
        # dynamic-crop
        # modernx
        # nextfile
        # subselect
        # subsearch
        # thumbfast
      ]);
    };
in
{
  programs = {
    mpv = {
      enable = true;
      package = (nixGL mpvgl);
    };
  };

  home =
    let
      kvFormat = pkgs.formats.keyValue { };
      font = "FiraCode Nerd Font";
    in
    {
      file = {
        ".config/mpv/script-opts/chapterskip.conf" = {
          text = "categories=sponsorblock>SponsorBlock";
        };
        ".config/mpv/script-opts/sub-select.json" = {
          text = builtins.toJSON [
            {
              blacklist = [
                "signs"
                "songs"
                "translation only"
                "forced"
              ];
            }
            {
              alang = "*";
              slang = "eng";
            }
          ];
        };
        ".config/mpv/script-opts/stats.conf" = {
          source = kvFormat.generate "mpv-script-opts-stats" {
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
        ".config/mpv/input.conf" = {
          source = ../../config/mpv/input/input.conf;
        };
        ".config/mpv/mpv.conf" = {
          text = ''
            ### Profile ###

            include="~~/profiles.conf"

            ### Video ###

            vo=gpu-next
            gpu-api=auto
            priority=high
            gpu-context=auto
            hwdec=d3d11va-copy
            profile=high-quality
            d3d11-adapter=NVIDIA

            scale-antiring=0.7
            dscale-antiring=0.7
            cscale-antiring=0.7

            display-fps-override=60
            video-sync=display-resample

            deband=no
            deband-iterations=1
            deband-threshold=48
            deband-range=16
            deband-grain=32

            temporal-dither=yes

            ## HDR -> SDR ##

            #tone-mapping=bt.2446a
            #tone-mapping-mode=luma
            #target-colorspace-hint=yes

            ### Audio and Subtitles ###

            slang=en,eng,English
            alang=ja,jp,jpn,jap,Japanese,en,eng,English

            sub-blur=0.5
            sub-scale=0.7
            sub-margin-y=60
            sub-color='#d6ffffff'
            sub-shadow-offset=5.0
            sub-font=Clear Sans Bold
            sub-back-color='#00000000'
            sub-border-color='#266a678c'
            sub-shadow-color='#00000000'

            sub-auto=fuzzy
            volume-max=150
            sub-fix-timing=yes
            audio-channels=auto
            blend-subtitles=yes
            sub-ass-override=yes
            audio-file-auto=fuzzy
            audio-pitch-correction=yes
            audio-normalize-downmix=yes
            sub-file-paths-append=subtitles
            demuxer-mkv-subtitle-preroll=yes
            sub-file-paths=sub;subs;subtitles;**
            af-add='dynaudnorm=g=5:f=250:r=0.9:p=0.5'

            ## Audio Filters to Test ##

            #af=loudnorm=I=-10
            #af=loudnorm=I=-20
            #af=speechnorm=e=4:p=0.4
            #af='lavfi=[dynaudnorm=f=200:g=5:r=0.1]'
            #af=lavfi=[loudnorm=I=-16:TP=-2:LRA=11]

            # boost speech volume
            #af=@normalize:speechnorm=e=10:r=0.0005:l=1
            # loudnorm works well too, but uses more CPU
            #af=@normalize:loudnorm=I=-10

            #af-toggle=@loudnorm:lavfi=[loudnorm=I=-16:TP=-3:LRA=4]
            #af-toggle=@dynaudnorm:lavfi=[dynaudnorm=g=5:f=250:r=0.9:p=0.5]

            #af-toggle=@loudnorm:!loudnorm=I=-25:TP=-1.5:LRA=1:linear=false
            #af-toggle=@dynaudnorm:!dynaudnorm=f=500:g=17:r=0.1
            #af-toggle=format:srate=48000

            ### General ###

            fs=yes
            snap-window
            alpha=blend
            keep-open=always
            geometry=50%:50%
            save-position-on-quit=yes
            watch-later-options-remove=pause

            ### OSD/OSC ###

            osc=no
            border=no
            osd-bar=no
            osd-bold=yes
            osd-font-size=24
            osd-font='JetBrains Mono'
          '';
        };
        ".config/mpv/profiles.conf" = {
          text = ''
            ### Profiles ###

            [Deband-Medium]
            deband-iterations=2
            deband-threshold=64
            deband-range=16
            deband-grain=24

            [Deband-Strong]
            deband-iterations=3
            deband-threshold=64
            deband-range=16
            deband-grain=24

            [Upscale-Q]
            glsl-shaders-clr
            glsl-shaders="~~/shaders/F8.glsl;~~/shaders/krigbl.glsl;~~/shaders/ssimsr.glsl;~~/shaders/ssimds.glsl"

            linear-downscaling=no

            [Upscale-M]
            glsl-shaders-clr
            glsl-shaders="~~/shaders/ravu_Z_ar_r3.glsl;~~/shaders/krigbl.glsl;~~/shaders/ssimds.glsl"

            linear-downscaling=no

            [Upscale-P]
            glsl-shaders-clr
            glsl-shaders="~~/shaders/krigbl.glsl;~~/shaders/FSR_EASU.glsl;~~/shaders/ssimds.glsl"

            linear-downscaling=no

            [Enhance-LA]
            glsl-shaders-clr
            glsl-shaders="~~/shaders/krigbl.glsl;~~/shaders/A4K_Dark.glsl;~~/shaders/A4K_Thin.glsl;~~/shaders/adasharpA.glsl"

            [UpscaleLA-Q]
            glsl-shaders-clr
            glsl-shaders="~~/shaders/F8_LA.glsl;~~/shaders/krigbl.glsl;~~/shaders/ssimsr.glsl;~~/shaders/ssimds.glsl"

            linear-downscaling=no

            [UpscaleLA-M]
            glsl-shaders-clr
            glsl-shaders="~~/shaders/A4K_Upscale_L.glsl;~~/shaders/krigbl.glsl;~~/shaders/ssimsr.glsl;~~/shaders/ssimds.glsl"

            linear-downscaling=no

            ### Conditional Profiles ###

            [4k-Downscaling]
            profile-cond=(height >= 2160 or width >= 3840)
            profile-restore=copy-equal
            glsl-shaders-clr
            glsl-shaders="~~/shaders/krigbl.glsl;~~/shaders/ssimds.glsl"

            linear-downscaling=no

            [Downmix-Audio-5.1]
            profile-cond=get("audio-params/channel-count") >= 5 and get("audio-params/channel-count") < 7
            profile-restore=copy-equal
            volume-max=200
            af=lavfi="lowpass=c=LFE:f=120,volume=1.6,pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE"

            [Downmix-Audio-7.1]
            profile-cond=get("audio-params/channel-count") >= 7
            profile-restore=copy-equal
            volume-max=200
            af=lavfi="lowpass=c=LFE:f=120,volume=1.6,pan=stereo|FL=0.5*FC+0.3*FLC+0.3*FL+0.3*BL+0.3*SL+0.5*LFE|FR=0.5*FC+0.3*FRC+0.3*FR+0.3*BR+0.3*SR+0.5*LFE"

            ## General Anime Profile (Applies to any video in a folder called 'Anime') ##

            [Anime]
            profile-cond=require 'mp.utils'.join_path(working_directory, path):match('\\Anime\\')
            profile-restore=copy-equal

            deband=yes
            deband-iterations=2
            deband-threshold=35
            deband-range=20
            deband-grain=5

            sub-scale=0.75

            ## Hides unwanted webtorrent entries in memo script ##

            [Webtorrent-Entries]
            profile-cond=string.match(string.lower(string.gsub(require "mp.utils".join_path(get("working-directory", ""), get("path", "")), string.gsub(get("filename", ""), "([^%w])", "%%%1").."$", "")), "webtorrent")
            profile-restore=copy-equal
            script-opts-append=memo-enabled=no

          '';
        };
        #### Shaders ###
        ".config/mpv/shaders" = {
          source = ../../config/mpv/shaders;
          recursive = true;
        };
      };
    };

  # Xdg entries
  xdg = {
    desktopEntries.mpv = {
      type = "Application";
      name = "mpv";
      genericName = "Video Player";
      # exec = "${pkgs.mpv}/bin/umpv %U";
      exec = "umpv %U";
      categories = [ "Application" ];
      mimeType = [ "video/mp4" ];
    };
    mimeApps = {
      defaultApplications = {
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
