# What it is: Waybar status bar for Wayland environments (MangoWM, Hyprland, Sway).
# How to enable: Set `desktop.wayland.enable = true;`.
# Example: desktop.wayland.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.wayland;
  c = config.desktop.theme.colors;
  isTraditional = config.desktop.display-servers.backend == "wayland" && cfg.shell == "traditional";
  isMango = cfg.compositor == "mangowm" || (config.desktop.mangowm.enable or false);

  writeShellApp =
    args:
    pkgs.writeShellApplication (
      args
      // {
        bashOptions = args.bashOptions or [ ];
        excludeShellChecks = (args.excludeShellChecks or [ ]) ++ [
          "SC1091"
          "SC2001"
          "SC2005"
          "SC2012"
          "SC2015"
          "SC2016"
          "SC2028"
          "SC2034"
          "SC2046"
          "SC2059"
          "SC2076"
          "SC2086"
          "SC2089"
          "SC2090"
          "SC2119"
          "SC2120"
          "SC2126"
          "SC2154"
          "SC2155"
          "SC2181"
          "SC2183"
          "SC2206"
          "SC2207"
          "SC2221"
          "SC2222"
        ];
      }
    );

  # Scripts utilitários extraídos e validados hermeticamente
  powerMenu = writeShellApp {
    name = "session-power-menu";
    runtimeInputs = [
      pkgs.rofi
      pkgs.hyprlock
      pkgs.systemd
    ];
    text = builtins.readFile ./scripts/session-power-menu.sh;
  };

  powerMenuHyprland = writeShellApp {
    name = "hyprland-power-menu";
    runtimeInputs = [ powerMenu ];
    text = ''exec session-power-menu "$@"'';
  };

  rofiWifiMenu = writeShellApp {
    name = "rofi-wifi-menu";
    runtimeInputs = [
      pkgs.rofi
      pkgs.libnotify
      pkgs.networkmanager
    ];
    text = builtins.readFile ./scripts/rofi-wifi-menu.sh;
  };

  mangoLayoutSwitcher = writeShellApp {
    name = "mango-layout-switcher";
    runtimeInputs = [
      pkgs.procps
      pkgs.jq
    ];
    text = builtins.readFile ./scripts/mango-layout-switcher.sh;
  };

  mangoLayoutPicker = writeShellApp {
    name = "mango-layout-picker";
    runtimeInputs = [
      pkgs.rofi
      pkgs.procps
    ];
    text = builtins.readFile ./scripts/mango-layout-picker.sh;
  };

  mangoWindowTitle = writeShellApp {
    name = "mango-window-title";
    runtimeInputs = [
      pkgs.jq
      pkgs.coreutils
      pkgs.gnused
    ];
    text = builtins.readFile ./scripts/mango-window-title.sh;
  };

