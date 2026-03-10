{ config, lib, pkgs, useNixGL ? false, ... }:
let
  cfg = config.system.programs.terminal;
  nixGL = import ../../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  themeSettings = {
    import = [ (pkgs.alacritty-theme + "/dracula.toml") ];
  };
in
{
  config = lib.mkIf (cfg.name == "alacritty") {
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    programs.alacritty = {
      enable = true;
      package = nixGLWrapper pkgs.alacritty;
      settings = {
        window = {
          title = "Terminal";
          position = "None";
          class = {
            instance = "Alacritty";
            general = "Alacritty";
          };
          opacity = 0.95;
          decorations = "full";
          decorations_theme_variant = "None";
          startup_mode = "Windowed";
          dynamic_title = true;
          padding = {
            x = 10;
            y = 10;
          };
          dynamic_padding = false;
          dimensions = {
            columns = 82;
            lines = 24;
          };
          # scrolling = {
          #   history = 10000;
          #   multiplier = 3;
          # };
        };
        font = {
          normal.family = "JetBrainsMono Nerd Font";
          normal.style = "Regular";
          bold.family = "JetBrainsMono Nerd Font";
          bold.style = "Bold";
          italic.family = "JetBrainsMono Nerd Font";
          italic.style = "Italic";
          bold_italic.family = "JetBrainsMono Nerd Font";
          bold_italic.style = "Bold Italic";
          size = 12.0;
          builtin_box_drawing = true;
          offset = {
            x = 0;
            y = 0;
          };
          glyph_offset = {
            x = 0;
            y = 0;
          };
        };
        draw_bold_text_with_bright_colors = true;
        colors = {
          primary = {
            background = "#282a36";
            foreground = "#f8f8f2";
          };
          normal = {
            black = "#000000";
            red = "#ff5555";
            green = "#50fa7b";
            yellow = "#f1fa8c";
            blue = "#caa9fa";
            magenta = "#ff79c6";
            cyan = "#8be9fd";
            white = "#bfbfbf";
          };
          bright = {
            black = "#575b70";
            red = "#ff6e67";
            green = "#5af78e";
            yellow = "#f4f99d";
            blue = "#caa9fa";
            magenta = "#ff92d0";
            cyan = "#9aedfe";
            white = "#e6e6e6";
          };
        };
        selection = {
          semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
          save_to_clipboard = false;
        };
        cursor = {
          style = {
            shape = "Beam";
            blinking = "Always";
          };
          unfocused_hollow = true;
          thickness = 0.15;
          blink_interval = 750;
          blink_timeout = 0;
        };
        live_config_reload = true;
        mouse = {
          hide_when_typing = true;
          bindings = [{
            mouse = "Middle";
            action = "Paste";
          }];
        };
        hints.enabled = [{
          command = "${pkgs.xdg-utils}/bin/xdg-open";
          hyperlinks = true;
          post_processing = true;
          persist = false;
          mouse.enabled = true;
          binding = { key = "U"; mods = "Control|Shift"; };
        }];
      }
      // themeSettings
      ;
      # theme = "Dracula";
      # themePackage = pkgs.alacritty-theme;
    };
  };
}
