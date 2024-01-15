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
        # thumbnail
        thumbfast # High-performance on-the-fly thumbnailer.
        autoload #  Automatically load playlist entries before and after the currently playing file, by scanning the directory.
        mpris
        uosc # Adds a minimalist but highly customisable GUI.
        acompressor
        webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents. It provides an osd overlay to show info/progress.
        inhibit-gnome
        autodeint #  Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by key bind.
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
        ".config/mpv/input.conf" = {
          source = ../../config/mpv/input/input.conf;
        };
        ".config/mpv/mpv.conf" = {
          text = ''
            ### Profile ###

            include="/home/$USER/.config/mpv/profiles.conf"

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
            osd-font-size=32
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
            glsl-shaders="/home/$USER/.config/mpv/shaders/F8.glsl;/home/$USER/.config/mpv/shaders/krigbl.glsl;/home/$USER/.config/mpv/shaders/ssimsr.glsl;/home/$USER/.config/mpv/shaders/ssimds.glsl"

            linear-downscaling=no

            [Upscale-M]
            glsl-shaders-clr
            glsl-shaders="/home/$USER/.config/mpv/shaders/ravu_Z_ar_r3.glsl;/home/$USER/.config/mpv/shaders/krigbl.glsl;/home/$USER/.config/mpv/shaders/ssimds.glsl"

            linear-downscaling=no

            [Upscale-P]
            glsl-shaders-clr
            glsl-shaders="/home/$USER/.config/mpv/shaders/krigbl.glsl;/home/$USER/.config/mpv/shaders/FSR_EASU.glsl;/home/$USER/.config/mpv/shaders/ssimds.glsl"

            linear-downscaling=no

            [Enhance-LA]
            glsl-shaders-clr
            glsl-shaders="/home/$USER/.config/mpv/shaders/krigbl.glsl;/home/$USER/.config/mpv/shaders/A4K_Dark.glsl;/home/$USER/.config/mpv/shaders/A4K_Thin.glsl;/home/$USER/.config/mpv/shaders/adasharpA.glsl"

            [UpscaleLA-Q]
            glsl-shaders-clr
            glsl-shaders="/home/$USER/.config/mpv/shaders/F8_LA.glsl;/home/$USER/.config/mpv/shaders/krigbl.glsl;/home/$USER/.config/mpv/shaders/ssimsr.glsl;/home/$USER/.config/mpv/shaders/ssimds.glsl"

            linear-downscaling=no

            [UpscaleLA-M]
            glsl-shaders-clr
            glsl-shaders="/home/$USER/.config/mpv/shaders/A4K_Upscale_L.glsl;/home/$USER/.config/mpv/shaders/krigbl.glsl;/home/$USER/.config/mpv/shaders/ssimsr.glsl;/home/$USER/.config/mpv/shaders/ssimds.glsl"

            linear-downscaling=no

            ### Conditional Profiles ###

            [4k-Downscaling]
            profile-cond=(height >= 2160 or width >= 3840)
            profile-restore=copy-equal
            glsl-shaders-clr
            glsl-shaders="/home/$USER/.config/mpv/shaders/krigbl.glsl;/home/$USER/.config/mpv/shaders/ssimds.glsl"

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
        #### Scripts ###
        ".config/mpv/scripts/evfast.lua" = {
          # Fast-forwarding and seeking on a single key.
          source = ../../config/mpv/scripts/evfast.lua;
        };
        ".config/mpv/scripts/memo.lua" = {
          # Saves watch history, and displays it in a nice menu, integrated with uosc.
          source = ../../config/mpv/scripts/memo.lua;
        };
        ".config/mpv/scripts/sview.lua" = {
          # Show shaders currently running, triggered on shader activation or by key bind.
          source = ../../config/mpv/scripts/sview.lua;
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
            history_path=/home/$USER/.config/mpv/script-opts/memo-history.log

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
            hwdec=yes

            # Windows only: use native Windows API to write to pipe (requires LuaJIT)
            direct_io=no

            # Custom path to the mpv executable
            mpv_path=mpv
          '';
        };
        ".config/mpv/script-opts/uosc.conf" = {
          text = ''
            # Display style of current position. available: line, bar
            timeline_style=line
            # Line display style config
            timeline_line_width=2
            # Timeline size when fully expanded, in pixels, 0 to disable
            timeline_size=25
            # Comma separated states when element should always be fully visible.
            # Available: paused, audio, image, video, idle, windowed, fullscreen
            timeline_persistency=paused
            # Top border of background color to help visually separate timeline from video
            timeline_border=1
            # When scrolling above timeline, wheel will seek by this amount of seconds
            timeline_step=5
            # Render cache indicators for streaming content
            timeline_cache=yes

            # When to display an always visible progress bar (minimized timeline). Can be: windowed, fullscreen, always, never
            # Can also be toggled on demand with `toggle-progress` command.
            progress=windowed
            progress_size=2
            progress_line_width=20

            # A comma delimited list of controls above the timeline. Set to `never` to disable.
            # Parameter spec: enclosed in `{}` means value, enclosed in `[]` means optional
            # Full item syntax: `[<[!]{disposition1}[,[!]{dispositionN}]>]{element}[:{paramN}][#{badge}[>{limit}]][?{tooltip}]`
            # Common properties:
            #   `{icon}` - parameter used to specify an icon name (example: `face`)
            #            - pick here: https://fonts.google.com/icons?icon.platform=web&icon.set=Material+Icons&icon.style=Rounded
            # `{element}`s and their parameters:
            #   `{shorthand}` - preconfigured shorthands:
            #        `play-pause`, `menu`, `subtitles`, `audio`, `video`, `playlist`,
            #        `chapters`, `editions`, `stream-quality`, `open-file`, `items`,
            #        `next`, `prev`, `first`, `last`, `audio-device`, `fullscreen`,
            #        `loop-playlist`, `loop-file`, `shuffle`
            #   `speed[:{scale}]` - display speed slider, [{scale}] - factor of controls_size, default: 1.3
            #   `command:{icon}:{command}` - button that executes a {command} when pressed
            #   `toggle:{icon}:{prop}[@{owner}]` - button that toggles mpv property
            #   `cycle:{default_icon}:{prop}[@{owner}]:{value1}[={icon1}][!]/{valueN}[={iconN}][!]`
            #       - button that cycles mpv property between values, each optionally having different icon and active flag
            #       - presence of `!` at the end will style the button as active
            #       - `{owner}` is the name of a script that manages this property if any
            #   `gap[:{scale}]` - display an empty gap
            #       {scale} - factor of controls_size, default: 0.3
            #   `space` - fills all available space between previous and next item, useful to align items to the right
            #           - multiple spaces divide the available space among themselves, which can be used for centering
            # Item visibility control:
            #   `<[!]{disposition1}[,[!]{dispositionN}]>` - optional prefix to control element's visibility
            #   - `{disposition}` can be one of:
            #     - `idle` - true if mpv is in idle mode (no file loaded)
            #     - `image` - true if current file is a single image
            #     - `audio` - true for audio only files
            #     - `video` - true for files with a video track
            #     - `has_many_video` - true for files with more than one video track
            #     - `has_image` - true for files with a cover or other image track
            #     - `has_audio` - true for files with an audio track
            #     - `has_many_audio` - true for files with more than one audio track
            #     - `has_sub` - true for files with an subtitle track
            #     - `has_many_sub` - true for files with more than one subtitle track
            #     - `has_many_edition` - true for files with more than one edition
            #     - `has_chapter` - true for files with chapter list
            #     - `stream` - true if current file is read from a stream
            #     - `has_playlist` - true if current playlist has 2 or more items in it
            #   - prefix with `!` to negate the required disposition
            #   Examples:
            #     - `<stream>stream-quality` - show stream quality button only for streams
            #     - `<has_audio,!audio>audio` - show audio tracks button for all files that have
            #                                   an audio track, but are not exclusively audio only files
            # Place `#{badge}[>{limit}]` after the element params to give it a badge. Available badges:
            #   `sub`, `audio`, `video` - track type counters
            #   `{mpv_prop}` - any mpv prop that makes sense to you: https://mpv.io/manual/master/#property-list
            #                - if prop value is an array it'll display its size
            #   `>{limit}` will display the badge only if it's numerical value is above this threshold.
            #   Example: `#audio>1`
            # Place `?{tooltip}` after the element config to give it a tooltip.
            # Example implementations:
            #   menu = command:menu:script-binding uosc/menu-blurred?Menu
            #   subtitles = command:subtitles:script-binding uosc/subtitles#sub?Subtitles
            #   fullscreen = cycle:crop_free:fullscreen:no/yes=fullscreen_exit!?Fullscreen
            #   loop-playlist = cycle:repeat:loop-playlist:no/inf!?Loop playlist
            #   toggle:{icon}:{prop} = cycle:{icon}:{prop}:no/yes!
            controls=menu,gap,subtitles,<has_many_audio>audio,<has_many_video>video,<has_chapter>chapters,<has_many_edition>editions,<stream>stream-quality,gap,space,speed,space,gap,command:history:script-binding memo-history?History,prev,items,next
            controls_size=35
            controls_margin=8
            controls_spacing=2
            controls_persistency=

            # Where to display volume controls: none, left, right
            volume=none
            volume_size=40
            volume_border=1
            volume_step=1
            volume_persistency=

            # Playback speed widget: mouse drag or wheel to change, click to reset
            speed_step=0.05
            speed_step_is_factor=no
            speed_persistency=

            # Controls all menus, such as context menu, subtitle loader/selector, etc
            menu_item_height=35
            menu_min_width=360
            menu_padding=4
            # Determines if `/` or `ctrl+f` is required to activate the search, or if typing
            # any text is sufficient.
            # When enabled, you can no longer toggle a menu off with the same key that opened it, if the key is a unicode character.
            menu_type_to_search=yes

            # Top bar with window controls and media title
            # Can be: never, no-border, always
            top_bar=no-border
            top_bar_size=45
            top_bar_controls=yes
            # Can be: `no` (hide), `yes` (inherit title from mpv.conf), or a custom template string
            top_bar_title=yes
            # Template string to enable alternative top bar title. If alt title matches main title,
            # it'll be hidden. Tip: use `$\{media-title}` for main, and `$\{filename}` for alt title.
            top_bar_alt_title=
            # Can be:
            #   `below`  => display alt title below the main one
            #   `toggle` => toggle the top bar title text between main and alt by clicking
            #               the top bar, or calling `toggle-title` binding
            top_bar_alt_title_place=below
            # Flash top bar when any of these file types is loaded. Available: audio,image,video
            top_bar_flash_on=video,audio
            top_bar_persistency=

            # Window border drawn in no-border mode
            window_border_size=1

            # If there's no playlist and file ends, load next file in the directory
            # Requires `keep-open=yes` in `mpv.conf`.
            autoload=no
            # What types to accept as next item when autoloading or requesting to play next file
            # Can be: video, audio, image, subtitle
            autoload_types=video,audio,image
            # Enable uosc's playlist/directory shuffle mode
            # This simply makes the next selected playlist or directory item be random, just
            # like any other player in the world. It also has an easily togglable control button.
            shuffle=no

            # Scale the interface by this factor
            scale=1
            # Scale in fullscreen
            scale_fullscreen=1
            # Adjust the text scaling to fit your font
            font_scale=1.18
            # Border of text and icons when drawn directly on top of video
            text_border=1.2
            # Border radius of buttons, menus, and all other rectangles
            border_radius=2
            # A comma delimited list of color overrides in RGB HEX format. Defaults:
            # foreground=ffffff,foreground_text=000000,background=000000,background_text=ffffff,curtain=111111,success=a5e075,error=ff616e
            color=
            # A comma delimited list of opacity overrides for various UI element backgrounds and shapes.
            # This does not affect any text, which is always rendered fully opaque. Defaults:
            # timeline=0.9,position=1,chapters=0.8,slider=0.9,slider_gauge=1,controls=0,speed=0.6,menu=1,submenu=0.4,border=1,title=1,tooltip=1,thumbnail=1,curtain=0.8,idle_indicator=0.8,audio_indicator=0.5,buffering_indicator=0.3,playlist_position=0.8
            opacity=timeline=0.8,speed=0,menu=0.84,title=0,tooltip=0.8,curtain=0.13
            # Use a faster estimation method instead of accurate measurement
            # setting this to `no` might have a noticeable impact on performance, especially in large menus.
            text_width_estimation=yes
            # Duration of animations in milliseconds
            animation_duration=100
            # Execute command for background clicks shorter than this number of milliseconds, 0 to disable
            # Execution always waits for `input-doubleclick-time` to filter out double-clicks
            click_threshold=0
            click_command=cycle pause; script-binding uosc/flash-pause-indicator
            # Flash duration in milliseconds used by `flash-{element}` commands
            flash_duration=1000
            # Distances in pixels below which elements are fully faded in/out
            proximity_in=40
            proximity_out=120
            # Use only bold font weight throughout the whole UI
            font_bold=yes
            # One of `total`, `playtime-remaining` (scaled by the current speed), `time-remaining` (remaining length of file)
            destination_time=total
            # Display sub second fraction in timestamps up to this precision
            time_precision=0
            # Display stream's buffered time in timeline if it's lower than this amount of seconds, 0 to disable
            buffered_time_threshold=60
            # Hide UI when mpv autohides the cursor. Timing is controlled by `cursor-autohide` in `mpv.conf` (in milliseconds).
            autohide=no
            # Can be: flash, static, manual (controlled by flash-pause-indicator and decide-pause-indicator commands)
            pause_indicator=flash
            # Sizes to list in stream quality menu
            stream_quality_options=4320,2160,1440,1080,720,480,360,240,144
            # Types to identify media files
            video_types=3g2,3gp,asf,avi,f4v,flv,h264,h265,m2ts,m4v,mkv,mov,mp4,mp4v,mpeg,mpg,ogm,ogv,rm,rmvb,ts,vob,webm,wmv,y4m
            audio_types=aac,ac3,aiff,ape,au,cue,dsf,dts,flac,m4a,mid,midi,mka,mp3,mp4a,oga,ogg,opus,spx,tak,tta,wav,weba,wma,wv
            image_types=apng,avif,bmp,gif,j2k,jp2,jfif,jpeg,jpg,jxl,mj2,png,svg,tga,tif,tiff,webp
            subtitle_types=aqt,ass,gsub,idx,jss,lrc,mks,pgs,pjs,psb,rt,sbv,slt,smi,sub,sup,srt,ssa,ssf,ttxt,txt,usf,vt,vtt
            # Default open-file menu directory
            default_directory=~/
            # List hidden files when reading directories. Due to environment limitations, this currently only hides
            # files starting with a dot. Doesn't hide hidden files on windows (we have no way to tell they're hidden).
            show_hidden_files=no
            # Move files to trash (recycle bin) when deleting files. Dependencies:
            # - Linux: `sudo apt install trash-cli`
            # - MacOS: `brew install trash`
            use_trash=no
            # Adjusted osd margins based on the visibility of UI elements
            adjust_osd_margins=yes

            # Adds chapter range indicators to some common chapter types.
            # Additionally to displaying the start of the chapter as a diamond icon on top of the timeline,
            # the portion of the timeline of that chapter range is also colored based on the config below.
            #
            # The syntax is a comma-delimited list of `{type}:{color}` pairs, where:
            # `{type}` => range type. Currently supported ones are:
            #   - `openings`, `endings` => anime openings/endings
            #   - `intros`, `outros` => video intros/outros
            #   - `ads` => segments created by sponsor-block software like https://github.com/po5/mpv_sponsorblock
            # `{color}` => an RGB(A) HEX color code (`rrggbb`, or `rrggbbaa`)
            #
            # To exclude marking any of the range types, simply remove them from the list.
            chapter_ranges=openings:30abf964,endings:30abf964,ads:c54e4e80
            # Add alternative lua patterns to identify beginnings of simple chapter ranges (except for `ads`)
            # Syntax: `{type}:{pattern}[,{patternN}][;{type}:{pattern}[,{patternN}]]`
            chapter_range_patterns=openings:オープニング;endings:エンディング

            # Localization language priority from highest to lowest.
            # Built in languages can be found in `uosc/intl`.
            # `slang` is a keyword to inherit values from `--slang` mpv config.
            # Supports paths to custom json files: `languages=/home/$USER/.config/mpv/custom.json,slang,en`
            languages=slang,en

            # A comma separated list of element IDs to disable. Available IDs:
            #   window_border, top_bar, timeline, controls, volume,
            #   idle_indicator, audio_indicator, buffering_indicator, pause_indicator
            disable_elements=
          '';
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
