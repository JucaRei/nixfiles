# { pkgs, ... }:
# let
#   browser = pkgs.dolphin;
# in
# {
#   services = {
#     dunst = {
#       enable = true;
#       settings = {
#         global = {
#           monitor = 0;
#           follow = "none";
#           width = 300;
#           height = "(0,300)";
#           origin = "top-center";
#           offset = "0x30";
#           scale = 0;
#           notification_limit = 20;
#           progress_bar = "true";
#           progress_bar_height = 10;
#           progress_bar_frame_width = 1;
#           progress_bar_min_width = 150;
#           progress_bar_max_width = 300;
#           progress_bar_corner_radius = 10;
#           icon_corner_radius = 0;
#           indicate_hidden = "yes";
#           transparency = 30;
#           separator_height = 2;
#           padding = 8;
#           horizontal_padding = 8;
#           text_icon_padding = 0;
#           frame_width = 3;
#           frame_color = "#ffffff";
#           gap_size = 0;
#           separator_color = "frame";
#           sort = "yes";
#           font = "Fira Sans Semibold 11";
#           line_height = 3;
#           markup = "full";
#           format = "<b>%s</b>\n%b";
#           alignment = "left";
#           vertical_alignment = "center";
#           show_age_threshold = 60;
#           ellipsize = "middle";
#           ignore_newline = "no";
#           stack_duplicates = true;
#           hide_duplicate_count = false;
#           show_indicators = "yes";
#           enable_recursive_icon_lookup = "true";
#           icon_position = "left";
#           mix_icon_size = 32;
#           max_icon_size = 128;
#           # icon_path = "icons/${pkgs.adwaita-qt6}/status:${pkgs.adwaita-qt6}/share/icons/gnome/16x16/devices/";
#           stick_history = "yes";
#           history_length = 20;
#           ## Misc
#           dmenu = "${pkgs.dmenu} -p dunst:";
#           browser = "xdg-open";
#           always_run_script = true;
#           title = "Dunst";
#           class = "Dunst";
#           corner_radius = 10;
#           ignore_dbusclose = false;
#           force_xwayland = false;
#           force_xinerame = false;
#           mouse_left_click = "close_current";
#           mouse_middle_click = "do_action, close_current";
#           mouse_right_click = "close_all";
#         };
#         experimental = {
#           per_monitor_dpi = false;
#         };
#         urgency_low = {
#           background = "#00000070";
#           foreground = "#888888";
#           timeout = 6;
#         };
#         urgency_normal = {
#           background = "#00000070";
#           foreground = "#ffffff";
#           timeout = 6;
#         };
#         urgency_critical = {
#           background = "#90000070";
#           foreground = "#ffffff";
#           frame_color = "#ffffff";
#           timeout = 6;
#         };
#       };
#       iconTheme = {
#         package = pkgs.adwaita-qt6;
#         name = "Adwaita";
#         size = "16x16";
#       };
#     };
#   };
# }

{ pkgs, ... }: {
  services.dunst = {
    enable = true;
    package = pkgs.dunst.overrideAttrs (_: {
      src = pkgs.fetchFromGitHub {
        owner = "sioodmy";
        repo = "dunst";
        rev = "6477864bd870dc74f9cf76bb539ef89051554525";
        sha256 = "FCoGrYipNOZRvee6Ks5PQB5y2IvN+ptCAfNuLXcD8Sc=";
      };
    });
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders;
      name = "Papirus";
    };
    settings = {
      global = {
        frame_color = "#f4b8e495";
        separator_color = "#f4b8e4";
        width = 220;
        height = 280;
        offset = "0x15";
        font = "Lexend 12";
        corner_radius = 10;
        origin = "top-center";
        notification_limit = 3;
        idle_threshold = 120;
        ignore_newline = "no";
        mouse_left_click = "close_current";
        mouse_right_click = "close_all";
        sticky_history = "yes";
        history_length = 20;
        show_age_threshold = 60;
        ellipsize = "middle";
        padding = 10;
        always_run_script = true;
        frame_width = 2;
        transparency = 10;
        progress_bar = true;
        progress_bar_frame_width = 0;
        highlight = "#f4b8e4";
      };
      fullscreen_delay_everything.fullscreen = "delay";
      urgency_low = {
        background = "#1e1e2e83";
        foreground = "#c6d0f5";
        timeout = 5;
      };
      urgency_normal = {
        background = "#1e1e2e83";
        foreground = "#c6d0f5";
        timeout = 6;
      };
      urgency_critical = {
        background = "#1e1e2e83";
        foreground = "#c6d0f5";
        frame_color = "#ea999c80";
        timeout = 0;
      };
    };
  };
  # Regularly check battery status
  systemd.user.services = {
    battery_monitor = {
      Unit = {
        Description = ''
          Regularly check the battery status and send a notification when it discharges
          below certain thresholds.
          Implemented by calling the `acpi` program regularly. This is the simpler and
          safer approach because the battery might not send discharging events.
        '';
      };
      Install = {
        # wants = [ "display-manager.service" ];
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        # bat0 | bat1 | bat2
        ExecStart = "${pkgs.writeShellScript "battery_monitor.sh " ''
          #!/run/current-system/sw/bin/bash
          prev_val=100
          check () { [[ $1 -ge $val ]] && [[ $1 -lt $prev_val ]]; }
          notify () {
            ${pkgs.libnotify}/bin/notify-send -a Battery "$@" \
              -h "int:value:$val" "Discharging" "$val%, $remaining"
          }
          while true; do
            IFS=: read _ bat1 < <(${pkgs.acpi}/bin/acpi -b)
            IFS=\ , read status val remaining <<<"$bat1"
            val=''${val%\%}
            if [[ $status = Discharging ]]; then
              echo "$val%, $remaining"
              if check 30 || check 25 || check 20; then notify
              elif check 15 || [[ $val -le 10 ]]; then notify -u critical
              fi
            fi
            prev_val=$val
            # Sleep longer when battery is high to save CPU
            if [[ $val -gt 30 ]]; then ${pkgs.coreutils}/bin/sleep 10m; elif [[ $val -ge 20 ]]; then ${pkgs.coreutils}/bin/sleep 5m; else ${pkgs.coreutils}/bin/sleep 1m; fi
          done
        ''}";
      };
    };
  };
}
