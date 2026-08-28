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
          corner_radius = 12;
          origin = "top-right";
          offset = "16x46";
          width = "(260, 420)";
          height = "(50, 220)";
          progress_bar = true;
          progress_bar_height = 8;
          progress_bar_frame_width = 0;
          progress_bar_min_width = 160;
          progress_bar_max_width = 320;
          progress_bar_corner_radius = 6;
          highlight = "#cba6f7";
          frame_width = 2;
          frame_color = "#cba6f7";
          separator_color = "frame";
          gap_size = 8;
          padding = 14;
          horizontal_padding = 14;
          text_icon_padding = 12;
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
          timeout = 4;
        };

        urgency_normal = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#cba6f7";
          timeout = 6;
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
