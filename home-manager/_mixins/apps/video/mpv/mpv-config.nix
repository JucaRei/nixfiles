{ pkgs, username, ... }:

# nlmeans - Highly configurable and featureful denoiser.
# NVIDIA Image Sharpening - An adaptive-directional sharpening algorithm shaders.
# FidelityFX CAS - Sharpening shader that provides an even level of sharpness across the frame.
# FSRCNNX-TensorFlow - Very resource intensive upscaler that uses a neural network to upscale accurately.
# Anime4k - Shaders designed to scale and enhance anime. Includes shaders for line sharpening and upscaling.
# AMD FidelityFX Super Resolution EASU (FSR without RCAS) - A spatial upscaler which provides consistent upscaling quality regardless of whether the frame is in movement.
# mpv-prescalers - RAVU (Rapid and Accurate Video Upscaling) is a set of prescalers with an overall performance consumption design slightly higher than the built-in ewa scaler, while providing much better results.
# SSimDownscaler, SSimSuperRes, KrigBilateral, Adaptive Sharpen
# Adaptive Sharpen: Another sharpening shader.
# SSimDownscaler: Perceptually based downscaler.
# KrigBilateral: Chroma scaler that uses luma information for high quality upscaling.
# SSimSuperRes: Make corrections to the image upscaled by mpv built-in scaler (removes ringing artifacts and restores original sharpness).
{
  home =
    let
      kvFormat = pkgs.formats.keyValue { };
      font = "FiraCode Nerd Font";
    in
    {

      file = {
        # ".config/mpv/motioninterpolation.py".source = pkgs.substituteAll {
        #   src = ./motioninterpolation.py;
        #   mvtoolslib = "${pkgs.vapoursynth-mvtools}/lib/vapoursynth/";
        # };
        ".config/mpv/script-opts/chapterskip.conf" = {
          text = "categories=sponsorblock>SponsorBlock";
        };
        ".config/mpv/script-opts/sub-select.json" = {
          text = builtins.toJSON [
            { blacklist = [ "signs" "songs" "translation only" "forced" ]; }
            {
              alang = "*";
              slang = "pt_BR,en,eng,de,deu,ger";
            }
          ];
        };
        ".config/mpv/script-opts/console.conf" = {
          text = "font=JetBrains Mono";
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
        ".config/mpv/vapoursynth/motion-based-interpolation.vpy" = {
          source = ../../../config/mpv/vapoursynth/motion-based-interpolation.vpy;
        };
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
            Ctrl+up add volume +2
            Ctrl+down add volume -2
            + add audio-delay 0.100
            - add audio-delay -0.100
          '';
        };
        ".config/mpv/mpv.conf" = {
          source = ../../../config/mpv/mpv.conf;
        };
        ".config/mpv/profiles.conf" = {
          source = ../../../config/mpv/profiles.conf;
        };
        #### Shaders ###
        ".config/mpv/shaders" = {
          source = ../../../config/mpv/shaders;
          recursive = true;
        };
        #### Scripts ###
        ".config/mpv/scripts/evfast.lua" = {
          # Fast-forwarding and seeking on a single key.
          source = ../../../config/mpv/scripts/evfast.lua;
        };
        ".config/mpv/scripts/memo.lua" = {
          # Saves watch history, and displays it in a nice menu, integrated with uosc.
          source = ../../../config/mpv/scripts/memo.lua;
        };
        ".config/mpv/scripts/sview.lua" = {
          # Show shaders currently running, triggered on shader activation or by key bind.
          source = ../../../config/mpv/scripts/sview.lua;
        };
        ".config/mpv/script-opts/evfast.conf" = {
          text = ''
            # How far to jump on press
            seek_distance=5

            # Playback speed modifier, applied once every speed_interval until cap is reached
            speed_increase=0.1
            speed_decrease=0.1

            # At what interval to apply speed modifiers
            speed_interval=0.05

            # Playback speed cap
            speed_cap=2

            # Playback speed cap when subtitles are displayed, 'no' for same as speed_cap
            subs_speed_cap=1.8

            # Multiply current speed by modifier before adjustment (exponential speedup)
            # Use much lower values than default e.g. speed_increase=0.05, speed_decrease=0.025
            multiply_modifier=no

            # Show current speed on the osd (or flash speed if using uosc)
            show_speed=yes

            # Show current speed on the osd when toggled (or flash speed if using uosc)
            show_speed_toggled=yes

            # Show seek actions on the osd (or flash timeline if using uosc)
            show_seek=yes

            # Look ahead for smoother transition when subs_speed_cap is set
            lookahead=no
          '';
        };
        ".config/mpv/script-opts/memo.conf" = {
          text = ''
            # File path gets expanded, leave empty for in-memory history
            history_path=/home/${username}/.config/mpv/script-opts/memo-history.log

            # How many entries to display in menu
            entries=10

            # Display navigation to older/newer entries
            pagination=yes

            # Display files only once
            hide_duplicates=yes

            # Check if files still exist
            hide_deleted=yes

            # Display only the latest file from each directory
            hide_same_dir=no

            # Date format https://www.lua.org/pil/22.1.html
            timestamp_format=

            # Display titles instead of filenames when available
            use_titles=yes

            # Truncate titles to n characters, 0 to disable
            truncate_titles=60

            # Meant for use in auto profiles
            enabled=yes

            # Keybinds for vanilla menu
            up_binding=UP WHEEL_UP
            down_binding=DOWN WHEEL_DOWN
            select_binding=RIGHT ENTER
            append_binding=Shift+RIGHT Shift+ENTER
            close_binding=LEFT ESC

            # Path prefixes for the recent directory menu
            # This can be used to restrict the parent directory relative to which the
            # directories are shown.
            # Syntax
            #   Prefixes are separated by | and can use Lua patterns by prefixing
            #   them with "pattern:", otherwise they will be treated as plain text.
            #   Pattern syntax can be found here https://www.lua.org/manual/5.1/manual.html#5.4.1
            # Example
            #   "path_prefixes=My-Movies|pattern:TV Shows/.-/|Anime" will show directories
            #   that are direct subdirectories of directories named "My-Movies" as well as
            #   "Anime", while for TV Shows the shown directories are one level below that.
            #   Opening the file "/data/TV Shows/Comedy/Curb Your Enthusiasm/S4/E06.mkv" will
            #   lead to "Curb Your Enthusiasm" to be shown in the directory menu. Opening
            #   of that entry will then open that file again.
            path_prefixes=pattern:.*
          '';
        };
        ".config/mpv/script-opts/thumbfast.conf" = {
          text = ''
            # Socket path (leave empty for auto)
            socket=

            # Thumbnail path (leave empty for auto)
            thumbnail=

            # Maximum thumbnail size in pixels (scaled down to fit)
            # Values are scaled when hidpi is enabled
            max_height=200
            max_width=200

            # Apply tone-mapping, no to disable
            tone_mapping=auto

            # Overlay id
            overlay_id=42

            # Spawn thumbnailer on file load for faster initial thumbnails
            spawn_first=yes

            # Close thumbnailer process after an inactivity period in seconds, 0 to disable
            quit_after_inactivity=0

            # Enable on network playback
            network=yes

            # Enable on audio playback
            audio=no

            # Enable hardware decoding
            hwdec=auto

            # Windows only: use native Windows API to write to pipe (requires LuaJIT)
            direct_io=no

            # Custom path to the mpv executable
            mpv_path=mpv
          '';
        };
        ".config/mpv/script-opts/uosc.conf" = {
          source = ../../../config/mpv/script-opts/uosc.conf;
        };
        ".config/mpv/script-opts/webtorrent.conf" = {
          text = ''
            # Path to save downloaded files in. Can be set to "memory" to store all files in RAM.
            path=~/
            # Maximum number of connections.
            maxConns=100
            # Port to use for webtorrent web-server.
            # If it's already in use a random port will be chosen instead.
            port=8888
            # Enable μTP support.
            utp=yes
            # Enable DHT.
            dht=yes
            # Enable local service discovery.
            lsd=yes
            # Download speed limit in bytes/sec.
            #downloadLimit=
            # Upload speed limit in bytes/sec.
            #uploadLimit=
            # Specify the node command to use.
            # Usefull if the command is called nodejs on your system.
            node_path=node

            # The same text style options as in stats.conf is also available.
          '';
        };
      };
    };
}
#  bindings = {
#         # Basics
#         "BS" = "cycle pause";
#         "SPACE" = "cycle pause";
#         "\\" = "set speed 1.0";
#         # "PGUP" = "add chapter -1";
#         # "PGDWN" = "add chapter 1";
#         "Alt+ENTER" = "cycle fullscreen";
#         "Alt+x" = "quit-watch-later";
#         "1" = "cycle border";
#         "Ctrl+a" = "cycle ontop";
#         n = ''show-text ''${media-title}'';
#         MBTN_LEFT = "cycle pause";
#         MBTN_LEFT_DBL = "cycle fullscreen";
#         MBTN_RIGHT = "ignore";
#         # Video
#         v = "cycle sub-visibility";
#         "Ctrl+LEFT" = "sub-seek -1";
#         "Ctrl+RIGHT" = "sub-seek 1";
#         PGUP = "playlist-next; write-watch-later-config";
#         PGDWN = "playlist-prev; write-watch-later-config";
#         "Alt+1" = "set window-scale 0.5";
#         "Alt+2" = "set window-scale 1.0";
#         "Alt+3" = "set window-scale 2.0";
#         "Alt+i" = "screenshot";
#         s = "ignore";
#         "Ctrl+h" = "add chapter -1";
#         "Ctrl+j" = "repeatable playlist-prev";
#         "Ctrl+k" = "repeatable playlist-next";
#         "Ctrl+l" = "add chapter 1";
#         "J" = "cycle sub";
#         "L" = "ab_loop";
#         "shift+LEFT" = "script-binding previousfile";
#         "shift+RIGHT" = "script-binding nextfile";
#         # Audio
#         UP = "add volume +2";
#         DOWN = "add volume -2";
#         WHEEL_UP = "add volume +2";
#         WHEEL_DOWN = "add volume -2";
#         "+" = "add audio-delay 0.100";
#         "-" = "add audio-delay -0.100";
#         a = "cycle audio";
#         "Shift+a" = "cycle audio down";
#         "Ctrl+M" = "cycle mute";
#         "=" = ''af toggle "lavfi=[pan=1c|c0=0.5*c0+0.5*c1]" ; show-text "Audio mix set to Mono"'';
#         # Frame-step
#         ">" = "frame-step";
#         "<" = "frame-back-step";
#         "O" = "cycle osc; cycle osd-bar";
#         # Seek to timestamp
#         "ctrl+t" = ''script-message-to console type "set time-pos "'';
#       };
