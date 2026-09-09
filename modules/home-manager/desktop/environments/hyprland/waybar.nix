{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.hyprland.waybar;

  powerMenu = pkgs.writeShellScriptBin "session-power-menu" ''
    chosen=$(printf "󰌾 Bloquear\n󰤄 Suspender\n󰍃 Encerrar Sessão\n󰑐 Reiniciar\n󰐥 Desligar" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰐥 Energia " -theme-str 'window {width: 320px; height: 320px;} listview {columns: 1; lines: 5;}')
    case "$chosen" in
      *"Bloquear") ${pkgs.hyprlock}/bin/hyprlock ;;
      *"Suspender") systemctl suspend ;;
      *"Encerrar Sessão")
        if [ "$XDG_CURRENT_DESKTOP" = "mango" ] || [ "$DESKTOP_SESSION" = "mango" ] || pgrep -x mango >/dev/null 2>&1; then
          pkill -SIGTERM -x mango 2>/dev/null || loginctl terminate-session "''${XDG_SESSION_ID:-}" 2>/dev/null || loginctl terminate-user "$USER"
        elif command -v hyprctl >/dev/null 2>&1 && pgrep -x Hyprland >/dev/null 2>&1; then
          ${pkgs.hyprland}/bin/hyprctl dispatch exit
        elif [ -n "''${XDG_SESSION_ID:-}" ]; then
          loginctl terminate-session "$XDG_SESSION_ID"
        else
          loginctl terminate-user "$USER"
        fi
        ;;
      *"Reiniciar") systemctl reboot ;;
      *"Desligar") systemctl poweroff ;;
    esac
  '';

  powerMenuHyprland = pkgs.writeShellScriptBin "hyprland-power-menu" ''
    exec ${powerMenu}/bin/session-power-menu "$@"
  '';
