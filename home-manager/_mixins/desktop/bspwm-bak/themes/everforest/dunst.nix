{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}: {
  config = {
    # home = {
    #   packages = with pkgs; [
    #     libnotify
    #     dunst
    #     papirus-icon-theme
    #   ];
    # };
    services = {
      dunst = {
        enable = true;
        package = pkgs.dunst;
        iconTheme = {
          name = "Papirus Dark";
          package = pkgs.papirus-icon-theme;
          size = "16x16";
        };
        settings = {
          global = {
            # Which monitor should the notifications be displayed on.
            monitor = 0;

            # Display notification on focused monitor.  Possible modes are:
            #   mouse: follow mouse pointer
            #   keyboard: follow window with keyboard focus
            #   none: don't follow anything
            #
            # "keyboard" needs a window manager that exports the
            # _NET_ACTIVE_WINDOW property.
            # This should be the case for almost all modern window managers.
            #
            # If this option is set to mouse or keyboard, the monitor option
            # will be ignored.
            follow = "mouse";

            ### Geometry ###

            # dynamic width from 0 to 300
            # width = (0, 300)
            # constant width of 300
            width = "(111, 444)";

            # The maximum height of a single notification, excluding the frame.
            height = 222;

            # Position the notification in the top right corner
            origin = "top-right";

            # Offset from the origin
            offset = "15x55";

            # Scale factor. It is auto-detected if value is 0.
            scale = 0;

            # Maximum number of notification (0 means no limit)
            notification_limit = 0;

            # Turn on the progess bar. It appears when a progress hint is passed with
            # for example dunstify -h int:value:12
            progress_bar = true;

            # Set the progress bar height. This includes the frame, so make sure
            # it's at least twice as big as the frame width.
            progress_bar_height = 10;

            # Set the frame width of the progress bar
            progress_bar_frame_width = 1;

            # Set the minimum width for the progress bar
            progress_bar_min_width = 150;

            # Set the maximum width for the progress bar
            progress_bar_max_width = 300;

            # Show how many messages are currently hidden (because of
            # notification_limit).
            indicate_hidden = "yes";

            # The transparency of the window.  Range: [0; 100].
            # This option will only work if a compositing window manager is
            # present (e.g. xcompmgr, compiz, etc.). (X11 only)
            transparency = 0;

            # Draw a line of "separator_height" pixel height between two
            # notifications.
            # Set to 0 to disable.
            separator_height = 5;

            # Padding between text and separator.
            padding = 15;

            # Horizontal padding.
            horizontal_padding = 15;

            # Padding between text and icon.
            text_icon_padding = 0;

            # Defines width in pixels of frame around the notification window.
            # Set to 0 to disable.
            frame_width = 0;

            # Defines color of the frame around the notification window.
            frame_color = "#16161E";

            # Define a color for the separator.
            # possible values are:
            #  * auto: dunst tries to find a color fitting to the background;
            #  * foreground: use the same color as the foreground;
            #  * frame: use the same color as the frame;
            #  * anything else will be interpreted as a X color.
            separator_color = "frame";

            # Sort messages by urgency.
            sort = "yes";

            # Don't remove messages, if the user is idle (no mouse or keyboard input)
            # for longer than idle_threshold seconds.
            # Set to 0 to disable.
            # A client can set the 'transient' hint to bypass this. See the rules
            # section for how to disable this if necessary
            # idle_threshold = 120

            ### Text ###

            font = "Iosevka Medium Italic 10";

            # The spacing between lines.  If the height is smaller than the
            # font height, it will get raised to the font height.
            line_height = 0;

            # Possible values are:
            # full: Allow a small subset of html markup in notifications:
            #        <b>bold</b>
            #        <i>italic</i>
            #        <s>strikethrough</s>
            #        <u>underline</u>
            #
            #        For a complete reference see
            #        <https://docs.gtk.org/Pango/pango_markup.html>.
            #
            # strip: This setting is provided for compatibility with some broken
            #        clients that send markup even though it's not enabled on the
            #        server. Dunst will try to strip the markup but the parsing is
            #        simplistic so using this option outside of matching rules for
            #        specific applications *IS GREATLY DISCOURAGED*.
            #
            # no:    Disable markup parsing, incoming notifications will be treated as
            #        plain text. Dunst will not advertise that it has the body-markup
            #        capability if this is set as a global setting.
            #
            # It's important to note that markup inside the format option will be parsed
            # regardless of what this is set to.
            markup = "full";

            # The format of the message.  Possible variables are:
            #   %a  appname
            #   %s  summary
            #   %b  body
            #   %i  iconname (including its path)
            #   %I  iconname (without its path)
            #   %p  progress value if set ([  0%] to [100%]) or nothing
            #   %n  progress value if set without any extra characters
            #   %%  Literal %
            # Markup is allowed
            format = ''
              <b>%s</b>
              %b'';

            # Alignment of message text.
            # Possible values are "left", "center" and "right".
            alignment = "center";

            # Vertical alignment of message text and icon.
            # Possible values are "top", "center" and "bottom".
            vertical_alignment = "center";

            # Show age of message if message is older than show_age_threshold
            # seconds.
            # Set to -1 to disable.
            show_age_threshold = 60;

            # Specify where to make an ellipsis in long lines.
            # Possible values are "start", "middle" and "end".
            ellipsize = "middle";

            # Ignore newlines '\n' in notifications.
            ignore_newline = "yes";

            # Stack together notifications with the same content
            stack_duplicates = true;

            # Hide the count of stacked notifications with the same content
            hide_duplicate_count = false;

            # Display indicators for URLs (U) and actions (A).
            show_indicators = "no";

            ### Icons ###

            # Align icons left/right/off
            icon_position = "left";

            # Scale small icons up to this size, set to 0 to disable. Helpful
            # for e.g. small files or high-dpi screens. In case of conflict,
            # max_icon_size takes precedence over this.
            icon_size = 48;

            # Scale larger icons down to this size, set to 0 to disable
            max_icon_size = 80;

            # Paths to default icons.
            #  icon_path = /usr/share/icons/Papirus-Dark/48x48/status/:/usr/share/icons/Papirus-Dark/48x48/devices/:/usr/share/icons/Papirus-Dark/48x48/apps

            ### History ###

            # Should a notification popped up from history be sticky or timeout
            # as if it would normally do.
            stick_history = "yes";

            # Maximum amount of notifications kept in history
            history_lenght = 20;

            ### Misc/Advanced ###

            # dmenu path
            dmenu = "${pkgs.dmenu}/bin/dmenu -p ${pkgs.dunst}/bin/dunst:";

            # Browser for opening urls in context menu.
            browser = "${pkgs.firefox}/bin/firefox -new-tab";

            # Always run rule-defined scripts, even if the notification is suppressed
            always_run_script = true;

            # Define the title of the windows spawned by dunst
            title = "Dunst";

            # Define the class of the windows spawned by dunst
            class = "Dunst";

            # Define the corner radius of the notification window
            # in pixel size. If the radius is 0, you have no rounded
            # corners.
            # The radius will be automatically lowered if it exceeds half of the
            # notification height to avoid clipping text and/or icons.
            corner_radius = 5;

            # Ignore the dbus closeNotification message.
            # Useful to enforce the timeout set by dunst configuration. Without this
            # parameter, an application may close the notification sent before the
            # user defined timeout.
            ignore_dbusclose = false;

            ### Wayland ###
            # These settings are Wayland-specific. They have no effect when using X11

            # Uncomment this if you want to let notications appear under fullscreen
            # applications (default: overlay)
            # layer = top

            # Set this to true to use X11 output on Wayland.
            force_xwayland = false;

            ### Legacy ###

            # Use the Xinerama extension instead of RandR for multi-monitor support.
            # This setting is provided for compatibility with older nVidia drivers that
            # do not support RandR and using it on systems that support RandR is highly
            # discouraged.
            #
            # By enabling this setting dunst will not be able to detect when a monitor
            # is connected or disconnected which might break follow mode if the screen
            # layout changes.
            force_xinerama = false;

            ### mouse

            # Defines list of actions for each mouse event
            # Possible values are:
            # * none: Don't do anything.
            # * do_action: Invoke the action determined by the action_name rule. If there is no
            #              such action, open the context menu.
            # * open_url: If the notification has exactly one url, open it. If there are multiple
            #             ones, open the context menu.
            # * close_current: Close current notification.
            # * close_all: Close all notifications.
            # * context: Open context menu for the notification.
            # * context_all: Open context menu for all notifications.
            # These values can be strung together for each mouse event, and
            # will be executed in sequence.
            mouse_left_click = "close_current";
            mouse_middle_click = "do_action, close_current";
            mouse_right_click = "close_all";
          };

          # Experimental features that may or may not work correctly. Do not expect them
          # to have a consistent behaviour across releases.
          experimental = {
            # Calculate the dpi to use on a per-monitor basis.
            # If this setting is enabled the Xft.dpi value will be ignored and instead
            # dunst will attempt to calculate an appropriate dpi value for each monitor
            # using the resolution and physical size. This might be useful in setups
            # where there are multiple screens with very different dpi values.
            per_monitor_dpi = false;
          };

          log_notifs = {script = "~/.config/dunst/scripts/dunst_logger.sh";};

          urgency_low = {
            # IMPORTANT: colors have to be defined in quotation marks.
            # Otherwise the "#" and following would be interpreted as a comment.
            background = "#21222C";
            foreground = "#f8f8f2";
            highlight = "#f8f8f2";
            timeout = 6;
            # Icon for notifications with low urgency, uncomment to enable
            #default_icon = /path/to/icon
          };
          urgency_normal = {
            background = "#21222C";
            foreground = "#f8f8f2";
            highlight = "#f8f8f2";
            highlight-background = "#21222C";
            timeout = 6;
            # Icon for notifications with normal urgency, uncomment to enable
            #default_icon = /path/to/icon
          };
          urgency_critical = {
            background = "#21222C";
            foreground = "#f8f8f2";
            highlight = "#f8f8f2";
            timeout = 10;
            # Icon for notifications with critical urgency, uncomment to enable
            #default_icon = /path/to/icon

            # Every section that isn't one of the above is interpreted as a rules to
            # override settings for certain messages.
            #
            # Messages can be matched by
            #    appname (discouraged, see desktop_entry)
            #    body
            #    category
            #    desktop_entry
            #    icon
            #    match_transient
            #    msg_urgency
            #    stack_tag
            #    summary
            #
            # and you can override the
            #    background
            #    foreground
            #    format
            #    frame_color
            #    fullscreen
            #    new_icon
            #    set_stack_tag
            #    set_transient
            #    set_category
            #    timeout
            #    urgency
            #    skip_display
            #    history_ignore
            #    action_name
            #    word_wrap
            #    ellipsize
            #    alignment
            #
            # Shell-like globbing will get expanded.
            #
            # Instead of the appname filter, it's recommended to use the desktop_entry filter.
            # GLib based applications export their desktop-entry name. In comparison to the appname,
            # the desktop-entry won't get localized.
            #
            # SCRIPTING
            # You can specify a script that gets run when the rule matches by
            # setting the "script" option.
            # The script will be called as follows:
            #   script appname summary body icon urgency
            # where urgency can be "LOW", "NORMAL" or "CRITICAL".
            #
            # NOTE: It might be helpful to run dunst -print in a terminal in order
            # to find fitting options for rules.

            # Disable the transient hint so that idle_threshold cannot be bypassed from the
            # client
            #[transient_disable]
            #    match_transient = yes
            #    set_transient = no
            #
            # Make the handling of transient notifications more strict by making them not
            # be placed in history.
            #[transient_history_ignore]
            #    match_transient = yes
            #    history_ignore = yes

            # fullscreen values
            # show: show the notifications, regardless if there is a fullscreen window opened
            # delay: displays the new notification, if there is no fullscreen window active
            #        If the notification is already drawn, it won't get undrawn.
            # pushback: same as delay, but when switching into fullscreen, the notification will get
            #           withdrawn from screen again and will get delayed like a new notification
            #[fullscreen_delay_everything]
            #    fullscreen = delay
            #[fullscreen_show_critical]
            #    msg_urgency = critical
            #    fullscreen = show

            #[espeak]
            #    summary = "*"
            #    script = dunst_espeak.sh

            #[script-test]
            #    summary = "*script*"
            #    script = dunst_test.sh

            #[ignore]
            #    # This notification will not be displayed
            #    summary = "foobar"
            #    skip_display = true

            #[history-ignore]
            #    # This notification will not be saved in history
            #    summary = "foobar"
            #    history_ignore = yes

            #[skip-display]
            #    # This notification will not be displayed, but will be included in the history
            #    summary = "foobar"
            #    skip_display = yes

            #[signed_on]
            #    appname = Pidgin
            #    summary = "*signed on*"
            #    urgency = low
            #
            #[signed_off]
            #    appname = Pidgin
            #    summary = *signed off*
            #    urgency = low
            #
            #[says]
            #    appname = Pidgin
            #    summary = *says*
            #    urgency = critical
            #
            #[twitter]
            #    appname = Pidgin
            #    summary = *twitter.com*
            #    urgency = normal
            #
            #[stack-volumes]
            #    appname = "some_volume_notifiers"
            #    set_stack_tag = "volume"
            #
            # vim: ft=cfg
          };
        };
      };
    };
    home = {
      # file = {
      #   ".config/dunst/scripts/dunst_logger.sh" = {
      #     text = ''
      #       #!/usr/bin/bash
      #       #set -euo pipefail

      #       # Because certain programs like to insert their own newlines and fuck up my format (im looking at you thunderbird)
      #       # we need to crunch each input to ensure that each component is its own line in the log file
      #       crunch_appname=$(echo "$1" | sed '/^$/d')
      #       crunch_summary=$(echo "$2" | sed '/^$/d' | xargs)
      #       crunch_body=$(echo "$3" | sed '/^$/d' | xargs)
      #       crunch_icon=$(echo "$4" | sed '/^$/d')
      #       crunch_urgency=$(echo "$5" | sed '/^$/d')
      #       timestamp=$(date +"%I:%M %p")

      #       # filter stuff ans add custom icons if you want

      #       # e.g.
      #       # notify-send -u urgency "summary" "body" -i "icon"
      #       #
      #       # this will give
      #       # app-name - notif-send
      #       # urgency - upgency
      #       # summary - summary
      #       # body - body
      #       # icon - icon

      #       # Rules for notifs that send their icons over the wire (w/o an actual path)
      #       if [[ "$crunch_appname" == "Spotify" ]]; then
      #           random_name=$(mktemp --suffix ".png")
      #           artlink=$(playerctl metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')
      #           curl -s "$artlink" -o "$random_name"
      #           crunch_icon=$random_name
      #       elif [[ "$crunch_appname" == "VLC media player" ]]; then
      #           crunch_icon="vlc"
      #       elif [[ "$crunch_appname" == "Calendar" ]] || [[ "$crunch_appname" == "Volume" ]] || [[ "$crunch_appname" == "Brightness" ]] || [[ "$crunch_appname" == "notify-send" ]]; then
      #           exit 0
      #       fi

      #       echo -en "$timestamp\n$crunch_urgency\n$crunch_icon\n$crunch_body\n$crunch_summary\n$crunch_appname\n" >>/tmp/dunstlog

      #       #echo -en "$crunch_appname\n$crunch_summary\n$crunch_body\n$crunch_icon\n$crunch_urgency\x0f" >> /tmp/dunstlog
      #     '';
      #     executable = true;
      #   };
      # };
    };
  };
}