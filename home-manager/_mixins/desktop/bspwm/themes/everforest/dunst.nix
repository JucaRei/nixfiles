{ pkgs, ... }: {
  home = {
    packages = [ pkgs.libnotify ];
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
          width = "(111, 444)";
          height = 222;
          origin = "top-right";
          offset = "15x55";
          scale = 0;
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          indicate_hidden = "yes";
          transparency = 0;
          separator_height = 5;
          padding = 15;
          horizontal_padding = 15;
          text_icon_padding = 0;
          frame_width = 0;
          frame_color = "#16161E";
          separator_color = "frame";
          sort = "yes";
          font = "Iosevka Medium Italic 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "center";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "yes";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "no";
          icon_position = "left";
          icon_size = 48;
          max_icon_size = 80;
          #  icon_path = /usr/share/icons/Papirus-Dark/48x48/status/:/usr/share/icons/Papirus-Dark/48x48/devices/:/usr/share/icons/Papirus-Dark/48x48/apps
          stick_history = "yes";
          history_lenght = 20;
          dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst:";
          browser = "${pkgs.firefox}/bin/firefox -new-tab";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 5;
          ignore_dbusclose = false;
          force_xwayland = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };
        experimental = {
          per_monitor_dpi = false;
        };
        log_notifs = {
          script = "~/.config/dunst/scripts/dunst_logger.sh";
        };
        urgency_low = {
          background = "#21222C";
          foreground = "#f8f8f2";
          highlight = "#f8f8f2";
          timeout = 6;
        };
        urgency_normal = {
          background = "#21222C";
          foreground = "#f8f8f2";
          highlight = "#f8f8f2";
          highlight-background = "#21222C";
          timeout = 6;
        };
        urgency_critical = {
          background = "#21222C";
          foreground = "#f8f8f2";
          highlight = "#f8f8f2";
          timeout = 10;
        };
      };
    };
  };
  home = {
    file = {
      ".config/dunst/scripts/dunst_logger.sh" = {
        text = ''
          #!/usr/bin/bash
          #set -euo pipefail

          # Because certain programs like to insert their own newlines and fuck up my format (im looking at you thunderbird)
          # we need to crunch each input to ensure that each component is its own line in the log file
          crunch_appname=$(echo "$1" | sed '/^$/d')
          crunch_summary=$(echo "$2" | sed '/^$/d' | xargs)
          crunch_body=$(echo "$3" | sed '/^$/d' | xargs)
          crunch_icon=$(echo "$4" | sed '/^$/d')
          crunch_urgency=$(echo "$5" | sed '/^$/d')
          timestamp=$(date +"%I:%M %p")

          # filter stuff ans add custom icons if you want

          # e.g.
          # notify-send -u urgency "summary" "body" -i "icon"
          #
          # this will give
          # app-name - notif-send
          # urgency - upgency
          # summary - summary
          # body - body
          # icon - icon

          # Rules for notifs that send their icons over the wire (w/o an actual path)
          if [[ "$crunch_appname" == "Spotify" ]]; then
              random_name=$(mktemp --suffix ".png")
              artlink=$(playerctl metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')
              curl -s "$artlink" -o "$random_name"
              crunch_icon=$random_name
          elif [[ "$crunch_appname" == "VLC media player" ]]; then
              crunch_icon="vlc"
          elif [[ "$crunch_appname" == "Calendar" ]] || [[ "$crunch_appname" == "Volume" ]] || [[ "$crunch_appname" == "Brightness" ]] || [[ "$crunch_appname" == "notify-send" ]]; then
              exit 0
          fi

          echo -en "$timestamp\n$crunch_urgency\n$crunch_icon\n$crunch_body\n$crunch_summary\n$crunch_appname\n" >>/tmp/dunstlog

          #echo -en "$crunch_appname\n$crunch_summary\n$crunch_body\n$crunch_icon\n$crunch_urgency\x0f" >> /tmp/dunstlog
        '';
        executable = true;
      };
    };
  };
}