in
{
  options.desktop = {
    wayland.traditional.waybar.enable = lib.my.mkBool isTraditional "Habilitar waybar moderna no shell tradicional Wayland";

    # Retrocompatibilidade
    hyprland.waybar.enable = lib.my.mkBool config.desktop.wayland.traditional.waybar.enable "Opção de retrocompatibilidade para waybar";

    mangowm.waybar.enable = lib.my.mkBool config.desktop.wayland.traditional.waybar.enable "Opção de retrocompatibilidade para waybar";
  };

  config = mkIf (isTraditional && config.desktop.wayland.traditional.waybar.enable) {
    home.packages = [
      powerMenu
      powerMenuHyprland
      rofiWifiMenu
      mangoLayoutSwitcher
      mangoLayoutPicker
      mangoWindowTitle
    ];

    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      systemd.enable = false;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 34;
          margin-top = 6;
          margin-left = 10;
          margin-right = 10;
          spacing = 6;

          modules-left =
            if isMango then
              [
                "custom/launcher"
                "ext/workspaces"
                "custom/layout"
                "custom/window"
              ]
            else
              [
                "custom/launcher"
                "hyprland/workspaces"
                "hyprland/window"
              ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "cpu"
            "memory"
            "backlight"
            "pulseaudio"
            "network"
            "battery"
            "tray"
            "custom/power"
          ];

          "custom/launcher" = {
            format = "󱄅";
            on-click = "${pkgs.rofi}/bin/rofi -show drun";
            tooltip = false;
          };

          # Workspaces para MangoWM
          "ext/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "󰮯";
              "2" = "󰊠";
              "3" = "󰀦";
              "4" = "󰅩";
              "5" = "󰈹";
              "6" = "󰝚";
              "7" = "󰒱";
              "8" = "󰇮";
              "9" = "󰢹";
              "urgent" = "󰀨";
              "default" = "󰮯";
            };
            sort-by-id = true;
            on-click = "activate";
          };

          # Workspaces para Hyprland
          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            format-icons = {
              "1" = "󰮯";
              "2" = "󰊠";
              "3" = "󰀦";
              "4" = "󰅩";
              "5" = "󰈹";
              "6" = "󰝚";
              "7" = "󰒱";
              "8" = "󰇮";
              "9" = "󰢹";
              "urgent" = "󰀨";
              "default" = "󰮯";
            };
          };

          "custom/layout" = {
            exec = "${mangoLayoutSwitcher}/bin/mango-layout-switcher";
            return-type = "json";
            interval = 2;
            signal = 8;
            on-click = "${mangoLayoutPicker}/bin/mango-layout-picker";
            tooltip = true;
          };

          "custom/window" = {
            exec = "${mangoWindowTitle}/bin/mango-window-title";
            return-type = "json";
            interval = 1;
            max-length = 38;
            tooltip = true;
          };

          "hyprland/window" = {
            format = "{title}";
            max-length = 40;
            separate-outputs = true;
            rewrite = {
              "(.*) — Mozilla Firefox" = "󰈹 $1";
              "(.*) - Google Chrome" = "󰊯 $1";
              "(.*) - Visual Studio Code" = "󰨞 $1";
              "Alacritty" = "󰞷 Terminal";
            };
          };

          "clock" = {
            format = "󰥔 {:%H:%M}";
            format-alt = "󰃭 {:%d/%m/%Y  󰥔 %H:%M:%S}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='${c.purple}'><b>{}</b></span>";
                days = "<span color='${c.fg}'><b>{}</b></span>";
                weeks = "<span color='${c.cyan}'><b>W{}</b></span>";
                weekdays = "<span color='${c.yellow}'><b>{}</b></span>";
                today = "<span color='${c.red}'><b><u>{}</u></b></span>";
              };
            };
          };

          "cpu" = {
            format = "󰍛 {usage}%";
            interval = 2;
            tooltip = true;
          };

          "memory" = {
            format = "󰘚 {percentage}%";
            interval = 2;
            tooltip-format = "RAM: {used:0.1f}GiB / {total:0.1f}GiB ({percentage}%)";
          };

          "backlight" = {
            device = "intel_backlight";
            format = "{icon} {percent}%";
            format-icons = [
              "󰃞"
              "󰃟"
              "󰃠"
            ];
            on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl -q s +2% || ${pkgs.brightnessctl}/bin/brightnessctl -q s +1";
            on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl -q s 2%- || ${pkgs.brightnessctl}/bin/brightnessctl -q s 1-";
            tooltip = false;
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = "󰝟 Mudo";
            format-icons = {
              headphone = "󰋋";
              hands-free = "󰋎";
              headset = "󰋎";
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+";
            on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
            tooltip = false;
          };

          "network" = {
            format-wifi = "󰤨 {essid}";
            format-ethernet = "󰈀 Conectado";
            format-linked = "󰈀 Sem IP";
            format-disconnected = "󰤮 Offline";
            tooltip-format = "Interface: {ifname}\nIP: {ipaddr}\nSinal: {signalStrength}%";
            on-click = "${rofiWifiMenu}/bin/rofi-wifi-menu";
          };

          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            tooltip-format = "{timeTo}\nConsumo: {power}W";
          };

          "tray" = {
            icon-size = 14;
            spacing = 8;
          };

          "custom/power" = {
            format = "󰐥";
            on-click = "${powerMenu}/bin/session-power-menu";
            tooltip = false;
          };
        };
      };

      style = import ./_waybar-style.nix { inherit c; };
    };
  };
}
