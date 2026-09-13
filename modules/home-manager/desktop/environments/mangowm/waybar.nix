{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.mangowm;

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
          hyprctl dispatch exit
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

  # Script de seleção WiFi via Rofi + nmcli (usa nmcli nativo do Fedora/NixOS)
  rofiWifiMenu = pkgs.writeShellScriptBin "rofi-wifi-menu" ''
    NMCLI="/usr/bin/nmcli"
    if ! command -v "$NMCLI" >/dev/null 2>&1; then
      NMCLI=$(command -v nmcli 2>/dev/null || true)
    fi
    if [ -z "$NMCLI" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical "WiFi" "nmcli não encontrado. Instale o NetworkManager."
      exit 1
    fi

    # Estado atual da conexão
    connected=$($NMCLI -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    wifi_status=$($NMCLI radio wifi)

    if [ "$wifi_status" = "disabled" ]; then
      action=$(printf "󰤮 WiFi Desligado\n󰖩 Ligar WiFi" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰤮 WiFi " -theme-str 'window {width: 360px; height: 200px;} listview {lines: 2;}')
      case "$action" in
        *"Ligar WiFi") $NMCLI radio wifi on; ${pkgs.libnotify}/bin/notify-send -u low "WiFi" "Rádio WiFi ligado!" ;;
      esac
      exit 0
    fi

    # Escanear redes disponíveis
    $NMCLI dev wifi rescan 2>/dev/null || true
    sleep 1

    # Listar SSIDs com sinal
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
        if $NMCLI -t -f active,ssid dev wifi | grep -q "^yes:$ssid"; then
          ${pkgs.libnotify}/bin/notify-send -u low "WiFi" "Conectado a $ssid"
        else
          ${pkgs.libnotify}/bin/notify-send -u critical "WiFi" "Falha ao conectar a $ssid"
        fi
        ;;
    esac
  '';

  # Script para exibir o título da janela ativa na Waybar (via mmsg get focusing-client)
  mangoWindowTitle = pkgs.writeShellScriptBin "mango-window-title" ''
    set -euo pipefail
    if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
      export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n1 || true)
    fi

    client=$(mmsg get focusing-client 2>/dev/null || true)
    if [ -z "$client" ] || echo "$client" | grep -q '"error"'; then
      echo '{"text":"","tooltip":"Área de Trabalho","class":"empty"}'
      exit 0
    fi

    title=$(echo "$client" | ${pkgs.jq}/bin/jq -r '.title // empty' 2>/dev/null || true)
    appid=$(echo "$client" | ${pkgs.jq}/bin/jq -r '.appid // empty' 2>/dev/null || true)

    if [ -z "$title" ]; then
      echo '{"text":"","tooltip":"Área de Trabalho","class":"empty"}'
      exit 0
    fi

    appid_lower=$(echo "$appid" | tr '[:upper:]' '[:lower:]')

    icon="󰣆"
    case "$appid_lower" in
      *firefox*) icon="󰈹" ;;
      *chrom*) icon="" ;;
      *code*) icon="󰨞" ;;
      *zed*) icon="󱓷" ;;
      *discord*) icon="󰙯" ;;
      *steam*) icon="󰓓" ;;
      *alacritty*) icon="" ;;
      *kitty*) icon="󰄛" ;;
      *thunar*) icon="󰉋" ;;
      *pavucontrol*) icon="󰕾" ;;
    esac

    # Truncar título longo para telas pequenas
    if [ ''${#title} -gt 28 ]; then
      display_title="''${title:0:25}…"
    else
      display_title="$title"
    fi

    ${pkgs.jq}/bin/jq -c -n \
      --arg text "$icon $display_title" \
      --arg tooltip "$title ($appid)" \
      --arg class "$appid_lower" \
      '{"text": $text, "tooltip": $tooltip, "class": $class}'
  '';

  # Script para exibir o layout ativo na Waybar (via mmsg get all-monitors)
  mangoLayoutSwitcher = pkgs.writeShellScriptBin "mango-layout-switcher" ''
    set -euo pipefail
    if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
      export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n1 || true)
    fi

    declare -A LAYOUT_NAMES=(
      [T]="Tile"
      [S]="Scroller"
      [G]="Grid"
      [M]="Monocle"
      [K]="Deck"
      [CT]="Center Tile"
      [RT]="Right Tile"
      [VS]="Vert Scroller"
      [VT]="Vert Tile"
      [VG]="Vert Grid"
      [VK]="Vert Deck"
      [DW]="Dwindle"
      [F]="Fair"
      [VF]="Vert Fair"
      [TG]="TGMix"
    )

    declare -A LAYOUT_ICONS=(
      [T]="󰕰"
      [S]="󰹑"
      [G]="󰝘"
      [M]="󰍹"
      [K]="󰓩"
      [CT]="󰕲"
      [RT]="󰕳"
      [VS]="󰹒"
      [VT]="󰕴"
      [VG]="󰝙"
      [VK]="󰓪"
      [DW]="󰕯"
      [F]="󰕮"
      [VF]="󰕬"
      [TG]="󰕱"
    )

    state=$(mmsg get all-monitors 2>/dev/null || true)
    if [ -z "$state" ] || echo "$state" | grep -q '"error"'; then
      echo '{"text":"󰕰 Mango","tooltip":"MangoWM não detectado ou inativo"}'
      exit 0
    fi

    code=$(echo "$state" | ${pkgs.jq}/bin/jq -r '.monitors[0].layout_symbol // empty' 2>/dev/null || true)
    if [ -z "$code" ] || [ -z "''${LAYOUT_NAMES[$code]+x}" ]; then
      echo "{\"text\":\"󰕰 ''${code:-Tile}\",\"tooltip\":\"Layout atual: ''${code:-Desconhecido}\"}"
      exit 0
    fi

    name="''${LAYOUT_NAMES[$code]}"
    icon="''${LAYOUT_ICONS[$code]:-󰕰}"

    echo "{\"text\":\"$icon $name\",\"tooltip\":\"Layout do MangoWM: $name ($code)\nClique para alternar o layout\",\"class\":\"$code\"}"
  '';

  # Menu Rofi para seleção rápida de layout do MangoWM
  mangoLayoutPicker = pkgs.writeShellScriptBin "mango-layout-picker" ''
    set -euo pipefail
    if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
      export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n1 || true)
    fi

    options="󰹑 Scroller (S)\n󰕰 Tile (T)\n󰕲 Center Tile (CT)\n󰝘 Grid (G)\n󰍹 Monocle (M)\n󰓩 Deck (K)\n󰕳 Right Tile (RT)\n󰹒 Vertical Scroller (VS)\n󰕴 Vertical Tile (VT)\n󰝙 Vertical Grid (VG)\n󰓪 Vertical Deck (VK)\n󰕯 Dwindle (DW)\n󰕮 Fair (F)"

    chosen=$(echo -e "$options" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰕰 Layout Mango " -theme-str 'window {width: 320px; height: 440px;} listview {lines: 13;}')

    case "$chosen" in
      *"Scroller (S)") mmsg dispatch setlayout,scroller >/dev/null 2>&1 ;;
      *"Tile (T)") mmsg dispatch setlayout,tile >/dev/null 2>&1 ;;
      *"Center Tile (CT)") mmsg dispatch setlayout,center_tile >/dev/null 2>&1 ;;
      *"Grid (G)") mmsg dispatch setlayout,grid >/dev/null 2>&1 ;;
      *"Monocle (M)") mmsg dispatch setlayout,monocle >/dev/null 2>&1 ;;
      *"Deck (K)") mmsg dispatch setlayout,deck >/dev/null 2>&1 ;;
      *"Right Tile (RT)") mmsg dispatch setlayout,right_tile >/dev/null 2>&1 ;;
      *"Vertical Scroller (VS)") mmsg dispatch setlayout,vertical_scroller >/dev/null 2>&1 ;;
      *"Vertical Tile (VT)") mmsg dispatch setlayout,vertical_tile >/dev/null 2>&1 ;;
      *"Vertical Grid (VG)") mmsg dispatch setlayout,vertical_grid >/dev/null 2>&1 ;;
      *"Vertical Deck (VK)") mmsg dispatch setlayout,vertical_deck >/dev/null 2>&1 ;;
      *"Dwindle (DW)") mmsg dispatch setlayout,dwindle >/dev/null 2>&1 ;;
      *"Fair (F)") mmsg dispatch setlayout,fair >/dev/null 2>&1 ;;
    esac
  '';
