{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.wayland;
  isTraditional = config.desktop.display-servers.backend == "wayland" && cfg.shell == "traditional";
  isMango = cfg.compositor == "mangowm" || (config.desktop.mangowm.enable or false);

  # Script de Energia / Sessão (Power Menu via Rofi) — agnóstico ao compositor
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

  # Script de seleção WiFi via Rofi + nmcli
  rofiWifiMenu = pkgs.writeShellScriptBin "rofi-wifi-menu" ''
    NMCLI="/usr/bin/nmcli"
    if ! command -v "$NMCLI" >/dev/null 2>&1; then
      NMCLI=$(command -v nmcli 2>/dev/null || true)
    fi
    if [ -z "$NMCLI" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical "WiFi" "nmcli não encontrado. Instale o NetworkManager."
      exit 1
    fi

    connected=$($NMCLI -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    wifi_status=$($NMCLI radio wifi)

    if [ "$wifi_status" = "disabled" ]; then
      action=$(printf "󰤮 WiFi Desligado\n󰖩 Ligar WiFi" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰤮 WiFi " -theme-str 'window {width: 360px; height: 200px;} listview {lines: 2;}')
      case "$action" in
        *"Ligar WiFi") $NMCLI radio wifi on; ${pkgs.libnotify}/bin/notify-send -u low "WiFi" "Rádio WiFi ligado!" ;;
      esac
      exit 0
    fi

    $NMCLI dev wifi rescan 2>/dev/null || true
    sleep 1

    networks=$($NMCLI -t -f SSID,SIGNAL,SECURITY dev wifi list | grep -v '^$' | sort -t: -k2 -rn | head -15)
    menu=""
    if [ -n "$connected" ]; then
      menu="󰤨 Conectado: $connected\n󰤭 Desconectar\n"
    fi
    menu="$menu󰤯 Desligar WiFi\n─────────────\n"

    while IFS=: read -r ssid signal security; do
      [ -z "$ssid" ] && continue
      if [ "$signal" -ge 75 ]; then icon="󰤨";
      elif [ "$signal" -ge 50 ]; then icon="󰤥";
      elif [ "$signal" -ge 25 ]; then icon="󰤢";
      else icon="󰤟"; fi
      lock=""; [ -n "$security" ] && [ "$security" != "--" ] && lock=" 󰌾"
      menu="$menu$icon $ssid ($signal%)$lock\n"
    done <<< "$networks"

    chosen=$(printf "$menu" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰤨 WiFi " -theme-str 'window {width: 420px; height: 480px;} listview {lines: 12;}')
    [ -z "$chosen" ] && exit 0

    case "$chosen" in
      *"Desconectar")
        $NMCLI dev disconnect iface wlp2s0b1 2>/dev/null || $NMCLI con down id "$connected" 2>/dev/null
        ${pkgs.libnotify}/bin/notify-send -u low "WiFi" "Desconectado de $connected"
        ;;
      *"Desligar WiFi")
        $NMCLI radio wifi off
        ${pkgs.libnotify}/bin/notify-send -u low "WiFi" "Rádio WiFi desligado"
        ;;
      *"Conectado"*) ;;
      *"─────"*) ;;
      *)
        ssid=$(echo "$chosen" | sed 's/^[^ ]* //' | sed 's/ ([0-9]*%).*$//')
        if $NMCLI -t -f NAME con show | grep -qx "$ssid"; then
          $NMCLI con up id "$ssid" 2>/dev/null
        else
          pass=$(${pkgs.rofi}/bin/rofi -dmenu -p " 󰌾 Senha WiFi: $ssid " -password -theme-str 'window {width: 420px; height: 100px;} listview {lines: 0;}')
          if [ -n "$pass" ]; then
            $NMCLI dev wifi connect "$ssid" password "$pass" 2>/dev/null
          fi
        fi
        ;;
    esac
  '';

  # Scripts de utilidade para o MangoWM
  mangoLayoutSwitcher = pkgs.writeShellScriptBin "mango-layout-switcher" ''
    if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
    fi
    LAYOUT=$(mmsg get layout 2>/dev/null || echo "tile")
    case "$LAYOUT" in
      *tile*)     echo '{"text": "󰕰 Tile", "tooltip": "Layout: Tile (Normal)\nClique para alternar", "class": "tile"}' ;;
      *scroller*) echo '{"text": "󰍹 Scroll", "tooltip": "Layout: Scroller\nClique para alternar", "class": "scroller"}' ;;
      *grid*)     echo '{"text": "󰝘 Grid", "tooltip": "Layout: Grid\nClique para alternar", "class": "grid"}' ;;
      *monocle*)  echo '{"text": "󰍹 Mono", "tooltip": "Layout: Monocle (Fullscreen)\nClique para alternar", "class": "monocle"}' ;;
      *)          echo "{\"text\": \"󰕰 $LAYOUT\", \"tooltip\": \"Layout: $LAYOUT\", \"class\": \"other\"}" ;;
    esac
  '';

  mangoLayoutPicker = pkgs.writeShellScriptBin "mango-layout-picker" ''
    if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
    fi
    chosen=$(printf "󰕰 Tile\n󰍹 Scroller\n󰝘 Grid\n󰍹 Monocle" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󱗼 Layout " -theme-str 'window {width: 280px; height: 260px;} listview {lines: 4;}')
    case "$chosen" in
      *"Tile")     mmsg dispatch switch_layout,tile 2>/dev/null ;;
      *"Scroller") mmsg dispatch switch_layout,scroller 2>/dev/null ;;
      *"Grid")     mmsg dispatch switch_layout,grid 2>/dev/null ;;
      *"Monocle")  mmsg dispatch switch_layout,monocle 2>/dev/null ;;
    esac
    pkill -RTMIN+8 waybar 2>/dev/null || true
  '';

  mangoReload = pkgs.writeShellScriptBin "mango-reload" ''
    if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
    fi
    mmsg dispatch reload_config 2>/dev/null || true
    pkill -SIGUSR2 waybar 2>/dev/null || true
    ${pkgs.libnotify}/bin/notify-send -u low "MangoWM" "Configuração e Waybar recarregados com sucesso!"
  '';

  mangoToggleOuterGaps = pkgs.writeShellScriptBin "mango-toggle-outer-gaps" ''
    GAPS_FILE="/tmp/.mango_outer_gaps_$USER"
    if [ -f "$GAPS_FILE" ]; then
      rm -f "$GAPS_FILE"
      mmsg dispatch set_outer_gaps,8 2>/dev/null || true
      ${pkgs.libnotify}/bin/notify-send -u low "MangoWM" "Gaps externos restaurados (8px)"
    else
      touch "$GAPS_FILE"
      mmsg dispatch set_outer_gaps,0 2>/dev/null || true
      ${pkgs.libnotify}/bin/notify-send -u low "MangoWM" "Gaps externos desativados (0px)"
    fi
  '';

  mangoWindowTitle = pkgs.writeShellScriptBin "mango-window-title" ''
    if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
    fi
    INFO=$(mmsg get focusing-client 2>/dev/null)
    if [ -z "$INFO" ] || [ "$INFO" = "null" ]; then
      echo '{"text": "", "tooltip": "", "class": "empty"}'
      exit 0
    fi
    TITLE=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.title // empty' 2>/dev/null)
    APPID=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.appid // empty' 2>/dev/null)
    if [ -z "$TITLE" ]; then
      echo '{"text": "", "tooltip": "", "class": "empty"}'
      exit 0
    fi
    ICON="󰣆"
    case "$APPID" in
      *alacritty*|*kitty*|*terminal*) ICON="󰞷" ;;
      *firefox*)  ICON="󰈹" ;;
      *chrome*)   ICON="󰊯" ;;
      *code*|*antigravity*) ICON="󰨞" ;;
      *thunar*)   ICON="󰝰" ;;
      *mpv*)      ICON="󰕼" ;;
    esac
    TRUNCATED=$(echo "$TITLE" | cut -c 1-38)
    [ "''${#TITLE}" -gt 38 ] && TRUNCATED="$TRUNCATED..."
    ESCAPED_TEXT=$(echo "$ICON $TRUNCATED" | sed 's/"/\\"/g')
    ESCAPED_TOOLTIP=$(echo "$APPID: $TITLE" | sed 's/"/\\"/g')
    echo "{\"text\": \"$ESCAPED_TEXT\", \"tooltip\": \"$ESCAPED_TOOLTIP\", \"class\": \"$APPID\"}"
  '';
