{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.dunst;
in
{
  options.desktop.bspwm.dunst = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable dunst notification daemon for bspwm";
    };
  };

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          font = "Inter 10";
          corner_radius = 8;
          origin = "top-right";
          offset = "16x40";
          width = "(250, 400)";
          height = "(50, 200)";
          progress_bar = true;
          progress_bar_height = 6;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          progress_bar_corner_radius = 4;
          frame_width = 2;
          frame_color = "#89b4fa";
          separator_color = "frame";
          gap_size = 6;
          padding = 12;
          horizontal_padding = 12;
          text_icon_padding = 10;
          icon_position = "left";
          min_icon_size = 24;
          max_icon_size = 48;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };

        urgency_low = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#585b70";
          timeout = 5;
        };

        urgency_normal = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#89b4fa";
          timeout = 8;
        };

        urgency_critical = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#f38ba8";
          timeout = 0;
        };
      };
    };
  };
}
