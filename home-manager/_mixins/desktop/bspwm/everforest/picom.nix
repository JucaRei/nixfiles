{ config, pkgs, ... }:
let
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  nixgl = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
in
{
  services = {
    picom = {
      enable = true;
      package = if (isGeneric) then (nixgl pkgs.picom) else pkgs.picom;
      backend = "xrender"; # "glx";
      shadow = true;
      shadowExclude = [
        "_GTK_FRAME_EXTENTS@:c"
      ];
      # ''_BSPWM_TAGS@:s != 'floating' && name != 'Dunst' && window_type != 'popup_menu' && window_type != 'dropdown_menu' && class_g != 'Rofi'"
      #   "class_g ?= 'peek'" ''
      fade = true;
      inactiveOpacity = 0.9; # 0.95;
      settings = {
        #################################
        #       General Settings        #
        #################################
        # Enable remote control via D-Bus. See the *D-BUS API* section below for more details.
        # dbus = false

        # Try to detect WM windows (a non-override-redirect window with no
        # child that has 'WM_STATE') and mark them as active.
        mark-wmwin-focused = false;
        # Mark override-redirect windows that doesn't have a child window with 'WM_STATE' focused.
        # mark-ovredir-focused = true;

        # Try to detect windows with rounded corners and don't consider them
        # shaped windows. The accuracy is not very high, unfortunately.
        #
        detect-rounded-corners = true;
        # Detect '_NET_WM_OPACITY' on client windows, useful for window managers
        # not passing '_NET_WM_OPACITY' of client windows to frame windows.
        #
        detect-client-opacity = true;
        # Specify refresh rate of the screen. If not specified or 0, picom will
        # try detecting this with X RandR extension.
        #
        # refresh-rate = 60
        # refresh-rate = 0

        # Limit picom to repaint at most once every 1 / 'refresh_rate' second to
        # boost performance. This should not be used with
        #   vsync drm/opengl/opengl-oml
        # as they essentially does sw-opti's job already,
        # unless you wish to specify a lower refresh rate than the actual value.
        #
        # sw-opti =

        # Use EWMH '_NET_ACTIVE_WINDOW' to determine currently focused window,
        # rather than listening to 'FocusIn'/'FocusOut' event. Might have more accuracy,
        # provided that the WM supports it.
        #
        # Unredirect all windows if a full-screen opaque window is detected,
        # to maximize performance for full-screen windows. Known to cause flickering
        # when redirecting/unredirecting windows.
        #
        # unredir-if-possible = false

        # Delay before unredirecting the window, in milliseconds. Defaults to 0.
        # unredir-if-possible-delay = 0

        # Conditions of windows that shouldn't be considered full-screen for unredirecting screen.
        # unredir-if-possible-exclude = []

        # Use 'WM_TRANSIENT_FOR' to group windows, and consider windows
        # in the same group focused at the same time.
        #
        detect-transient = true;
        # Use 'WM_CLIENT_LEADER' to group windows, and consider windows in the same
        # group focused at the same time. 'WM_TRANSIENT_FOR' has higher priority if
        # detect-transient is enabled, too.
        #
        detect-client-leader = true;
        # Resize damaged region by a specific number of pixels.
        # A positive value enlarges it while a negative one shrinks it.
        # If the value is positive, those additional pixels will not be actually painted
        # to screen, only used in blur calculation, and such. (Due to technical limitations,
        # with use-damage, those pixels will still be incorrectly painted to screen.)
        # Primarily used to fix the line corruption issues of blur,
        # in which case you should use the blur radius value here
        # (e.g. with a 3x3 kernel, you should use `--resize-damage 1`,
        # with a 5x5 one you use `--resize-damage 2`, and so on).
        # May or may not work with *--glx-no-stencil*. Shrinking doesn't function correctly.
        #
        # resize-damage = 1

        # Specify a list of conditions of windows that should be painted with inverted color.
        # Resource-hogging, and is not well tested.
        #
        # invert-color-include = []

        # GLX backend: Avoid using stencil buffer, useful if you don't have a stencil buffer.
        # Might cause incorrect opacity when rendering transparent content (but never
        # practically happened) and may not work with blur-background.
        # My tests show a 15% performance boost. Recommended.
        #
        # glx-no-stencil = false

        # GLX backend: Avoid rebinding pixmap on window damage.
        # Probably could improve performance on rapid window content changes,
        # but is known to break things on some drivers (LLVMpipe, xf86-video-intel, etc.).
        # Recommended if it works.
        #
        # glx-no-rebind-pixmap = false

        # Disable the use of damage information.
        # This cause the whole screen to be redrawn everytime, instead of the part of the screen
        # has actually changed. Potentially degrades the performance, but might fix some artifacts.
        # The opposing option is use-damage
        #
        # no-use-damage = false
        use-damage = true;
        # Use X Sync fence to sync clients' draw calls, to make sure all draw
        # calls are finished before picom starts drawing. Needed on nvidia-drivers
        # with GLX backend for some users.
        #
        xrender-sync-fence = true;

        # GLX backend: Use specified GLSL fragment shader for rendering window contents.
        # See `compton-default-fshader-win.glsl` and `compton-fake-transparency-fshader-win.glsl`
        # in the source tree for examples.
        #
        # glx-fshader-win = ''

        # Force all windows to be painted with blending. Useful if you
        # have a glx-fshader-win that could turn opaque pixels transparent.
        #
        # force-win-blend = false

        # Do not use EWMH to detect fullscreen windows.
        # Reverts to checking if a window is fullscreen based only on its size and coordinates.
        #
        # no-ewmh-fullscreen = false

        # Dimming bright windows so their brightness doesn't exceed this set value.
        # Brightness of a window is estimated by averaging all pixels in the window,
        # so this could comes with a performance hit.
        # Setting this to 1.0 disables this behaviour. Requires --use-damage to be disabled. (default: 1.0)
        #
        # max-brightness = 1.0

        # Make transparent windows clip other windows like non-transparent windows do,
        # instead of blending on top of them.
        #
        # transparent-clipping = false

        # Set the log level. Possible values are:
        #  "trace", "debug", "info", "warn", "error"
        # in increasing level of importance. Case doesn't matter.
        # If using the "TRACE" log level, it's better to log into a file
        # using *--log-file*, since it can generate a huge stream of logs.
        #
        # log-level = "debug"
        log-level = "warn";
        # Set the log file.
        # If *--log-file* is never specified, logs will be written to stderr.
        # Otherwise, logs will to written to the given file, though some of the early
        # logs might still be written to the stderr.
        # When setting this option from the config file, it is recommended to use an absolute path.
        #
        log-file = "/tmp/picom.log";

        # Show all X errors (for debugging)
        # show-all-xerrors = false

        # Write process ID to a file.
        # write-pid-path = '/path/to/your/log/file'

        # Window type settings
        #
        # 'WINDOW_TYPE' is one of the 15 window types defined in EWMH standard:
        #     "unknown", "desktop", "dock", "toolbar", "menu", "utility",
        #     "splash", "dialog", "normal", "dropdown_menu", "popup_menu",
        #     "tooltip", "notification", "combo", and "dnd".
        #
        # Following per window-type options are available: ::
        #
        #   fade, shadow:::
        #     Controls window-type-specific shadow and fade settings.
        #
        #   opacity:::
        #     Controls default opacity of the window type.
        #
        #   focus:::
        #     Controls whether the window of this type is to be always considered focused.
        #     (By default, all window types except "normal" and "dialog" has this on.)
        #
        #   full-shadow:::
        #     Controls whether shadow is drawn under the parts of the window that you
        #     normally won't be able to see. Useful when the window has parts of it
        #     transparent, and you want shadows in those areas.
        #
        #   redir-ignore:::
        #     Controls whether this type of windows should cause screen to become
        #     redirected again after been unredirected. If you have unredir-if-possible
        #     set, and doesn't want certain window to cause unnecessary screen redirection,
        #     you can set this to `true`.
        #
        wintypes = {
          tooltip = {
            fade = true;
            shadow = true;
            opacity = 0.75;
            focus = true;
            full-shadow = false;
          };
          dock = {
            shadow = false;
          };
          popup_menu = {
            opacity = 0.9;
            shadow = true;
          };
          dropdown_menu = {
            opacity = 0.8;
            shadow = true;
          };
          dialog = {
            shadow = true;
          };
        };
        #################################
        #     Background-Blurring       #
        #################################
        # Blur background of semi-transparent / ARGB windows.
        # Bad in performance, with driver-dependent behavior.
        # The name of the switch may change without prior notifications.
        blur-background = true;
        #################################
        #   Transparency / Opacity      #
        #################################
        # Opacity of inactive windows. (0.1 - 1.0, defaults to 1.0)
        # inactive-opacity = 1

        # Opacity of window titlebars and borders. (0.1 - 1.0, disabled by default)
        # frame-opacity = 1.0
        # frame-opacity = 0.7;

        # Let inactive opacity set by -i override the '_NET_WM_OPACITY' values of windows.
        inactive-opacity-override = true; # this fixed opacity for me. Not sure what is setting _NET_WM_OPACITY
        # Default opacity for active windows. (0.0 - 1.0, defaults to 1.0)
        # active-opacity = 0.1

        # Dim inactive windows. (0.0 - 1.0, defaults to 0.0)
        # inactive-dim = 0.8

        # Specify a list of conditions of windows that should always be considered focused.
        focus-exclude = [ ];

        # Use fixed inactive dim value, instead of adjusting according to window opacity.
        # inactive-dim-fixed = 1.0

        # Specify a list of opacity rules, in the format `PERCENT:PATTERN`,
        # like `50:name *= "Firefox"`. picom-trans is recommended over this.
        # Note we don't make any guarantee about possible conflicts with other
        # programs that set '_NET_WM_WINDOW_OPACITY' on frame or client windows.
        # example:
        #    opacity-rule = [ "80:class_g = 'URxvt'" ];
        #
        opacity-rule = [
          # make windows that are behind others completely transparent
          # "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'",
          # "0:_NET_WM_STATE@[0]:32a *= '_NET_WM_STATE_HIDDEN'",
          # "0:_NET_WM_STATE@[1]:32a *= '_NET_WM_STATE_HIDDEN'",
          # "0:_NET_WM_STATE@[2]:32a *= '_NET_WM_STATE_HIDDEN'",
          # "0:_NET_WM_STATE@[3]:32a *= '_NET_WM_STATE_HIDDEN'",
          # "0:_NET_WM_STATE@[4]:32a *= '_NET_WM_STATE_HIDDEN'"
        ];
        #################################
        #           Fading              #
        #################################
        # Fade windows in/out when opening/closing and when opacity changes,
        #  unless no-fading-openclose is used.
        # Opacity change between steps while fading in. (0.01 - 1.0, defaults to 0.028)

        fade-in-step = 0.01;
        # Opacity change between steps while fading out. (0.01 - 1.0, defaults to 0.03)
        fade-out-step = 0.01;
        # The time between steps in fade step, in milliseconds. (> 0, defaults to 10)
        fade-delta = 3; # 5;
        # Specify a list of conditions of windows that should not be faded.
        fade-exclude = [
          "class_g = 'Rofi'"
          "class_g ?= 'peek'"
        ];
        # Do not fade on window open/close.
        # no-fading-openclose = false

        # Do not fade destroyed ARGB windows with WM frame. Workaround of bugs in Openbox, Fluxbox, etc.
        # no-fading-destroyed-argb = false

        #################################
        #             Shadows           #
        #################################
        # Enabled client-side shadows on windows. Note desktop windows
        # (windows with '_NET_WM_WINDOW_TYPE_DESKTOP') never get shadow,
        # unless explicitly requested using the wintypes option.
        shadow = true;
        # The opacity of shadows. (0.0 - 1.0, defaults to 0.75)
        shadow-opacity = .75;
        # The left offset for shadows, in pixels. (defaults to -15)
        shadow-offset-x = 0;
        # The top offset for shadows, in pixels. (defaults to -15)
        shadow-offset-y = 10;
        # The blur radius for shadows, in pixels. (defaults to 12)
        shadow-radius = 20;


        # Specify a X geometry that describes the region in which shadow should not
        # be painted in, such as a dock window region. Use
        #    shadow-exclude-reg = "x10+0+0"
        # for example, if the 10 pixels on the bottom of the screen should not have shadows painted on.
        #
        # shadow-exclude-reg = ""

        # Crop shadow of a window fully on a particular Xinerama screen to the screen.
        # xinerama-shadow-crop = false

        # Red color value of shadow (0.0 - 1.0, defaults to 0).
        # shadow-red = 0

        # Green color value of shadow (0.0 - 1.0, defaults to 0).
        # shadow-green = 0

        # Blue color value of shadow (0.0 - 1.0, defaults to 0).
        # shadow-blue = 0

        # Do not paint shadows on shaped windows. Note shaped windows
        # here means windows setting its shape through X Shape extension.
        # Those using ARGB background is beyond our control.
        # Deprecated, use
        #   shadow-exclude = 'bounding_shaped'
        # or
        #   shadow-exclude = 'bounding_shaped && !rounded_corners'
        # instead.
        #
        # shadow-ignore-shaped = ''

        # Specify a list of conditions of windows that should have no shadow.
        #
        # examples:
        #   shadow-exclude = "n:e:Notification";
        #

        blur = {
          method = "dual_kawase";
          size = 20; # 24;
          strenght = 12;
          deviation = 5.0;
          # Exclude conditions for background blur.
          # blur-background-exclude = []
          backround-exclude = [
            "window_type = 'dock'"
            "window_type = 'conky'"
            "window_type = 'desktop'"
            "class_g = 'slop'"
            "class_g ?= 'peek'"
            "_GTK_FRAME_EXTENTS@:c"
          ];
        };

        #################################
        #       Corner Settings         #
        #################################
        corner-radius = 10;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'Rofi'"
          # "window_type = 'conky'"
        ];
        use-ewmh-active-win = false; # true;
        unredir-if-possible = false; # true;
      };
      vSync = false;
      extraArgs = [
        "--legacy-backends"
        "--use-damage"
      ];
    };
  };
}