in
{
  options.desktop.wayland.traditional.waybar = {
    enable = mkOption {
      type = bool;
      default = isTraditional;
      description = "Habilitar waybar moderna no shell tradicional Wayland";
    };
  };

  # Retrocompatibilidade
  options.desktop.hyprland.waybar = {
    enable = mkOption {
      type = bool;
      default = config.desktop.wayland.traditional.waybar.enable;
      description = "Opção de retrocompatibilidade para waybar";
    };
  };

  options.desktop.mangowm.waybar = {
    enable = mkOption {
      type = bool;
      default = config.desktop.wayland.traditional.waybar.enable;
      description = "Opção de retrocompatibilidade para waybar";
    };
  };

  config = mkIf (isTraditional && config.desktop.wayland.traditional.waybar.enable) {
    home.packages = [
      powerMenu
      powerMenuHyprland
      rofiWifiMenu
      mangoLayoutSwitcher
      mangoLayoutPicker
      mangoReload
      mangoToggleOuterGaps
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
                months = "<span color='#cba6f7'><b>{}</b></span>";
                days = "<span color='#cdd6f4'><b>{}</b></span>";
                weeks = "<span color='#89dceb'><b>W{}</b></span>";
                weekdays = "<span color='#f9e2af'><b>{}</b></span>";
                today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
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
            format-icons = [ "󰃞" "󰃟" "󰃠" ];
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
              default = [ "󰕿" "󰖀" "󰕾" ];
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
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
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

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: 'Inter', 'JetBrainsMono Nerd Font', Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: transparent;
          color: #cdd6f4;
        }

        tooltip {
          background: #1e1e2e;
          border-radius: 10px;
          border: 1px solid #89b4fa;
          color: #cdd6f4;
        }

        #custom-launcher {
          background: #89b4fa;
          color: #1e1e2e;
          border-radius: 8px;
          padding: 2px 10px;
          margin: 4px 2px;
          font-size: 15px;
          transition: all 0.2s ease-in-out;
        }

        #custom-launcher:hover {
          background: #b4befe;
        }

        #tags,
        #workspaces {
          background: rgba(49, 50, 68, 0.6);
          border: 1px solid rgba(137, 180, 250, 0.25);
          border-radius: 8px;
          margin: 4px 2px;
          padding: 0 4px;
        }

        #tags button,
        #workspaces button {
          padding: 2px 6px;
          color: #a6adc8;
          border-radius: 6px;
          transition: all 0.2s ease-in-out;
          font-size: 13px;
        }

        #tags button.occupied,
        #workspaces button.occupied {
          color: #f9e2af;
        }

        #tags button.empty,
        #workspaces button.empty {
          color: #585b70;
        }

        #tags button.focused,
        #tags button.active,
        #workspaces button.focused,
        #workspaces button.active {
          color: #1e1e2e;
          background: #89b4fa;
          font-weight: 800;
        }

        #tags button.urgent,
        #workspaces button.urgent {
          color: #1e1e2e;
          background: #f38ba8;
        }

        #tags button:hover,
        #workspaces button:hover {
          background: rgba(137, 180, 250, 0.25);
          color: #cdd6f4;
        }

        #tags button.empty:nth-child(n+6),
        #workspaces button.empty:nth-child(n+6) {
          padding: 0;
          margin: 0;
          min-width: 0;
          font-size: 0;
          border: none;
          opacity: 0;
        }

        #custom-layout {
          background: rgba(49, 50, 68, 0.6);
          border: 1px solid rgba(203, 166, 247, 0.35);
          color: #cba6f7;
          border-radius: 8px;
          padding: 2px 10px;
          margin: 4px 3px;
          transition: all 0.2s ease-in-out;
        }

        #custom-layout:hover {
          background: #cba6f7;
          color: #1e1e2e;
          border-color: #f5c2e7;
        }

        #window,
        #custom-window {
          color: #a6adc8;
          padding: 2px 8px;
          margin: 4px 3px;
          font-weight: 600;
        }

        #custom-window.empty {
          opacity: 0;
          padding: 0;
          margin: 0;
        }

        #clock {
          background: rgba(49, 50, 68, 0.6);
          border: 1px solid rgba(137, 180, 250, 0.25);
          color: #89b4fa;
          border-radius: 8px;
          padding: 2px 12px;
          margin: 4px 0;
        }

        #cpu,
        #temperature,
        #memory,
        #disk,
        #network,
        #pulseaudio,
        #backlight,
        #battery,
        #tray {
          background: rgba(49, 50, 68, 0.5);
          border: 1px solid rgba(49, 50, 68, 0.8);
          border-radius: 8px;
          padding: 2px 8px;
          margin: 4px 2px;
        }

        #cpu {
          color: #89dceb;
        }

        #temperature {
          color: #fab387;
        }

        #temperature.critical {
          color: #f38ba8;
        }

        #memory {
          color: #a6e3a1;
        }

        #disk {
          color: #f9e2af;
        }

        #network {
          color: #cba6f7;
        }

        #pulseaudio {
          color: #f5c2e7;
        }

        #pulseaudio.muted {
          color: #6c7086;
          background: rgba(30, 30, 46, 0.6);
        }

        #backlight {
          color: #f9e2af;
        }

        #battery {
          color: #a6e3a1;
        }

        #battery.charging {
          color: #94e2d5;
        }

        #battery.warning:not(.charging) {
          color: #fab387;
        }

        #battery.critical:not(.charging) {
          color: #f38ba8;
          animation: blink 1s steps(2) infinite;
        }

        @keyframes blink {
          to {
            background-color: #f38ba8;
            color: #1e1e2e;
          }
        }

        #custom-power {
          background: rgba(243, 139, 168, 0.15);
          border: 1px solid rgba(243, 139, 168, 0.35);
          color: #f38ba8;
          border-radius: 8px;
          padding: 2px 10px;
          margin: 4px 2px 4px 4px;
          transition: all 0.2s ease-in-out;
        }

        #custom-power:hover {
          background: #f38ba8;
          color: #1e1e2e;
          border-color: #f38ba8;
        }
      '';
    };
  };
}