in
{
  options.desktop.mangowm.waybar = {
    enable = mkOption {
      type = bool;
      default = cfg.enable;
      description = "Enable modern custom waybar status bar for MangoWM";
    };
  };

  config = mkIf (cfg.enable && config.desktop.mangowm.waybar.enable) {
    home.packages = [
      mangoLayoutSwitcher
      mangoLayoutPicker
      mangoWindowTitle
      powerMenu
      rofiWifiMenu
    ];

    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      systemd.enable = false;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 36;
          margin-top = 6;
          margin-left = 10;
          margin-right = 10;
          spacing = 6;

          modules-left = [
            "custom/launcher"
            "ext/workspaces"
            "custom/layout"
            "custom/window"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "cpu"
            "temperature"
            "memory"
            "disk"
            "network"
            "pulseaudio"
            "backlight"
            "battery"
            "tray"
            "custom/power"
          ];

          "custom/launcher" = {
            format = "󱄅";
            on-click = "${pkgs.rofi}/bin/rofi -show drun";
            tooltip = false;
          };

          "ext/workspaces" = {
            format = "{name}";
            on-click = "activate";
            sort-by-id = true;
          };

          "custom/layout" = {
            exec = "${mangoLayoutSwitcher}/bin/mango-layout-switcher";
            interval = 1;
            return-type = "json";
            on-click = "${mangoLayoutPicker}/bin/mango-layout-picker";
            tooltip = true;
          };

          "custom/window" = {
            exec = "${mangoWindowTitle}/bin/mango-window-title";
            interval = 1;
            return-type = "json";
            tooltip = true;
          };

          "clock" = {
            format = "󰥔 {:%H:%M}";
            format-alt = "󰃭 {:%a, %d %b %Y}";
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

          "temperature" = {
            format = " {temperatureC}°C";
            interval = 3;
            tooltip = true;
          };

          "memory" = {
            format = "󰍛 {percentage}%";
            interval = 2;
            tooltip-format = "RAM: {used:0.1f}GiB / {total:0.1f}GiB";
          };

          "disk" = {
            format = "󰋊 {percentage_used}%";
            path = "/";
            interval = 30;
            tooltip-format = "Disco: {used} / {total} ({percentage_used}%)";
          };

          "network" = {
            format-wifi = "󰤨 {bandwidthDownBytes} 󰇚";
            format-ethernet = "󰈀 {bandwidthDownBytes} 󰇚";
            format-disconnected = "󰤭 Offline";
            interval = 2;
            on-click = "${rofiWifiMenu}/bin/rofi-wifi-menu";
            tooltip-format-wifi = "WiFi: {essid} ({signalStrength}%)\nDown: {bandwidthDownBits} | Up: {bandwidthUpBits}";
            tooltip-format-ethernet = "Ethernet: {ifname}\nDown: {bandwidthDownBits} | Up: {bandwidthUpBits}";
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = "󰝟 Mudo";
            format-icons = {
              headphone = "󰋋";
              headset = "󰋋";
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-scroll-up = "${pkgs.pamixer}/bin/pamixer -i 5";
            on-scroll-down = "${pkgs.pamixer}/bin/pamixer -d 5";
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

          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-icons = [
              "󰂎"
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
            icon-size = 15;
            spacing = 8;
          };

          "custom/power" = {
            format = "󰐥";
            tooltip = "Menu de Sessão / Energia";
            on-click = "${powerMenu}/bin/session-power-menu";
          };
        };
      };

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
          font-size: 13px;
          font-weight: bold;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(30, 30, 46, 0.88);
          border: 1px solid rgba(137, 180, 250, 0.2);
          border-radius: 12px;
          color: #cdd6f4;
          padding: 0 4px;
        }

        /* Launcher */
        #custom-launcher {
          font-size: 16px;
          color: #89b4fa;
          background: rgba(49, 50, 68, 0.6);
          border: 1px solid rgba(137, 180, 250, 0.25);
          border-radius: 8px;
          padding: 2px 10px 2px 8px;
          margin: 4px 3px;
          transition: all 0.2s ease-in-out;
        }

        #custom-launcher:hover {
          background: #89b4fa;
          color: #1e1e2e;
          border-color: #b4befe;
        }

        /* Workspaces / Mango Tags */
        #tags,
        #workspaces {
          background: rgba(17, 17, 27, 0.4);
          border: 1px solid rgba(49, 50, 68, 0.6);
          border-radius: 8px;
          padding: 1px 4px;
          margin: 4px 3px;
        }

        #tags button,
        #workspaces button {
          color: #6c7086;
          background: transparent;
          border-radius: 6px;
          padding: 1px 7px;
          margin: 1px;
          transition: all 0.2s ease-in-out;
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

        /* Oculta tags 6-9 quando vazias para economizar espaço em telas pequenas */
        #tags button.empty:nth-child(n+6),
        #workspaces button.empty:nth-child(n+6) {
          padding: 0;
          margin: 0;
          min-width: 0;
          font-size: 0;
          border: none;
          opacity: 0;
        }

        /* Layout Switcher */
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

        /* Window Title */
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

        /* Center Clock */
        #clock {
          background: rgba(49, 50, 68, 0.6);
          border: 1px solid rgba(137, 180, 250, 0.25);
          color: #89b4fa;
          border-radius: 8px;
          padding: 2px 12px;
          margin: 4px 0;
        }

        /* Right Hardware / Info Modules */
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
