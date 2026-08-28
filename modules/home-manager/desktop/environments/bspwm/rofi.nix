{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.rofi;
in
{
  options.desktop.bspwm.rofi = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable rofi application launcher for bspwm";
    };
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      font = "Inter 11";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      extraConfig = {
        modi = "drun,run,window";
        show-icons = true;
        icon-theme = "Papirus-Dark";
        drun-display-format = "{name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-window = " 󱂬  Window ";
        sidebar-mode = true;
      };
      theme =
        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            bg-col = mkLiteral "#1e1e2e";
            bg-col-light = mkLiteral "#181825";
            border-col = mkLiteral "#cba6f7";
            selected-col = mkLiteral "#313244";
            blue = mkLiteral "#cba6f7"; # Catppuccin Mauve (Hyprland vibe)
            fg-col = mkLiteral "#cdd6f4";
            fg-col2 = mkLiteral "#f38ba8";
            grey = mkLiteral "#6c7086";
            width = mkLiteral "600";
          };

          "element-text, element-icon , mode-switcher" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };

          "window" = {
            height = mkLiteral "400px";
            border = mkLiteral "2px";
            border-color = mkLiteral "@border-col";
            border-radius = mkLiteral "16px";
            background-color = mkLiteral "@bg-col";
          };

          "mainbox" = {
            background-color = mkLiteral "@bg-col";
            padding = mkLiteral "10px";
          };

          "inputbar" = {
            children = map mkLiteral [
              "prompt"
              "entry"
            ];
            background-color = mkLiteral "@bg-col-light";
            border-radius = mkLiteral "10px";
            padding = mkLiteral "4px 8px";
            margin = mkLiteral "8px 12px 0px 12px";
          };

          "prompt" = {
            background-color = mkLiteral "@blue";
            padding = mkLiteral "6px 12px";
            text-color = mkLiteral "@bg-col-light";
            border-radius = mkLiteral "8px";
            margin = mkLiteral "4px 0px 4px 4px";
          };

          "textbox-prompt-colon" = {
            expand = false;
            str = ":";
          };

          "entry" = {
            padding = mkLiteral "8px";
            margin = mkLiteral "0px 0px 0px 6px";
            text-color = mkLiteral "@fg-col";
            background-color = mkLiteral "transparent";
            placeholder = "Pesquisar...";
            placeholder-color = mkLiteral "@grey";
          };

          "listview" = {
            border = mkLiteral "0px";
            padding = mkLiteral "8px 0px 0px";
            margin = mkLiteral "10px 12px 0px 12px";
            columns = 2;
            lines = 6;
            background-color = mkLiteral "@bg-col";
          };

          "element" = {
            padding = mkLiteral "8px 12px";
            background-color = mkLiteral "@bg-col";
            text-color = mkLiteral "@fg-col";
            border-radius = mkLiteral "10px";
          };

          "element-icon" = {
            size = mkLiteral "24px";
            margin = mkLiteral "0px 10px 0px 0px";
          };

          "element selected" = {
            background-color = mkLiteral "@selected-col";
            text-color = mkLiteral "@blue";
          };

          "mode-switcher" = {
            spacing = 0;
          };

          "button" = {
            padding = mkLiteral "10px";
            background-color = mkLiteral "@bg-col-light";
            text-color = mkLiteral "@grey";
            vertical-align = mkLiteral "0.5";
            horizontal-align = mkLiteral "0.5";
          };

          "button selected" = {
            background-color = mkLiteral "@bg-col";
            text-color = mkLiteral "@blue";
          };

          "message" = {
            background-color = mkLiteral "@bg-col-light";
            margin = mkLiteral "2px";
            padding = mkLiteral "2px";
            border-radius = mkLiteral "5px";
          };

          "textbox" = {
            padding = mkLiteral "6px";
            margin = mkLiteral "20px 0px 0px 20px";
            text-color = mkLiteral "@blue";
            background-color = mkLiteral "@bg-col-light";
          };
        };
    };
  };
}