in
{
  options.desktop.hyprland.waybar = {
    enable = mkOption {
      type = bool;
      default = config.desktop.hyprland.enable;
      description = "Enable modern waybar status bar for hyprland";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      powerMenu
      powerMenuHyprland
    ];

    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      systemd = {
        enable = false; # Iniciado pelo Hyprland exec-once para garantir sincronismo
      };
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 38;
          margin-top = 8;
          margin-left = 14;
          margin-right = 14;
          spacing = 8;

          modules-left = [
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

          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            format-icons = {
              "1" = "󰮯";
              "2" = "󰊠";
              "3" = "󰀦";
              "4" = "󰈹";
              "5" = "󰓇";
              "6" = "󰭹";
              "7" = "󰚀";
              "8" = "󱔗";
              "9" = "󰒱";
              "10" = "󰐥";
              urgent = "󰀨";
              default = "󰄰";
            };
            sort-by-number = true;
          };

          "hyprland/window" = {
            format = "{title}";
            max-length = 35;
            separate-outputs = true;
          };

          "clock" = {
            format = "󰥔 {:%H:%M}";
            format-alt = "󰃭 {:%A, %d de %B de %Y}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='#cba6f7'><b>{}</b></span>";
                days = "<span color='#cdd6f4'><b>{}</b></span>";
                weeks = "<span color='#89b4fa'><b>W{}</b></span>";
                weekdays = "<span color='#fab387'><b>{}</b></span>";
                today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
              };
            };
          };

          "cpu" = {
            format = " {usage}%";
            interval = 2;
            tooltip = true;
          };

          "memory" = {
            format = "󰍛 {percentage}%";
            interval = 2;
            tooltip-format = "RAM: {used:0.1f}GiB / {total:0.1f}GiB";
          };

          "backlight" = {
            format = "{icon} {percent}%";
            format-icons = [
              "󰃞"
              "󰃟"
              "󰃠"
            ];
            on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
            on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = "󰝟 Mudo";
            format-icons = {
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            scroll-step = 4;
            on-click = "${pkgs.pamixer}/bin/pamixer -t";
            on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
            tooltip-format = "{desc}: {volume}%";
          };

          "network" = {
            format-wifi = "󰤨 {essid}";
            format-ethernet = "󰈀 Conectado";
            format-disconnected = "󰤭 Offline";
            tooltip-format-wifi = "Sinal: {signalStrength}%\nIP: {ipaddr}\nVelocidade: {bandwidthDownBytes} / {bandwidthUpBytes}";
            tooltip-format-ethernet = "Interface: {ifname}\nIP: {ipaddr}";
            tooltip-format-disconnected = "Sem conexão ativa";
            on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
          };

          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰚥 {capacity}%";
            format-icons = [
              "󰂃"
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
          };

          "tray" = {
            icon-size = 16;
            spacing = 8;
          };

          "custom/power" = {
            format = "󰐥";
            on-click = "${powerMenu}/bin/session-power-menu";
            tooltip = false;
          };
        };
      };

      style = ''
        /* Paleta Catppuccin Mocha */
        @define-color base       #1e1e2e;
        @define-color mantle     #181825;
        @define-color crust      #11111b;
        @define-color surface0   #313244;
        @define-color surface1   #45475a;
        @define-color surface2   #585b70;
        @define-color text       #cdd6f4;
        @define-color subtext0   #a6adc8;
        @define-color subtext1   #bac2de;
        @define-color mauve      #cba6f7;
        @define-color pink       #f5c2e7;
        @define-color red        #f38ba8;
        @define-color peach      #fab387;
        @define-color yellow     #f9e2af;
        @define-color green      #a6e3a1;
        @define-color teal       #94e2d5;
        @define-color sapphire   #74c7ec;
        @define-color blue       #89b4fa;
        @define-color lavender   #b4befe;

        * {
          font-family: "Inter", "FiraCode Nerd Font Mono", sans-serif;
          font-size: 12px;
          font-weight: 600;
          min-height: 0;
          border: none;
          border-radius: 0;
        }

        window#waybar {
          background-color: transparent;
        }

        /* Pills flutuantes */
        #custom-launcher,
        #workspaces,
        #window,
        #clock,
        #cpu,
        #memory,
        #backlight,
        #pulseaudio,
        #network,
        #battery,
        #tray,
        #custom-power {
          background: rgba(30, 30, 46, 0.78);
          color: @text;
          padding: 4px 12px;
          margin: 0px 4px;
          border-radius: 12px;
          border: 1px solid rgba(203, 166, 247, 0.22);
          transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }

        #custom-launcher {
          color: @mauve;
          font-size: 16px;
          padding: 4px 14px;
        }

        #custom-launcher:hover {
          background: @mauve;
          color: @crust;
        }

        #workspaces {
          padding: 2px 6px;
        }

        #workspaces button {
          padding: 2px 8px;
          margin: 2px 3px;
          border-radius: 8px;
          color: @subtext0;
          background: transparent;
          transition: all 0.25s ease;
        }

        #workspaces button:hover {
          background: rgba(203, 166, 247, 0.2);
          color: @text;
        }

        #workspaces button.active {
          background: @mauve;
          color: @crust;
          font-weight: bold;
        }

        #workspaces button.urgent {
          background: @red;
          color: @crust;
        }

        #window {
          color: @subtext1;
          font-style: italic;
        }

        #clock {
          color: @mauve;
          font-weight: bold;
          padding: 4px 16px;
        }

        #cpu {
          color: @peach;
        }

        #memory {
          color: @green;
        }

        #backlight {
          color: @yellow;
        }

        #pulseaudio {
          color: @sapphire;
        }

        #pulseaudio.muted {
          color: @red;
        }

        #network {
          color: @lavender;
        }

        #network.disconnected {
          color: @red;
        }

        #battery {
          color: @teal;
        }

        #battery.charging {
          color: @green;
        }

        #battery.warning:not(.charging) {
          color: @yellow;
        }

        #battery.critical:not(.charging) {
          color: @red;
          animation-name: blink;
          animation-duration: 0.8s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        @keyframes blink {
          to {
            background-color: @red;
            color: @crust;
          }
        }

        #custom-power {
          color: @red;
          font-size: 14px;
          padding: 4px 12px;
        }

        #custom-power:hover {
          background: @red;
          color: @crust;
        }

        tooltip {
          background: @mantle;
          border: 1px solid @mauve;
          border-radius: 10px;
          padding: 8px;
        }

        tooltip label {
          color: @text;
        }
      '';
    };
  };
}
