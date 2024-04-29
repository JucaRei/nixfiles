{ pkgs, lib ? pkgs.lib, ... }:

{
  home.packages = with pkgs; [
    (nerdfonts.override
      {
        fonts = [
          # Characters
          "JetBrainsMono"
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
        decorations = "full";
        decorations_theme_variant = "None";
        startup_mode = "Windowed";
        dynamic_title = true;

        ## Background opacity
        # background_opacity: 1.0
      };


      ## Number of lines/columns (not pixels) in the terminal.
      window.dimensions = {
        columns = 82;
        lines = 24;
      };

      ## Blank space added around the window in pixels.
      window.padding = {
        x = 10;
        y = 10;
      };

      ## SCROLLING ------------------------------------------------------
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      ## All key-value pairs in the [env] section will be added as environment variables for any process spawned
      ## by Alacritty, including its shell. Some entries may override variables set by alacritty itself.
      env = {
        TERM = "alacritty";
        WINIT_X11_SCALE_FACTOR = "1.0";
      };

      ## BELL -----------------------------------------------------------
      bell = {
        animation = "Linear";
        duration = 20;
        command = {
          program = "paplay";
          args = [ "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/dialog-error.oga" ];
        };
      };

      ## SELECTION ------------------------------------------------------
      selection = {
        save_to_clipboard = true;
      };

      font = {
        normal = {
          family = "JetbrainsMono Nerd Font";
          style = "Regular";
          # family = "FiraCode Nerd Font Mono";
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

        size = 11.0;

        ## When true, Alacritty will use a custom built-in font for box drawing characters and powerline symbols.
        builtin_box_drawing = true;
      };

      draw_bold_text_with_bright_colors = true;
      live_config_reload = true;
      ipc_socket = true;

      window_opacity = 0.3;

      colors = {
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
            focused_match = {
              foreground = "#24273A"; # base
              background = "#A6DA95"; # green
            };
            footer_bar = {
              foreground = "#24273A"; # base
              background = "#A5ADCB"; # subtext0
            };
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
      };
      cursor.style = {
        shape = "Block";
        blinking = "On";
      };

      ## MOUSE ----------------------------------------------------------
      mouse = {
        hide_when_typing = false;
      };

      ## HINTS ----------------------------------------------------------
      hints.enabled = [{
        command = "${pkgs.xdg-utils}/bin/xdg-open";
        hyperlinks = true;
        post_processing = true;
        persist = false;
        mouse.enabled = true;
        binding = { key = "U"; mods = "Control|Shift"; };
        regex = ''
          (ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\u0000-\u001F\u007F-\u009F<>\'\\s{-}\\^⟨⟩‘]+
        '';
      }];

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
