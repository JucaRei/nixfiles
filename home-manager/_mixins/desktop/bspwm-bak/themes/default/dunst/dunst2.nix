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
          follow = "mouse";
          width = 300;
          height = 80;
          origin = "top-right";
          offset = "10x48";
          corner_radius = 0;
          scale = 0;
          notification_limit = 0;
          progress_bar = true;
          progress_bar_height = 80;
          progress_bar_frame_width = 2;
          progress_bar_min_width = 300;
          progress_bar_max_width = 300;
          indicate_hidden = "yes";
          transparency = 0;
          separator_height = 2;
          padding = 15;
          horizontal_padding = 15;
          text_icon_padding = 0;
          frame_width = 2;
          gap_size = 0;
          separator_color = "frame";
          sort = "yes";
          idle_threshold = 120;
          font = "JetBrains Mono 10";
          line_height = 2;
          markup = "full";
          format = ''
            %s
            %b'';
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          enable_recursive_icon_lookup = true;
          icon_position = "left";
          min_icon_size = 24;
          max_icon_size = 48;
          sticky_history = "yes";
          history_length = 20;
          browser = "xdg-open";
          always_run_script = true;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
          title = "Dunst";
          class = "Dunst";
        };
        urgency_low = {
          timeout = 2;
          background = "#1E2128";
          foreground = "#ABB2BF";
          frame_color = "#292d37";
        };
        urgency_normal = {
          timeout = 5;
          background = "#1E2128";
          foreground = "#ABB2BF";
          frame_color = "#292d37";
        };
        urgency_critical = {
          timeout = 0;
          background = "#1E2128";
          foreground = "#E06B74";
          frame_color = "#E06B74";
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
