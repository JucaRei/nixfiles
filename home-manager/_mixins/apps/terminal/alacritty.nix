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
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
        padding = {
          x = 10;
          y = 10;
        };
        dimensions = {
          lines = 35;
          columns = 110;
        };
        # opacity = 0.7;
        opacity = 0.95;
        decorations = "full";
        startup_mode = "Windowed";
        dynamic_title = true;

        ## Background opacity
        # background_opacity: 1.0
      };

      ## Set environment variables
      env = {
        TERM = "alacritty";
        WINIT_X11_SCALE_FACTOR = "1.0";
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
        size = 12.0;
      };

      draw_bold_text_with_bright_colors = true;
      live_config_reload = true;

      window_opacity = 0.3;

      colors = {
        primary = {
          background = "0x000000";
          foreground = "0xEBEBEB";
        };
        cursor = {
          # text = "0xFF261E";
          # cursor = "0xFF261E";
          text = "#24273A"; # base
          cursor = "#B7BDF8"; # lavender
        };
        normal = {
          black = "#494D64"; # surface1
          red = "#ED8796"; # red
          green = "#A6DA95"; # green
          yellow = "#EED49F"; # yellow
          blue = "#8AADF4"; # blue
          magenta = "#F5BDE6"; # pink
          cyan = "#8BD5CA"; # teal
          white = "#B8C0E0"; # subtext1
        };
        bright = {
          black = "#5B6078"; # surface2
          red = "#ED8796"; # red
          green = "#A6DA95"; # green
          yellow = "#EED49F"; # yellow
          blue = "#8AADF4"; # blue
          magenta = "#F5BDE6"; # pink
          cyan = "#8BD5CA"; # teal
          white = "#A5ADCB"; # subtext0
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

      ## scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      ## Cursor
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 500;
        unfocused_hollow = false;
      };
    };
  };
}
