{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  cfg = config.desktop.wayland;
  isTraditional = config.desktop.display-servers.backend == "wayland" && cfg.shell == "traditional";
in
{
  options.desktop.wayland.traditional.dunst = {
    enable = mkOption {
      type = bool;
      default = isTraditional;
      description = "Habilitar daemon de notificações Dunst para Wayland (Rice Catppuccin Mocha)";
    };
  };

  config = mkIf (isTraditional && config.desktop.wayland.traditional.dunst.enable) {
    home.packages = with pkgs; [
      libnotify
      dunst
    ];

    services.dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          font = "Inter 10";
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          show_age_threshold = 60;
          word_wrap = "yes";
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";

          # Posicionamento e Dimensões
          width = 350;
          height = 120;
          offset = "20x20";
          origin = "top-right";
          transparency = 10;
          corner_radius = 10;

          # Linha divisória e progresso
          separator_height = 2;
          padding = 12;
          horizontal_padding = 16;
          text_icon_padding = 12;
          frame_width = 2;
          progress_bar = true;
          progress_bar_height = 8;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          progress_bar_corner_radius = 4;

          # Paleta Catppuccin Mocha
          frame_color = "#89b4fa"; # Sapphire / Blue accent
          separator_color = "frame";
          highlight = "#89b4fa";
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
          frame_color = "#89b4fa";
          timeout = 6;
        };

        urgency_critical = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#f38ba8"; # Red
          timeout = 10;
        };
      };
    };
  };
}
