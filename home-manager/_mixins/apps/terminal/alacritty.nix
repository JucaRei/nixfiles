{ pkgs, lib ? pkgs.lib, ... }:
# with lib.hm.gvariant;
let
  _ = lib.getExe;
  #   nixGL = import ../../../../lib/nixGL.nix { inherit config pkgs; };
in
{
  # programs.alacritty = {
  # enable = true;
  # package = pkgs.alacritty;
  settings = {
    window = {
      title = "Terminal";
      class = {
        instance = "Alacritty";
        general = "Alacritty";
      };
      padding = {
        x = 15;
        y = 15;
      };
      dimensions = {
        lines = 75;
        columns = 100;
      };

      opacity = 0.7;
    };

    font = {
      normal = {
        # family = "JetbrainsMono Nerd Font";
        # style = "Regular";
        family = "FiraCode Nerd Font Mono";
        style = "Retina";
      };
      # italic = {
      #   family = "FiraCode Nerd Font Mono";
      #   style = "MediumItalic";
      # };
      # bold = {
      #   family = "FiraCode Nerd Font Mono";
      #   style = "Bold";
      # };
      # bold_italic = {
      #   family = "FiraCode Nerd Font Mono";
      #   style = "BoldItalic";
      # };
      size = 11.0;
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
        text = "0xFF261E";
        cursor = "0xFF261E";
      };
      normal = {
        black = "0x0D0D0D";
        red = "0xFF301B";
        green = "0xA0E521";
        yellow = "0xFFC620";
        blue = "0x178AD1";
        magenta = "0x9f7df5";
        cyan = "0x21DEEF";
        white = "0xEBEBEB";
      };
      bright = {
        black = "0x6D7070";
        red = "0xFF4352";
        green = "0xB8E466";
        yellow = "0xFFD750";
        blue = "0x1BA6FA";
        magenta = "0xB978EA";
        cyan = "0x73FBF1";
        white = "0xFEFEF8";
      };
    };
    scrolling = {
      history = 10000;
    };
  };
  # };
}
