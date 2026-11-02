{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.shared.rofi;
  rofiPkg = if cfg.backend == "wayland" then pkgs.rofi-wayland else pkgs.rofi;

  hyprCliphist = pkgs.writeShellScriptBin "hypr-cliphist" ''
    ${pkgs.cliphist}/bin/cliphist list | ${rofiPkg}/bin/rofi -dmenu -p " 󰅌 Clipboard " -theme-str 'window {width: 700px;}' | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in
{
  options.desktop.shared.rofi = {
    enable = lib.my.mkBool false "Enable shared rofi application launcher for desktop environments (BSPWM, DWM, Hyprland, etc.)";

    backend =
      lib.my.mkEnum
        [
          "x11"
          "wayland"
        ]
        (if config.desktop.display-servers.backend == "wayland" then "wayland" else "x11")
        "Rofi backend package (x11 -> pkgs.rofi, wayland -> pkgs.rofi-wayland)";
  };

  config = mkIf cfg.enable {
    home.packages = lib.optional (cfg.backend == "wayland") hyprCliphist;

    programs.rofi = {
      enable = true;
      package = rofiPkg;
      font = "Inter 11";
      terminal = config.system.programs.terminal.activeCommand or "terminal";
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
          c = config.desktop.theme.colors;
          isWayland = cfg.backend == "wayland";
        in
        {
          "*" = {
            bg-col = mkLiteral c.bg;
            bg-col-light = mkLiteral (if isWayland then c.bgDark else c.bgAlt);
            border-col = mkLiteral c.accent;
            selected-col = mkLiteral (if isWayland then c.surface else c.surfaceAlt);
            blue = mkLiteral c.accent;
            fg-col = mkLiteral c.fg;
            fg-col2 = mkLiteral c.red;
            grey = mkLiteral (if isWayland then c.fgMuted else c.fgSubtle);
            width = mkLiteral (if isWayland then "620" else "600");
          };

          "element-text, element-icon , mode-switcher" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };

          "window" = {
            height = mkLiteral (if isWayland then "420px" else "400px");
            border = mkLiteral "2px";
            border-color = mkLiteral "@border-col";
            border-radius = mkLiteral "16px";
            background-color = mkLiteral "@bg-col";
          };

          "mainbox" = {
            background-color = mkLiteral "@bg-col";
            padding = mkLiteral (if isWayland then "12px" else "10px");
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
            placeholder = if isWayland then "Pesquisar ou executar..." else "Pesquisar...";
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
