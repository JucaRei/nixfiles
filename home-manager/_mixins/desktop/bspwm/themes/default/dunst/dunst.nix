{pkgs, ...}: {
  home = {
    packages = [pkgs.libnotify]; # Depency
  };
  services = {
    dunst = {
      enable = true;
      iconTheme = {
        name = "Papirus Dark";
        package = pkgs.papirus-icon-theme;
        size = "16x16";
      };
      settings = {
        global = {
          monitor = 0;
          follow = "none";
          width = 300;
          height = 80;
          # origin = "bottom-right";
          origin = "top-right";
          # offset = "50x50";
          offset = "10x48";
          scale = 0;
          notification_limit = 0;
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          indicate_hidden = "yes";
          shrink = "no";
          font = "UbuntuMono Nerd Font Regular 11";
          transparency = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          frame_width = 1;
          frame_color = "c0caf5";
          gap_size = 0;
          separator_color = "frame";
          sort = "yes";
          line_height = 0;
          markup = "full";
          format = ''
            <b>%s</b>
            %b'';
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          min_icon_size = 128;
          max_icon_size = 300;
          icon_theme = "Papirus, Adwaita";
          enable_recursive_icon_lookup = true;
          always_run_scripts = true;
          sticky_history = "yes";
          history_length = 20;
          dmenu = "dmenu -p dunst:";
          browser = "xdg-open";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 15;
          ignore_dbusclose = false;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "context";
          mouse_right_click = "do_action";
        };
        experimental = {per_monitor_dpi = false;};
        urgency_low = {
          background = "#1a1b26";
          foreground = "#c0caf5";
          frame_color = "#c0caf5";
          timeout = 10;
          script = "~/.config/dunst/scripts/sound-normal.sh";
        };
        urgency_normal = {
          background = "#1a1b26";
          foreground = "#c0caf5";
          frame_color = "#c0caf5";
          timeout = 10;
          script = "~/.config/dunst/scripts/sound-normal.sh";
        };
        urgency_critical = {
          background = "#1a1b26";
          foreground = "#db4b4b";
          frame_color = "#f7768e";
          timeout = 0;
          script = "~/.config/dunst/scripts/sound-critical.sh";
        };
        logger = {
          summary = "*";
          script = "~/.config/eww/Main/scripts/logger.zsh";
        };
        spotify = {
          summary = "*";
          script = "~/.scripts/music-art";
        };
        spotify-icon = {
          appname = "Spotify";
          icon = "~/.cache/temp.png";
        };
      };
    };
  };
  xdg = {
    configFile = {
      "dunst/scripts/sound-critical.sh" = {
        text = ''
          #!/usr/bin/env bash
          mpv /usr/share/sounds/Yaru/stereo/battery-low.oga
        '';
        executable = true;
      };
      "dunst/scripts/sound-normal.sh" = {
        text = ''
          #!/usr/bin/env bash
          mpv /usr/share/sounds/Yaru/stereo/message-new-instant.oga
        '';
        executable = true;
      };
      "dunst/scripts/reload" = {
        text = ''
          #!/bin/bash
          pkill dunst
          dunst -config ~/.config/dunst/dunstrc &

          notify-send -u critical "Test message: critical test 1"
          notify-send -u normal "Test message: normal test 2"
          notify-send -u low "Test message: low test 3"
          notify-send -u critical "Test message: critical test 4"
          notify-send -u normal "Test message: normal test 5"
          notify-send -u low "Test message: low test 6"
          notify-send -u critical "Test message: critical test 7"
          notify-send -u normal "Test message: normal test 8"
          notify-send -u low "Test message: low test 9"
        '';
        executable = true;
      };
    };
  };
}
