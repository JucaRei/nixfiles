{ pkgs, lib ? pkgs.lib, ... }:

{
  home.packages = with pkgs; [
    (nerdfonts.override
      {
        fonts = [
          # Characters
          "JetBrainsMono"
          # "Monoid"
        ];
      })
  ];
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      window = {
        title = "Terminal";
        position = "None";
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
        # opacity = 0.7;
        opacity = 0.95;

        # Window decorations
        #
        # Values for `decorations`:
        #     - full: Borders and title bar
        #     - none: Neither borders nor title bar
        #
        # Values for `decorations` (macOS only):
        #     - transparent: Title bar, transparent background and title bar buttons
        #     - buttonless: Title bar, transparent background, but no title bar buttons
        decorations = "full";
        decorations_theme_variant = "None";

        # When true, alacritty starts maximized.
        startup_mode = "Windowed"; # Maximized
        dynamic_title = true;

        ## Background opacity
        # background_opacity: 1.0

        ## Blank space added around the window in pixels.
        padding = {
          x = 10;
          y = 10;
        };

        # Spread additional padding evenly around the terminal content.
        dynamic_padding = false;

        ## Number of lines/columns (not pixels) in the terminal.
        dimensions = {
          columns = 82;
          lines = 24;
        };
      };

      ## SCROLLING ------------------------------------------------------
      scrolling = {
        # Maximum number of lines in the scrollback buffer.
        # Specifying '0' will disable scrolling.
        history = 10000;

        # Number of lines the viewport will move for every line scrolled when
        # scrollback is enabled (history > 0).
        multiplier = 3;
      };

      # Spaces per Tab (changes require restart)
      #
      # This setting defines the width of a tab in cells.
      #
      # Some applications, like Emacs, rely on knowing about the width of a tab.
      # To prevent unexpected behavior in these applications, it's also required to
      # change the `it` value in terminfo when altering this setting.
      # tabspaces: 8

      # Thin stroke font rendering (macOS only)
      #
      # Thin strokes are suitable for retina displays, but for non-retina screens
      # it is recommended to set `use_thin_strokes` to `false`
      #
      # macOS >= 10.14.x:
      #
      # If the font quality on non-retina display looks bad then set
      # `use_thin_strokes` to `true` and enable font smoothing by running the
      # following command:
      #   `defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO`
      #
      # This is a global setting and will require a log out or restart to take
      # effect.
      # use_thin_strokes = true;

      ## All key-value pairs in the [env] section will be added as environment variables for any process spawned
      ## by Alacritty, including its shell. Some entries may override variables set by alacritty itself.
      env = {
        TERM = "xterm-256color"; #"alacritty";
        WINIT_X11_SCALE_FACTOR = "1.0";
      };

      ## BELL -----------------------------------------------------------
      # Visual Bell
      #
      # Any time the BEL code is received, Alacritty "rings" the visual bell. Once
      # rung, the terminal background will be set to white and transition back to the
      # default background color. You can control the rate of this transition by
      # setting the `duration` property (represented in milliseconds). You can also
      # configure the transition function by setting the `animation` property.
      #
      # Values for `animation`:
      #   - Ease
      #   - EaseOut
      #   - EaseOutSine
      #   - EaseOutQuad
      #   - EaseOutCubic
      #   - EaseOutQuart
      #   - EaseOutQuint
      #   - EaseOutExpo
      #   - EaseOutCirc
      #   - Linear
      #
      # Specifying a `duration` of `0` will disable the visual bell.
      bell = {
        animation = "EaseOutExpo"; # "Linear";
        duration = 0; # 20;
        color = "0xffffff";
        command = {
          program = "paplay";
          args = [ "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/dialog-error.oga" ];
        };
      };

      ## SELECTION ------------------------------------------------------
      selection = {
        # When set to `true`, selected text will be copied to the primary clipboard.
        save_to_clipboard = true;
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";
      };

      # url = {
      # URL launcher
      #
      # This program is executed when clicking on a text which is recognized as a URL.
      # The URL is always added to the command as the last parameter.
      #
      # When set to `None`, URL launching will be disabled completely.
      #
      # Default:
      #   - (macOS) open
      #   - (Linux) xdg-open
      #   - (Windows) explorer
      #launcher: xdg-open

      # URL modifiers
      #
      # These are the modifiers that need to be held down for opening URLs when clicking
      # on them. The available modifiers are documented in the key binding section.
      #   modifiers = "None";
      # };

      font = {
        normal = {
          # family = "JetbrainsMonoNL NFM";
          # style = "SemiBold";
          family = "JetbrainsMono Nerd Font";
          style = "Regular";
          # family = "FiraCode Nerd Font Mono";
          # style = "Retina";
          # family = "Monoid Nerd Font Mono";
          # style = "Retina";
        };
        italic = {
          family = "JetbrainsMono Nerd Font";
          #   family = "FiraCode Nerd Font Mono";
          style = "Medium Italic";
        };
        bold = {
          family = "JetbrainsMono Nerd Font";
          #   family = "FiraCode Nerd Font Mono";
          style = "Bold";
        };
        bold_italic = {
          family = "JetbrainsMono Nerd Font";
          #   family = "FiraCode Nerd Font Mono";
          style = "Bold Italic";
        };

        ## Offset is the extra space around each character.
        ## 'y' can be thought of as modifying the line spacing, and 'x' as modifying the letter spacing.
        offset = {
          x = 0;
          y = 0;
        };

        ## Glyph offset determines the locations of the glyphs within their cells with the default being at the bottom.
        ## Increasing 'x' moves the glyph to the right, increasing 'y' moves the glyph upward.
        glyph_offset = {
          x = 0;
          y = 0;
        };

        size = 10.0;

        ## When true, Alacritty will use a custom built-in font for box drawing characters and powerline symbols.
        builtin_box_drawing = true;
      };

      # If `true`, bold text is drawn using the bright color variants.
      # draw_bold_text_with_bright_colors = true; #deprecated
      live_config_reload = true;
      ipc_socket = true;

      # window_opacity = 0.3;

      colors = {
        draw_bold_text_with_bright_colors = true;
        primary = {
          # background = "0x000000";
          # foreground = "0xEBEBEB";
          background = "#2E3440";
          foreground = "#D8DEE9";
        };
        cursor = {
          # text = "0xFF261E";
          # cursor = "0xFF261E";
          text = "#24273A"; # base
          cursor = "#B7BDF8"; # lavender
        };
        normal = {
          # black = "#494D64"; # surface1
          # red = "#ED8796"; # red
          # green = "#A6DA95"; # green
          # yellow = "#EED49F"; # yellow
          # blue = "#8AADF4"; # blue
          # magenta = "#F5BDE6"; # pink
          # cyan = "#8BD5CA"; # teal
          # white = "#B8C0E0"; # subtext1

          black = "#3B4252";
          red = "#BF616A";
          green = "#A3BE8C";
          yellow = "#EBCB8B";
          blue = "#81A1C1";
          magenta = "#B48EAD";
          cyan = "#88C0D0";
          white = "#E5E9F0";
        };
        bright = {
          # black = "#5B6078"; # surface2
          # red = "#ED8796"; # red
          # green = "#A6DA95"; # green
          # yellow = "#EED49F"; # yellow
          # blue = "#8AADF4"; # blue
          # magenta = "#F5BDE6"; # pink
          # cyan = "#8BD5CA"; # teal
          # white = "#A5ADCB"; # subtext0

          black = "#4C566A";
          red = "#BF616A";
          green = "#A3BE8C";
          yellow = "#EBCB8B";
          blue = "#81A1C1";
          magenta = "#B48EAD";
          cyan = "#8FBCBB";
          white = "#ECEFF4";
        };

        # Dim colors
        dim = {
          black = "#494d64"; #surface1
          red = "#ED8796"; # red
          green = "#A6DA95"; # green
          yellow = "#EED49F"; # yellow
          blue = "#8AADF4"; # blue
          magenta = "#F5BDE6"; # pink
          cyan = "#8BD5CA"; # teal
          white = "#B8C0E0"; # subtext1
        };

        indexed_colors = [
          {
            index = 16;
            color = "#F5A97F";
          }
          {
            index = 17;
            color = "#F4DBD6";
          }
        ];

        # Search colors
        search = {
          matches = {
            foreground = "#24273A"; # base
            background = "#A5ADCB"; # subtext0
            # focused_match = {
            #   foreground = "#24273A"; # base
            #   background = "#A6DA95"; # green
            # };
            # footer_bar = {
            #   foreground = "#24273A"; # base
            #   background = "#A5ADCB"; # subtext0
            # };
          };
        };

        # Keyboard regex hints
        hints = {
          start = {
            foreground = "#24273A"; # base
            background = "#EED49F"; # yellow
          };
          end = {
            foreground = "#24273A"; # base
            background = "#A5ADCB"; # subtext0
          };
        };

        # Selection colors
        selection = {
          text = "#24273A"; # base
          background = "#F4DBD6"; # rosewater
        };
      };

      ## CURSOR ---------------------------------------------------------
      cursor = {
        vi_mode_style = "None";
        blink_interval = 750;
        blink_timeout = 5;
        unfocused_hollow = false;
        thickness = 0.15;

        # Cursor style
        #
        # Values for `style`:
        #   - ▇ Block
        #   - _ Underline
        #   - | Beam
        style = {
          shape = "Block";
          blinking = "On";
        };
      };

      ## MOUSE ----------------------------------------------------------
      mouse = {
        # Click settings
        #
        # The `double_click` and `triple_click` settings control the time
        # alacritty should wait for accepting multiple clicks as one double
        # or triple click.
        # double_click = { threshold = 300; };
        # triple_click = { threshold = 300; };
        hide_when_typing = false;
      };

      # Mouse bindings
      #
      # Available fields:
      #   - mouse
      #   - action
      #   - mods (optional)
      #
      # Values for `mouse`:
      #   - Middle
      #   - Left
      #   - Right
      #   - Numeric identifier such as `5`
      #
      # All available `mods` and `action` values are documented in the key binding
      # section.
      # mouse_bindings = {
      #   mouse = "Middle";
      #   action = "PasteSelection";
      # };


      ## HINTS ----------------------------------------------------------
      hints.enabled = [{
        command = "${pkgs.xdg-utils}/bin/xdg-open";
        hyperlinks = true;
        post_processing = true;
        persist = false;
        mouse.enabled = true;
        binding = { key = "U"; mods = "Control|Shift"; };
        # regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\u0000-\u001F\u007F-\u009F<>\'\\s{-}\\^⟨⟩‘]+";
      }];

      # Shell
      #
      # You can set `shell.program` to the path of your favorite shell, e.g. `/bin/fish`.
      # Entries in `shell.args` are passed unmodified as arguments to the shell.
      #
      # Default:
      #   - (Linux/macOS) /bin/bash --login
      #   - (Windows) powershell
      #shell:
      #  program: /bin/bash
      #  args:
      #    - --login

      # Windows 10 ConPTY backend (Windows only)
      #
      # This will enable better color support and may resolve other issues,
      # however this API and its implementation is still young and so is
      # disabled by default, as stability may not be as good as the winpty
      # backend.
      #
      # Alacritty will fall back to the WinPTY automatically if the ConPTY
      # backend cannot be initialized.
      # enable_experimental_conpty_backend = false;

      # Send ESC (\x1b) before characters when alt is pressed.
      # alt_send_esc = true;

      ## DEBUG ----------------------------------------------------------
      # debug = {
      #   render_timer = false;
      #   persistent_logging = false;
      #   log_level = "Warn";
      #   renderer = "None";
      #   print_events = false;
      #   highlight_damage = false;
      #   prefer_egl = false;
      # };
    };
  };
}
