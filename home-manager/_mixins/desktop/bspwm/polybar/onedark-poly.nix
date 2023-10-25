_: {
  services = {
    polybar = {
      enable = true;
      settings = {
        # Colors.ini
        "color" = {
          BACKGROUND = "#1E2128";
          FOREGROUND = "#ABB2BF";
          ALTBACKGROUND = "#292d37";
          ALTFOREGROUND = "#5a6477";
          ACCENT = "#5294E2";

          BLACK = "#32363D";
          RED = "#E06B74";
          GREEN = "#98C379";
          YELLOW = "#E5C07A";
          BLUE = "#62AEEF";
          MAGENTA = "#C778DD";
          CYAN = "#55B6C2";
          WHITE = "#ABB2BF";
          ALTBLACK = "#50545B";
          ALTRED = "#EA757E";
          ALTGREEN = "#A2CD83";
          ALTYELLOW = "#EFCA84";
          ALTBLUE = "#6CB8F9";
          ALTMAGENTA = "#D282E7";
          ALTCYAN = "#5FC0CC";
          ALTWHITE = "#B5BCC9";
        };
        ## decor.ini
        "decor" = {
          "module/sep" = {
            type = "custom/text";
            content = "-";
            content-background = "\${color.BACKGROUND}";
            content-foreground = "\${color.BACKGROUND}";
          };
          "module/dot" = {
            type = "custom/text";
            content = "";
            content-foreground = "\${color.ALTBACKGROUND}";
            content-padding = 1;
            content-font = 4;
          };
          "module/dot-alt" = {
            "inherit" = "module/dot";
            content-foreground = "\${color.ALTFOREGROUND}";
          };
          #;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          "module/LD" = {
            type = "custom/text";
            content = "%{T3}%{T-}";
            content-background = "\${color.BACKGROUND}";
            content-foreground = "\${color.ALTBACKGROUND}";
          };
          "module/RD" = {
            type = "custom/text";
            content = "%{T3}%{T-}";
            content-background = "\${color.BACKGROUND}";
            content-foreground = "\${color.ALTBACKGROUND}";
          };
        };
        ## Global settings config.ini
        "config" = {
          "global/wm" = {
            margin-bottom = 0;
            margin-top = 0;
          };
          "bar/main" = {
            # ; Use either of the following command to list available outputs:
            # ; If unspecified, the application will pick the first one it finds.
            # ; $ polybar -m | cut -d ':' -f 1
            # ; $ xrandr -q | grep " connected" | cut -d ' ' -f1
            monitor = "$\{env:MONITOR}";

            # ; Use the specified monitor as a fallback if the main one is not found.
            monitor-fallback = "";

            # ; Require the monitor to be in connected state
            # ; XRandR sometimes reports my monitor as being disconnected (when in use)
            monitor-strict = false;

            # ; Tell the Window Manager not to configure the window.
            # ; Use this to detach the bar if your WM is locking its size/position.
            override-redirect = false;

            # ; Put the bar at the bottom of the screen
            bottom = false;

            # ; Prefer fixed center position for the `modules-center` block
            # ; When false, the center position will be based on the size of the other blocks.
            fixed-center = true;

            # ; Dimension defined as pixel value (e.g. 35) or percentage (e.g. 50%),
            # ; the percentage can optionally be extended with a pixel offset like so:
            # ; 50%:-10, this will result in a width or height of 50% minus 10 pixels
            width = "100%";
            height = 26;

            # ; Offset defined as pixel value (e.g. 35) or percentage (e.g. 50%)
            # ; the percentage can optionally be extended with a pixel offset like so:
            # ; 50%:-10, this will result in an offset in the x or y direction
            # ; of 50% minus 10 pixels
            offset-x = "0%";
            offset-y = "0%";

            # ; Background ARGB color (e.g. #f00, #ff992a, #ddff1023)
            background = "\${color.BACKGROUND}";

            # ; Foreground ARGB color (e.g. #f00, #ff992a, #ddff1023)
            foreground = "\${color.FOREGROUND}";

            # ; Background gradient (vertical steps)
            # ;   background-[0-9]+ = #aarrggbb
            # background-0 =

            # ; Value used for drawing rounded corners
            # ; Note: This shouldn't be used together with border-size because the border
            # ; doesn't get rounded
            # ; Individual top/bottom values can be defined using:
            # ;   radius-{top,bottom}
            radius-top = 0.0;
            radius-bottom = 0.0;

            # ; Under-/overline pixel size and argb color
            # ; Individual values can be defined using:
            # ;   {overline,underline}-size
            # ;   {overline,underline}-color
            line-size = 2;
            line-color = "\${color.ACCENT}";

            # ; Values applied to all borders
            # ; Individual side values can be defined using:
            # ;   border-{left,top,right,bottom}-size
            # ;   border-{left,top,right,bottom}-color
            # ; The top and bottom borders are added to the bar height, so the effective
            # ; window height is:
            # ;   height + border-top-size + border-bottom-size
            # ; Meanwhile the effective window width is defined entirely by the width key and
            # ; the border is placed withing this area. So you effectively only have the
            # ; following horizontal space on the bar:
            # ;   width - border-right-size - border-left-size
            border-size = 6;
            border-color = "\${color.BACKGROUND}";

            # ; Number of spaces to add at the beginning/end of the bar
            # ; Individual side values can be defined using:
            # ;   padding-{left,right}
            padding = 0;

            # ; Number of spaces to add before/after each module
            # ; Individual side values can be defined using:
            # ;   module-margin-{left,right}
            module-margin-left = 0;
            module-margin-right = 0;

            # ; Fonts are defined using <font-name>;<vertical-offset>
            # ; Font names are specified using a fontconfig pattern.
            # ;   font-0 = "JetBrains Mono:size=10;3"
            # ;   font-1 = MaterialIcons:size=10
            # ;   font-2 = Termsynu:size=8;-1
            # ;   font-3 = FontAwesome:size=10
            # ; See the Fonts wiki page for more details

            # ; text
            font-0 = "JetBrains Mono:size=10;3";
            # ; icons
            font-1 = "Symbols Nerd Font:size=12;3";
            # ; glyphs
            font-2 = "Iosevka Nerd Font:size=15;4";
            # ; dot
            font-3 = "Iosevka Nerd Font:size=10;4";
            # ; clock & mpd
            font-4 = "Iosevka:style=bold:size=10;4";
            # ; Archcraft
            font-5 = "archcraft:size=12;3";

            # ; Modules are added to one of the available blocks
            # ;   modules-left = cpu ram
            # ;   modules-center = xwindow xbrightness
            # ;   modules-right = ipc clock

            # Default
            modules-left = "LD menu RD dot-alt LD mod RD dot LD bspwm RD dot cpu dot used-memory";
            modules-center = "LD date RD dot-alt LD mpd RD sep song";
            modules-right = "volume dot bna dot bluetooth dot ethernet dot LD battery RD dot-alt LD sysmenu RD";

            # Alternate
            # ;modules-left = openbox 2LD cpu 3LD memory 4LD filesystem 5LD
            # ;modules-center = mpd
            # ;modules-right = 2RD volume 3RD brightness 4RD battery 5RD ethernet 6RD date sep

            # ; The separator will be inserted between the output of each module
            # separator =

            # ; This value is used to add extra spacing between elements
            # ; @deprecated: This parameter will be removed in an upcoming version
            spacing = 0;

            # ; Opacity value between 0.0 and 1.0 used on fade in/out
            dim-value = 1.0;

            # ; Value to be used to set the WM_NAME atom
            # ; If the value is empty or undefined, the atom value
            # ; will be created from the following template: polybar-[BAR]_[MONITOR]
            # ; NOTE: The placeholders are not available for custom values
            wm-name = "bspwm";

            # ; Locale used to localize various module data (e.g. date)
            # ; Expects a valid libc locale, for example: sv_SE.UTF-8
            # locale =

            # ; Position of the system tray window
            # ; If empty or undefined, tray support will be disabled
            # ; NOTE: A center aligned tray will cover center aligned modules
            # ;
            # ; Available positions:
            # ;   left
            # ;   center
            # ;   right
            # ;   none
            tray-position = "right";

            # ; If true, the bar will not shift its
            # ; contents when the tray changes
            tray-detached = false;

            # ; Tray icon max size
            tray-maxsize = 16;

            # ; DEPRECATED! Since 3.3.0 the tray always uses pseudo-transparency
            # ; Enable pseudo transparency
            # ; Will automatically be enabled if a fully transparent
            # ; background color is defined using `tray-background`
            # ; tray-transparent = false

            # ; Background color for the tray container
            # ; ARGB color (e.g. #f00, #ff992a, #ddff1023)
            # ; By default the tray container will use the bar
            # ; background color.
            tray-background = "\${color.BACKGROUND}";

            # ; Tray offset defined as pixel value (e.g. 35) or percentage (e.g. 50%)
            tray-offset-x = 0;
            tray-offset-y = 0;

            # ; Pad the sides of each tray icon
            tray-padding = 0;

            # ; Scale factor for tray clients
            tray-scale = 1.0;

            # ; Restack the bar window and put it above the
            # ; selected window manager's root
            # ;
            # ; Fixes the issue where the bar is being drawn
            # ; on top of fullscreen window's
            # ; Currently supported WM's:
            # ;   bspwm
            # ;   i3 (requires: `override-redirect = true`)
            wm-restack = "bspwm";

            # ; Set a DPI values used when rendering text
            # ; This only affects scalable fonts
            # ; dpi =

            # ; Enable support for inter-process messaging
            # ; See the Messaging wiki page for more details.
            enable-ipc = true;

            # ; Fallback click handlers that will be called if
            # ; there's no matching module handler found.
            click-left = "";
            click-middle = "";
            click-right = "";
            scroll-up = "bspc desktop -f prev.local";
            scroll-down = "bspc desktop -f next.local";
            double-click-left = "";
            double-click-middle = "";
            double-click-right = "";

            # ; Requires polybar to be built with xcursor support (xcb-util-cursor)
            # ; Possible values are:
            # ; - default   : The default pointer as before, can also be an empty string (default)
            # ; - pointer   : Typically in the form of a hand
            # ; - ns-resize : Up and down arrows, can be used to indicate scrolling
            cursor-click = "";
            cursor-scroll = "";

            # ;; WM Workspace Specific

            # ; bspwm
            # ;;scroll-up = bspwm-desknext
            # ;;scroll-down = bspwm-deskprev
            # ;;scroll-up = bspc desktop -f prev.local
            # ;;scroll-down = bspc desktop -f next.local

            # ;i3
            # ;;scroll-up = i3wm-wsnext
            # ;;scroll-down = i3wm-wsprev
            # ;;scroll-up = i3-msg workspace next_on_output
            # ;;scroll-down = i3-msg workspace prev_on_output

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

            # ;; Application Settings
          };
          "settings" = {
            # ; The throttle settings lets the eventloop swallow up til X events
            # ; if they happen within Y millisecond after first event was received.
            # ; This is done to prevent flood of update event.
            # ;
            # ; For example if 5 modules emit an update event at the same time, we really
            # ; just care about the last one. But if we wait too long for events to swallow
            # ; the bar would appear sluggish so we continue if timeout
            # ; expires or limit is reached.
            throttle-output = 5;
            throttle-output-for = 10;

            # ; Time in milliseconds that the input handler will wait between processing events
            # ;throttle-input-for = 30

            # ; Reload upon receiving XCB_RANDR_SCREEN_CHANGE_NOTIFY events
            screenchange-reload = false;

            # ; Compositing operators
            # ; @see: https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-operator-t
            compositing-background = "source";
            compositing-foreground = "over";
            compositing-overline = "over";
            compositing-underline = "over";
            compositing-border = "over";

            # ; Define fallback values used by all module formats
            # ;format-foreground =
            # ;format-background =
            # ;format-underline =
            # ;format-overline =
            # ;format-spacing =
            # ;format-padding =
            # ;format-margin =
            # ;format-offset =

            # ; Enables pseudo-transparency for the bar
            # ; If set to true the bar can be transparent without a compositor.
            pseudo-transparency = false;
          };
        };
        # System.ini
        "system" = {
          # ;; System Variables (Edit according to your system)
          # ;;
          # ;; Warning : DO NOT DELETE THIS FILE
          # ;;
          # ;; Run `ls -1 /sys/class/power_supply/` to list list batteries and adapters.
          # ;;
          # ;; Run `ls -1 /sys/class/backlight/` to list available graphics cards.
          # ;;
          # ;; Run `ip link | awk '/state UP/ {print $2}' | tr -d :` to get active network interface.
          # ;;
          # ;; Polybar Variables For Modules :
          # ;; card = ${system.sys_graphics_card}
          # ;; battery = ${system.sys_battery}
          # ;; adapter = ${system.sys_adapter}
          # ;; interface = ${system.sys_network_interface}
          sys_adapter = "ACAD";
          sys_battery = "BAT1";
          sys_graphics_card = "amdgpu_bl0";
          sys_network_interface = "enp1s0";
        };
        # Modules.ini
        "modules" = {
          "module/bpswm" = {
            type = "internal/bspwm";

            pin-workspaces = true;
            inline-mode = false;

            enable-click = true;
            enable-scroll = true;
            reverse-scroll = true;
            fuzzy-match = true;

            # ; ws-icon-[0-9]+ = label;icon
            # ; Note that the label needs to correspond with the bspwm workspace name
            ws-icon-0 = "1;";
            ws-icon-1 = "2;";
            ws-icon-2 = "3;";
            ws-icon-3 = "4;";
            ws-icon-4 = "5;";
            ws-icon-5 = "6;";
            ws-icon-6 = "7;";
            ws-icon-7 = "8;";
            ws-icon-default = "";

            format = "<label-state>";
            format-background = "\${color.ALTBACKGROUND}";
            format-font = 1;

            label-monitor = "%name%";

            # ; If any values for label-dimmed-N are defined, the workspace/mode
            # ; colors will get overridden with those values if the monitor is out of focus
            # ; To only override workspaces in a specific state, use:
            # ;   label-dimmed-focused
            # ;   label-dimmed-occupied
            # ;   label-dimmed-urgent
            # ;   label-dimmed-empty
            # ;label-dimmed-foreground = ${color.FOREGROUND}
            # ;label-dimmed-underline = ${color.YELLOW}
            # ;label-dimmed-focused-background = ${color.BACKGROUND}

            label-focused = "%name%";
            label-focused-foreground = "\${color.GREEN}";
            label-focused-underline = "\${color.GREEN}";
            label-focused-padding = 1;

            label-occupied = "%name%";
            label-occupied-foreground = "\${color.ACCENT}";
            # ;label-occupied-underline = "\${color.ACCENT}";
            label-occupied-padding = 1;

            label-urgent = "%name%";
            label-urgent-foreground = "\${color.RED}";
            label-urgent-underline = "\${color.RED}";
            label-urgent-padding = 1;

            label-empty = "%name%";
            label-empty-foreground = "\${color.FOREGROUND}";
            label-empty-padding = 1;

            # ; Separator in between workspaces
            label-separator = "";
            label-separator-padding = 0;
            label-separator-foreground = "\${color.ALTBACKGROUND}";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

          };
          "module/mod" = {
            type = "internal/bspwm";

            format = "<label-mode>";
            format-background = "\${color.ALTBACKGROUND}";
            format-foreground = "\${color.YELLOW}";
            format-padding = 0;

            label-monocle = "Monocle";
            label-tiled = "Tiled";

            label-floating = ", Float";
            label-pseudotiled = ", Pseudo";
            label-fullscreen = ", Full";

            label-locked = " | Locked";
            label-sticky = " | Sticky";
            label-private = " | Private";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/bna" = {
            type = "custom/text";

            content = " NA";
            content-prefix = "";
            content-prefix-font = 2;
            content-prefix-foreground = "\${color.RED}";
            content-padding = 1;

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/backlight" = {
            type = "internal/xbacklight";

            # ; Use the following command to list available cards:
            # ; $ ls -1 /sys/class/backlight/
            card = "intel_backlight";

            # ; Available tags:
            # ;   <label> (default)
            # ;   <ramp>
            # ;   <bar>
            format = "<ramp> <label>";
            format-background = "\${color.BACKGROUND}";
            format-padding = 1;

            # ; Available tokens:
            # ;   %percentage% (default)
            label = "%percentage%%";

            # ; Only applies if <ramp> is used

            ramp-0 = "";
            ramp-1 = "";
            ramp-2 = "";
            ramp-3 = "";
            ramp-4 = "";
            ramp-5 = "";
            ramp-6 = "";
            ramp-7 = "";
            ramp-8 = "";
            ramp-9 = "";
            ramp-font = 2;
            ramp-foreground = "\${color.CYAN}";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/brightness" = {
            type = "internal/backlight";

            # ; Use the following command to list available cards:
            # ; $ ls -1 /sys/class/backlight/
            card = "\${system.sys_graphics_card}";

            enable-scroll = true;

            # ; Available tags:
            # ;   <label> (default)
            # ;   <ramp>
            # ;   <bar>
            format = "<ramp> <label>";
            format-background = "\${color.BACKGROUND}";
            format-padding = 1;

            # ; Available tokens:
            # ;   %percentage% (default)
            label = "%percentage%%";

            # ; Only applies if <ramp> is used

            ramp-0 = "";
            ramp-1 = "";
            ramp-2 = "";
            ramp-3 = "";
            ramp-4 = "";
            ramp-5 = "";
            ramp-6 = "";
            ramp-7 = "";
            ramp-8 = "";
            ramp-9 = "";
            ramp-font = 2;
            ramp-foreground = "\${color.CYAN}";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/battery" = {
            type = "internal/battery";

            # ;
            # This is useful in case the battery never reports 100% charge
            full-at = 99;

            # ;
            # Use the following command to list batteries and adapters:
            # ; $ ls -1 /sys/class/power_supply/
            battery = "\${system.sys_battery}";
            adapter = "\${system.sys_adapter}";

            # ;
            # If an inotify event haven't been reported in this many
            # ; seconds, manually poll for new values.
            # ;
            # ; Needed as a fallback for systems that don't report events
            # ; on sysfs/procfs.
            # ;
            # ; Disable polling by setting the interval to 0.
            # ;
            # ; Default: 5
            poll-interval = 2;

            # ;
            # see "man date" for details on how to format the time string
            # ; NOTE: if you want to use syntax tags here you need to use %%{...}
            # ; Default: %H:%M:%S
            time-format = "%H:%M";

            # ;
            # Available tags:
            # ;   <label-charging> (default)
            # ;   <bar-capacity>
            # ;   <ramp-capacity>
            # ;   <animation-charging>
            format-charging = "<animation-charging> <label-charging>";
            format-charging-prefix = " ";
            format-charging-prefix-font = 1;
            format-charging-prefix-foreground = "\${color.RED}";
            format-charging-background = "\${color.ALTBACKGROUND}";

            # ; Available tags:
            # ;   <label-discharging> (default)
            # ;   <bar-capacity>
            # ;   <ramp-capacity>
            # ;   <animation-discharging>
            format-discharging = "<ramp-capacity> <label-discharging>";
            format-discharging-background = "\${color.ALTBACKGROUND}";

            # ; Available tags:
            # ;   <label-full> (default)
            # ;   <bar-capacity>
            # ;   <ramp-capacity>
            # ;format-full = <ramp-capacity> <label-full>

            # ; Available tokens:
            # ;   %percentage% (default)
            # ;   %time%
            # ;   %consumption% (shows current charge rate in watts)

            label-charging = "%percentage%%";

            # ; Available tokens:
            # ;   %percentage% (default)
            # ;   %time%
            # ;   %consumption% (shows current discharge rate in watts)
            label-discharging = "%percentage%%";

            # ; Available tokens:
            # ;   %percentage% (default)
            format-full = "<label-full>";
            format-full-prefix = " ";
            format-full-prefix-font = 2;
            format-full-prefix-foreground = "\${color.GREEN}";
            format-full-background = "\${color.ALTBACKGROUND}";
            label-full = "%percentage%%";

            # ; Only applies if <ramp-capacity> is used
            ramp-capacity-0 = "";
            ramp-capacity-1 = "";
            ramp-capacity-2 = "";
            ramp-capacity-3 = "";
            ramp-capacity-4 = "";
            ramp-capacity-foreground = "\${color.YELLOW}";
            ramp-capacity-font = 2;

            # ; Only applies if <animation-charging> is used
            animation-charging-0 = "";
            animation-charging-1 = "";
            animation-charging-2 = "";
            animation-charging-3 = "";
            animation-charging-4 = "";
            animation-charging-foreground = "\${color.GREEN}";
            animation-charging-font = 2;
            animation-charging-framerate = 700;

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/cpu" = {
            type = "internal/cpu";

            # ; Seconds to sleep between updates
            # ; Default: 1
            interval = 0.5;

            # ; Available tags:
            # ;   <label> (default)
            # ;   <bar-load>
            # ;   <ramp-load>
            # ;   <ramp-coreload>
            # ;;format = <label> <ramp-coreload>
            format = "<label>";
            format-prefix = "";
            format-prefix-font = 2;
            format-prefix-foreground = "\${color.YELLOW}";
            format-background = "\${color.BACKGROUND}";
            format-padding = 1;

            # ; Available tokens:
            # ;   %percentage% (default) - total cpu load averaged over all cores
            # ;   %percentage-sum% - Cumulative load on all cores
            # ;   %percentage-cores% - load percentage for each core
            # ;   %percentage-core[1-9]% - load percentage for specific core
            label = " %percentage%%";

            # ; Spacing between individual per-core ramps
            # ;;ramp-coreload-spacing = 1;
            # ;;ramp-coreload-0 = "";
            # ;;ramp-coreload-1 = "";
            # ;;ramp-coreload-2 = "";
            # ;;ramp-coreload-3 = "";
            # ;;ramp-coreload-4 = "";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/date" = {
            type = "internal/date";

            # ; Seconds to sleep between updates
            interval = 1.0;

            # ; See "http://en.cppreference.com/w/cpp/io/manip/put_time" for details on how to format the date string
            # ; NOTE: if you want to use syntax tags here you need to use %%{...}
            # ;;date = %Y-%m-%d%

            # ; Optional time format
            time = "%I:%M %p";

            # ; if `date-alt` or `time-alt` is defined, clicking
            # ; the module will toggle between formats
            # ;;date-alt = %A, %d %B %Y
            #time-alt = %d/%m/%Y%
            time-alt = "%A %b %d, %G";

            # ; Available tags:
            # ;   <label> (default)

            format = "<label>";
            format-prefix = " ";
            format-prefix-font = 2;
            format-prefix-foreground = "\${color.RED}";
            format-background = "\${color.ALTBACKGROUND}";

            # ; Available tokens:
            # ;   %date%
            # ;   %time%
            # ; Default: %date%
            label = "%time%";
            label-font = 5;

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/filesystem" = {
            type = "internal/fs";

            # ;
            # Mountpoints to display
            mount-0 = "/";
            # ;
            # ;mount-1 = /home
            # ;
            # ;mount-2 = /var

            # ;
            # Seconds to sleep between updates
            # ; Default: 30
            interval = 10;

            # ;
            # Display fixed precision values
            # ; Default: false
            fixed-values = true;

            # ;
            # Spacing between entries
            # ; Default: 2
            # ;;spacing = 4

            # ; Available tags:
            # ;   <label-mounted> (default)
            # ;   <bar-free>
            # ;   <bar-used>
            # ;   <ramp-capacity>
            format-mounted = "<label-mounted>";
            format-mounted-background = "\${color.BACKGROUND}";
            format-mounted-padding = 1;

            format-mounted-prefix = "";
            format-mounted-prefix-font = 2;
            format-mounted-prefix-foreground = "\${color.MAGENTA}";

            # ; Available tags:
            # ;   <label-unmounted> (default)
            format-unmounted = "<label-unmounted>";
            format-unmounted-background = "\${color.BACKGROUND}";
            format-unmounted-padding = 1;

            format-unmounted-prefix = "";
            format-unmounted-prefix-font = 2;
            format-unmounted-prefix-foreground = "\${color.RED}";

            # ; Available tokens:
            # ;   %mountpoint%
            # ;   %type%
            # ;   %fsname%
            # ;   %percentage_free%
            # ;   %percentage_used%
            # ;   %total%
            # ;   %free%
            # ;   %used%
            # ; Default: %mountpoint% %percentage_free%%
            label-mounted = " %free%";

            # ; Available tokens:
            # ;   %mountpoint%
            # ; Default: %mountpoint% is not mounted
            label-unmounted = " %mountpoint%: NM";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/memory" = {
            type = "internal/memory";

            # ; Seconds to sleep between updates
            # ; Default: 1
            interval = 3;

            # ; Available tags:
            # ;   <label> (default)
            # ;   <bar-used>
            # ;   <bar-free>
            # ;   <ramp-used>
            # ;   <ramp-free>
            # ;   <bar-swap-used>
            # ;   <bar-swap-free>
            # ;   <ramp-swap-used>
            # ;   <ramp-swap-free>
            format = "<label>";
            format-background = "\${color.BACKGROUND}";
            format-padding = 1;

            format-prefix = "";
            format-prefix-font = 2;
            format-prefix-foreground = "\${color.CYAN}";

            # ; Available tokens:
            # ;   %percentage_used% (default)
            # ;   %percentage_free%
            # ;   %gb_used%
            # ;   %gb_free%
            # ;   %gb_total%
            # ;   %mb_used%
            # ;   %mb_free%
            # ;   %mb_total%
            # ;   %percentage_swap_used%
            # ;   %percentage_swap_free%
            # ;   %mb_swap_total%
            # ;   %mb_swap_free%
            # ;   %mb_swap_used%
            # ;   %gb_swap_total%
            # ;   %gb_swap_free%
            # ;   %gb_swap_used%

            label = " %mb_used%";

            # ; Only applies if <ramp-used> is used
            # ;;ramp-used-0 = 
            # ;;ramp-used-1 = 
            # ;;ramp-used-2 = 
            # ;;ramp-used-3 = 
            # ;;ramp-used-4 = 

            # ; Only applies if <ramp-free> is used
            # ;;ramp-free-0 = 
            # ;;ramp-free-1 = 
            # ;;ramp-free-2 = 
            # ;;ramp-free-3 = 
            # ;;ramp-free-4 = 

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/used-memory" = {
            type = "custom/script";

            exec = "free -m | grep 'Mem:' | tr -s ' ' | cut -d ' ' -f3";

            tail = true;
            interval = 5;

            format = "<label>";
            format-background = "\${color.BACKGROUND}";
            format-padding = 1;

            format-prefix = "";
            format-prefix-font = 2;
            format-prefix-foreground = "\${color.CYAN}";

            label = " %output% MB";

            click-left = ''alacritty --class 'alacritty-float,alacritty-float' --config-file ~/.config/bspwm/alacritty/alacritty.yml -e "top" &'';

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/mpd" = {
            type = "internal/mpd";

            # ;
            # Host where mpd is running (either ip or domain name)
            # ; Can also be the full path to a unix socket where mpd is running.
            # ;;host = 127.0 .0 .1
            # ;
            # ;port = 6600
            # ;
            # ;password = mysecretpassword

            # ;
            # Seconds to sleep between progressbar/song timer sync
            # ; Default: 1
            interval = 2;

            # ;
            # Available tags:
            # ;   <label-song> (default)
            # ;   <label-time>
            # ;   <bar-progress>
            # ;   <toggle> - gets replaced with <icon-(pause|play)>
            # ;   <toggle-stop> - gets replaced with <icon-(stop|play)>
            # ;   <icon-random>
            # ;   <icon-repeat>
            # ;   <icon-repeatone> (deprecated)
            # ;   <icon-single> - Toggle playing only a single song. Replaces <icon-repeatone>
            # ;   <icon-consume>
            # ;   <icon-prev>
            # ;   <icon-stop>
            # ;   <icon-play>
            # ;   <icon-pause>
            # ;   <icon-next>
            # ;   <icon-seekb>
            # ;   <icon-seekf>

            format-online = "<icon-prev> <toggle> <icon-next>";
            # ;
            # ;format-online-prefix = " ";
            # ;
            # ;format-online-prefix-font = 2;
            # ;
            # ;format-online-prefix-foreground = "\${color.GREEN}";
            format-online-background = "\${color.ALTBACKGROUND}";

            format-playing = "\${self.format-online}";
            format-paused = "\${self.format-online}";
            format-stopped = "\${self.format-online}";

            # ;
            # Available tags:
            # ;   <label-offline>
            format-offline = "<label-offline>";
            #format-offline-prefix = " "
            format-offline-background = "\${color.ALTBACKGROUND}";

            # ; Available tokens:
            # ;   %artist%
            # ;   %album-artist%
            # ;   %album%
            # ;   %date%
            # ;   %title%
            # ; Default: %artist% - %title%
            label-song = "%artist% - %title%";
            label-song-maxlen = 25;
            label-song-ellipsis = true;

            # ; Available tokens:
            # ;   %elapsed%
            # ;   %total%
            # ; Default: %elapsed% / %total%
            # ;;abel-time = %elapsed% / %total%

            # ; Available tokens:
            # ;   None
            label-offline = "";

            # ; Only applies if <icon-X> is used
            icon-play = "";
            icon-play-font = 2;
            icon-play-foreground = "\${color.GREEN}";
            icon-pause = "";
            icon-pause-font = 2;
            icon-pause-foreground = "\${color.YELLOW}";
            icon-stop = "";
            icon-stop-foreground = "\${color.RED}";
            icon-prev = "玲";
            icon-prev-font = 1;
            icon-prev-foreground = "\${color.BLUE}";
            icon-next = "怜";
            icon-next-font = 1;
            icon-next-foreground = "\${color.BLUE}";

            # ; Used to display the state of random/repeat/repeatone/single
            # ; Only applies if <icon-[random|repeat|repeatone|single]> is used
            # ;;toggle-on-foreground = #ff
            # ;;toggle-off-foreground = #55

            # ;;-----------
          };
          "module/song" = {
            type = "internal/mpd";

            interval = 2;

            format-online = "<label-song>";
            format-online-font = 5;
            format-offline = "<label-offline>";
            format-offline-font = 5;

            format-playing = "\${self.format-online}";
            format-paused = "\${self.format-online}";
            format-stopped = "";

            label-offline = "Offline";
            label-song = "%title%";
            label-song-maxlen = 25;
            label-song-ellipsis = true;

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          # ; If you use both a wired and a wireless network, Add both modules in config.ini
          "module/ethernet" = {
            type = "internal/network";
            interface = "\${system.sys_network_interface}";

            interval = 1.0;
            accumulate-stats = true;
            unknown-as-up = true;

            format-connected = "<label-connected>";
            format-connected-prefix = "歷 ";
            format-connected-prefix-foreground = "\${color.MAGENTA}";
            format-connected-prefix-font = 2;
            format-connected-background = "\${color.BACKGROUND}";
            format-connected-padding = 1;

            format-disconnected = "<label-disconnected>";
            format-disconnected-prefix = "轢 ";
            format-disconnected-prefix-font = 2;
            format-disconnected-foreground = "\${color.ALTFOREGROUND}";
            format-disconnected-background = "\${color.BACKGROUND}";
            format-disconnected-padding = 1;

            label-connected = "%{A1:nmd &:}%downspeed% | %upspeed%%{A}";
            label-disconnected = "%{A1:nmd &:}Offline%{A}";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/network" = {
            type = "internal/network";
            interface = "\${system.sys_network_interface}";

            # ; Seconds to sleep between updates
            # ; Default: 1
            interval = 1.0;

            # ; Test connectivity every Nth update
            # ; A value of 0 disables the feature
            # ; NOTE: Experimental (needs more testing)
            # ; Default: 0
            # ;ping-interval = 3

            # ; @deprecated: Define min width using token specifiers (%downspeed:min% and %upspeed:min%)
            # ; Minimum output width of upload/download rate
            # ; Default: 3
            # ;;udspeed-minwidth = 5

            # ; Accumulate values from all interfaces
            # ; when querying for up/downspeed rate
            # ; Default: false
            accumulate-stats = true;

            # ; Consider an `UNKNOWN` interface state as up.
            # ; Some devices have an unknown state, even when they're running
            # ; Default: false
            unknown-as-up = true;

            # ; Available tags:
            # ;   <label-connected> (default)
            # ;   <ramp-signal>
            format-connected = "<ramp-signal> <label-connected>";
            format-connected-background = "\${color.BACKGROUND}";
            format-connected-padding = 1;

            # ; Available tags:
            # ;   <label-disconnected> (default)

            format-disconnected = "<label-disconnected>";
            format-disconnected-prefix = "睊 ";
            format-disconnected-prefix-font = 2;
            format-disconnected-foreground = "\${color.ALTFOREGROUND}";
            format-disconnected-background = "\${color.BACKGROUND}";
            format-disconnected-padding = 1;

            # ; Available tags:
            # ;   <label-connected> (default)
            # ;   <label-packetloss>
            # ;   <animation-packetloss>
            # ;;format-packetloss = <animation-packetloss> <label-connected>

            # ; Available tokens:
            # ;   %ifname%    [wireless+wired]
            # ;   %local_ip%  [wireless+wired]
            # ;   %local_ip6% [wireless+wired]
            # ;   %essid%     [wireless]
            # ;   %signal%    [wireless]
            # ;   %upspeed%   [wireless+wired]
            # ;   %downspeed% [wireless+wired]
            # ;   %linkspeed% [wired]
            # ; Default: %ifname% %local_ip%
            # ;label-connected = "%essid%  %downspeed%"
            label-connected = "%{A1:nmd &:}%essid%%{A}";

            # ; Available tokens:
            # ;   %ifname%    [wireless+wired]
            # ; Default: (none)
            label-disconnected = "%{A1:nmd &:}Offline%{A}";

            # ; Available tokens:
            # ;   %ifname%    [wireless+wired]
            # ;   %local_ip%  [wireless+wired]
            # ;   %local_ip6% [wireless+wired]
            # ;   %essid%     [wireless]
            # ;   %signal%    [wireless]
            # ;   %upspeed%   [wireless+wired]
            # ;   %downspeed% [wireless+wired]
            # ;   %linkspeed% [wired]
            # ; Default: (none)
            # ;label-packetloss = %essid%
            # ;label-packetloss-foreground = #eefafafa

            # ; Only applies if <ramp-signal> is used
            ramp-signal-0 = "直";
            ramp-signal-1 = "直";
            ramp-signal-2 = "直";
            ramp-signal-3 = "直";
            ramp-signal-4 = "直";
            ramp-signal-foreground = "\${color.MAGENTA}";
            ramp-signal-font = 2;

            # ; Only applies if <animation-packetloss> is used
            # ;;animation-packetloss-0 = ⚠
            # ;;animation-packetloss-0-foreground = #ffa64c
            # ;;animation-packetloss-1 = ⚠
            # ;;animation-packetloss-1-foreground = #000000
            # ; Framerate in milliseconds
            # ;;animation-packetloss-framerate = 500

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/bluetooth" = {
            type = "custom/script";
            exec = "~/.config/bspwm/themes/onedark/polybar/scripts/bluetooth.sh";
            interval = 1;
            tail = true;
            format = "<label>";
            format-padding = 1;
            label = "%output%";
            click-left = "~/.config/bspwm/scripts/rofi_bluetooth &";
            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/volume" = {
            type = "internal/pulseaudio";

            # ; Sink to be used, if it exists (find using `pacmd list-sinks`, name field)
            # ; If not, uses default sink
            sink = "";

            # ; Use PA_VOLUME_UI_MAX (~153%) if true, or PA_VOLUME_NORM (100%) if false
            # ; Default: true
            use-ui-max = false;

            # ; Interval for volume increase/decrease (in percent points)
            # ; Default: 5
            interval = 5;

            # ; Available tags:
            # ;   <label-volume> (default)
            # ;   <ramp-volume>
            # ;   <bar-volume>
            format-volume = "<ramp-volume> <bar-volume>";
            format-volume-background = "\${color.BACKGROUND}";
            format-volume-padding = 1;

            # ; Available tags:
            # ;   <label-muted> (default)
            # ;   <ramp-volume>
            # ;   <bar-volume>
            format-muted = "<label-muted>";
            format-muted-prefix = "婢";
            format-muted-prefix-font = 2;
            format-muted-prefix-foreground = "\${color.ALTFOREGROUND}";
            format-muted-background = "\${color.BACKGROUND}";
            format-muted-padding = 1;

            # ; Available tokens:
            # ;   %percentage% (default)
            # ;label-volume = %percentage%%

            # ; Available tokens:
            # ;   %percentage% (default)
            label-muted = " Mute";
            label-muted-foreground = "\${color.ALTFOREGROUND}";

            # ; Only applies if <bar-volume> is used
            bar-volume-width = 10;
            bar-volume-gradient = false;

            bar-volume-indicator = "雷";
            bar-volume-indicator-font = 2;
            bar-volume-indicator-foreground = "\${color.BLUE}";

            bar-volume-fill = "絛";
            bar-volume-fill-font = 3;
            bar-volume-foreground-0 = "\${color.BLUE}";
            bar-volume-foreground-1 = "\${color.BLUE}";
            bar-volume-foreground-2 = "\${color.BLUE}";
            bar-volume-foreground-3 = "\${color.BLUE}";
            bar-volume-foreground-4 = "\${color.BLUE}";

            bar-volume-empty = "絛";
            bar-volume-empty-font = 3;
            bar-volume-empty-foreground = "\${color.ALTBACKGROUND}";

            # ; Only applies if <ramp-volume> is used
            ramp-volume-0 = "奄";
            ramp-volume-1 = "奄";
            ramp-volume-2 = "奄";
            ramp-volume-3 = "奔";
            ramp-volume-4 = "奔";
            ramp-volume-5 = "奔";
            ramp-volume-6 = "墳";
            ramp-volume-7 = "墳";
            ramp-volume-8 = "墳";
            ramp-volume-9 = "墳";
            ramp-volume-font = 2;
            ramp-volume-foreground = "\${color.BLUE}";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/temperature" = {
            type = "internal/temperature";

            # ; Seconds to sleep between updates
            # ; Default: 1
            interval = 0.5;

            # ; Thermal zone to use
            # ; To list all the zone types, run
            # ; $ for i in /sys/class/thermal/thermal_zone*; do echo "$i: $(<$i/type)"; done
            # ; Default: 0
            thermal-zone = 0;

            # ; Full path of temperature sysfs path
            # ; Use `sensors` to find preferred temperature source, then run
            # ; $ for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
            # ; to find path to desired file
            # ; Default reverts to thermal zone setting
            # ;;hwmon-path = /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input

            # ; Threshold temperature to display warning label (in degrees celsius)
            # ; Default: 80
            warn-temperature = 60;

            # ; Whether or not to show units next to the temperature tokens (°C, °F)
            # ; Default: true
            units = true;

            # ; Available tags:
            # ;   <label> (default)
            # ;   <ramp>
            format = "<ramp> <label>";

            # ; Available tags:
            # ;   <label-warn> (default)
            # ;   <ramp>
            format-warn = "<ramp> <label-warn>";

            # ; Available tokens:
            # ;   %temperature% (deprecated)
            # ;   %temperature-c%   (default, temperature in °C)
            # ;   %temperature-f%   (temperature in °F)
            label = "%temperature-c%";

            # ; Available tokens:
            # ;   %temperature% (deprecated)
            # ;   %temperature-c%   (default, temperature in °C)
            # ;   %temperature-f%   (temperature in °F)
            label-warn = "%temperature-c%";
            label-warn-foreground = "\${color.RED}";

            # ; Requires the <ramp> tag
            # ; The icon selection will range from 0 to `warn-temperature`
            # ; with the current temperature as index.
            ramp-0 = "";
            ramp-1 = "";
            ramp-2 = "";
            ramp-3 = "";
            ramp-4 = "";
            ramp-5 = "";
            ramp-6 = "";
            ramp-7 = "";
            ramp-8 = "";
            ramp-9 = "";
            ramp-font = 2;
            ramp-foreground = "\${color.YELLOW}";
            # ;;ramp-foreground = #55

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/keyboard" = {
            type = "internal/xkeyboard";

            # ; List of indicators to ignore
            # ;blacklist-0 = num lock
            blacklist-1 = "scroll lock";

            # ; Available tags:
            # ;   <label-layout> (default)
            # ;   <label-indicator> (default)
            format = "<label-layout> <label-indicator>";
            format-prefix = " ";
            format-prefix-font = 2;
            format-prefix-foreground = "\${color.MAGENTA}";
            # ;;format-spacing = 0

            # ; Available tokens:
            # ;   %layout%
            # ;   %name%
            # ;   %number%
            # ; Default: %layout%
            label-layout = "%name%";
            # ;;label-layout-padding = 2
            # ;;label-layout-background = #bc99ed
            # ;;label-layout-foreground = #000

            # ; Available tokens:
            # ;   %name%
            # ; Default: %name%
            label-indicator-on = " %name%";
            # ;;label-indicator-padding = 2;
            label-indicator-on-foreground = "\${color.BLUE}";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/title" = {
            type = "internal/xwindow";

            # ; Available tags:
            # ;   <label> (default)
            format = "<label>";
            format-prefix = " ";
            format-prefix-font = 2;
            format-prefix-foreground = "\${color.BLUE}";
            format-background = "\${color.ALTBACKGROUND}";

            # ; Available tokens:
            # ;   %title%
            # ; Default: %title%
            label = "%title%";
            label-maxlen = 25;

            # ; Used instead of label when there is no window title
            # ; Available tokens:
            # ;   None
            label-empty = "Desktop";
            # ;label-empty-foreground = ${color.ALTBLACK}

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/openbox" = {
            type = "internal/xworkspaces";

            # ; Only show workspaces defined on the same output as the bar
            # ;
            # ; Useful if you want to show monitor specific workspaces
            # ; on different bars
            # ;
            # ; Default: false
            pin-workspaces = true;

            # ; Create click handler used to focus desktop
            # ; Default: true
            enable-click = true;

            # ; Create scroll handlers used to cycle desktops
            # ; Default: true
            enable-scroll = true;

            # ; icon-[0-9]+ = <desktop-name>;<icon>
            # ; NOTE: The desktop name needs to match the name configured by the WM
            # ; You can get a list of the defined desktops using:
            # ; $ xprop -root _NET_DESKTOP_NAMES
            icon-0 = "1;";
            icon-1 = "2;";
            icon-2 = "3;";
            icon-3 = "4;";
            icon-4 = "5;漣";
            icon-default = "";

            # ; Available tags:
            # ;   <label-monitor>
            # ;   <label-state> - gets replaced with <label-(active|urgent|occupied|empty)>
            # ; Default: <label-state>
            format = "<label-state>";
            format-background = "\${color.ALTBACKGROUND}";
            format-font = 2;

            # ; Available tokens:
            # ;   %name%
            # ; Default: %name%
            label-monitor = "%name%";

            # ; Available tokens:
            # ;   %name%
            # ;   %icon%
            # ;   %index%
            # ; Default: %icon%  %name%
            label-active = "ﱣ";
            label-active-foreground = "\${color.GREEN}";
            # ;;label-active-underline = ${color.ALTBLACK}

            # ; Available tokens:
            # ;   %name%
            # ;   %icon%
            # ;   %index%
            # ; Default: %icon%  %name%
            label-occupied = "綠";
            label-occupied-foreground = "\${color.ACCENT}";
            # ;;label-occupied-underline = ${color.ALTBLACK}

            # ; Available tokens:
            # ;   %name%
            # ;   %icon%
            # ;   %index%
            # ; Default: %icon%  %name%
            label-urgent = "ﱣ";
            label-urgent-foreground = "\${color.RED}";
            # ;;label-urgent-underline = ${color.ALTBLACK}

            # ; Available tokens:
            # ;   %name%
            # ;   %icon%
            # ;   %index%
            # ; Default: %icon%  %name%
            label-empty = "祿";
            label-empty-foreground = "\${color.ACCENT}";

            label-active-padding = 1;
            label-urgent-padding = 1;
            label-occupied-padding = 1;
            label-empty-padding = 1;

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/menu" = {
            type = "custom/text";

            content = "";
            content-font = 6;
            content-background = "\${color.ALTBACKGROUND}";
            content-foreground = "\${color.GREEN}";
            content-padding = 0;

            click-left = "~/.config/bspwm/scripts/rofi_launcher";
            click-right = "~/.config/bspwm/scripts/rofi_runner";

            # ;; _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
          };
          "module/sysmenu" = {
            type = "custom/text";

            content = "襤";
            content-font = 2;
            content-background = "\${color.ALTBACKGROUND}";
            content-foreground = "\${color.RED}";
            content-padding = 0;

            click-left = "~/.config/bspwm/scripts/rofi_powermenu";
          };
        };
      };
    };
  };
}
