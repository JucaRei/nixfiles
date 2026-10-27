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
  c = config.desktop.theme.colors;
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

    chosen=$(printf "$menu" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰤨 WiFi " -theme-str 'window {width: 750px; height: 480px;} listview {columns: 1; lines: 12;}')
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
          pass=$(${pkgs.rofi}/bin/rofi -dmenu -p " 󰌾 Senha WiFi: $ssid " -password -theme-str 'window {width: 580px; height: 100px;} listview {lines: 0;}')
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

    code=$(echo "$state" | ${pkgs.jq}/bin/jq -r '.monitors[] | select(.active) | .layout_symbol // empty' 2>/dev/null | head -n1 || true)
    if [ -z "$code" ]; then
      code=$(echo "$state" | ${pkgs.jq}/bin/jq -r '.monitors[0].layout_symbol // empty' 2>/dev/null || true)
    fi

    if [ -z "$code" ] || [ -z "''${LAYOUT_NAMES[$code]+x}" ]; then
      echo "{\"text\":\"󰕰 ''${code:-Tile}\",\"tooltip\":\"Layout atual: ''${code:-Desconhecido}\",\"class\":\"other\"}"
      exit 0
    fi

    name="''${LAYOUT_NAMES[$code]}"
    icon="''${LAYOUT_ICONS[$code]:-󰕰}"

    echo "{\"text\":\"$icon $name\",\"tooltip\":\"Layout do MangoWM: $name ($code)\nClique: Menu de Seleção | Dir: Alternar\",\"class\":\"$code\"}"
  '';

  mangoLayoutPicker = pkgs.writeShellScriptBin "mango-layout-picker" ''
    if [ -z "$MANGO_INSTANCE_SIGNATURE" ]; then
      SOCK=$(ls -t /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n 1)
      [ -n "$SOCK" ] && export MANGO_INSTANCE_SIGNATURE=$(basename "$SOCK" .sock | sed 's/^mango-//')
    fi

    options="󰹑 Scroller (S)\n󰕰 Tile (T)\n󰕲 Center Tile (CT)\n󰝘 Grid (G)\n󰍹 Monocle (M)\n󰓩 Deck (K)\n󰕳 Right Tile (RT)\n󰹒 Vertical Scroller (VS)\n󰕴 Vertical Tile (VT)\n󰝙 Vertical Grid (VG)\n󰓪 Vertical Deck (VK)\n󰕯 Dwindle (DW)\n󰕮 Fair (F)\n󰕬 Vertical Fair (VF)"

    dmenu_sock=$(ls /run/user/$(id -u)/noctalia-dmenu-*.sock 2>/dev/null | head -n1 || true)

    if [ -n "$dmenu_sock" ] && [ -S "$dmenu_sock" ] && command -v noctalia >/dev/null 2>&1; then
      chosen=$(printf "%b" "$options" | noctalia dmenu -p "Layout MangoWM")
    else
      chosen=$(printf "%b" "$options" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󱗼 Layout Mango " -theme-str '
        * {
          bg-col: ${c.bg};
          bg-col-light: ${c.bgAlt};
          border-col: ${c.accent};
          selected-col: ${c.surface};
          fg-col: ${c.fg};
          grey: ${c.fgMuted};
          font: "Inter 11";
        }
        window {
          width: 360px;
          height: 520px;
          border: 2px;
          border-color: ${c.accent};
          border-radius: 12px;
          background-color: ${c.bg};
        }
        mainbox {
          background-color: ${c.bg};
          padding: 12px;
        }
        inputbar {
          children: [prompt, entry];
          background-color: ${c.bgAlt};
          border-radius: 8px;
          padding: 6px 10px;
          margin: 0px 0px 8px 0px;
        }
        prompt {
          background-color: ${c.accent};
          padding: 4px 8px;
          text-color: ${c.bgDark};
          border-radius: 6px;
          margin: 0px 8px 0px 0px;
        }
        entry {
          padding: 4px;
          text-color: ${c.fg};
          background-color: transparent;
          placeholder-color: ${c.fgMuted};
        }
        listview {
          border: 0px;
          padding: 4px 0px 0px;
          margin: 0px;
          columns: 1;
          lines: 14;
          background-color: ${c.bg};
        }
        element {
          padding: 6px 10px;
          background-color: ${c.bg};
          text-color: ${c.fg};
          border-radius: 6px;
        }
        element selected {
          background-color: ${c.surface};
          text-color: ${c.accent};
        }
        element-text, element-icon {
          background-color: inherit;
          text-color: inherit;
        }
      ')
    fi

    case "$chosen" in
      *"Scroller (S)"*)           mmsg dispatch setlayout,scroller >/dev/null 2>&1 ;;
      *"Tile (T)"*)               mmsg dispatch setlayout,tile >/dev/null 2>&1 ;;
      *"Center Tile (CT)"*)       mmsg dispatch setlayout,center_tile >/dev/null 2>&1 ;;
      *"Grid (G)"*)               mmsg dispatch setlayout,grid >/dev/null 2>&1 ;;
      *"Monocle (M)"*)            mmsg dispatch setlayout,monocle >/dev/null 2>&1 ;;
      *"Deck (K)"*)               mmsg dispatch setlayout,deck >/dev/null 2>&1 ;;
      *"Right Tile (RT)"*)        mmsg dispatch setlayout,right_tile >/dev/null 2>&1 ;;
      *"Vertical Scroller (VS)"*) mmsg dispatch setlayout,vertical_scroller >/dev/null 2>&1 ;;
      *"Vertical Tile (VT)"*)     mmsg dispatch setlayout,vertical_tile >/dev/null 2>&1 ;;
      *"Vertical Grid (VG)"*)     mmsg dispatch setlayout,vertical_grid >/dev/null 2>&1 ;;
      *"Vertical Deck (VK)"*)     mmsg dispatch setlayout,vertical_deck >/dev/null 2>&1 ;;
      *"Dwindle (DW)"*)           mmsg dispatch setlayout,dwindle >/dev/null 2>&1 ;;
      *"Fair (F)"*)               mmsg dispatch setlayout,fair >/dev/null 2>&1 ;;
      *"Vertical Fair (VF)"*)     mmsg dispatch setlayout,vertical_fair >/dev/null 2>&1 ;;
    esac
    pkill -RTMIN+8 waybar 2>/dev/null || true
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
      *alacritty*|*kitty*|*terminal*|*foot*|*wezterm*|*ghostty*|*st*) ICON="" ;;
      *firefox*|*librewolf*|*floorp*|*zen*|*tor*) ICON="󰈹" ;;
      *chrome*|*chromium*|*brave*|*edge*|*vivaldi*|*opera*) ICON="" ;;
      *code*|*codium*|*vscode*|*antigravity*|*cursor*) ICON="󰨞" ;;
      *zed*)      ICON="󱓷" ;;
      *nvim*|*neovim*|*vim*) ICON="" ;;
      *thunar*|*nautilus*|*nemo*|*pcmanfm*|*dolphin*|*yazi*) ICON="󰉋" ;;
      *discord*|*vesktop*) ICON="󰙯" ;;
      *spotify*)  ICON="󰓇" ;;
      *mpv*|*vlc*) ICON="󰎁" ;;
      *steam*)    ICON="󰓓" ;;
      *zathura*|*pdf*) ICON="󰈦" ;;
      *obsidian*) ICON="󱓧" ;;
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
          color: ${c.fg};
        }

        tooltip {
          background: ${c.bgDark};
          border-radius: 10px;
          border: 1px solid ${c.accent};
          color: ${c.fg};
        }

        #custom-launcher {
          background: ${c.accent};
          color: ${c.bg};
          border-radius: 8px;
          padding: 2px 10px;
          margin: 4px 2px;
          font-size: 15px;
          transition: all 0.2s ease-in-out;
        }

        #custom-launcher:hover {
          background: ${c.purple};
        }

        #tags,
        #workspaces {
          background: ${c.surface};
          border: 1px solid ${c.border};
          border-radius: 8px;
          margin: 4px 2px;
          padding: 0 4px;
        }

        #tags button,
        #workspaces button {
          padding: 2px 6px;
          color: ${c.fgMuted};
          border-radius: 6px;
          transition: all 0.2s ease-in-out;
          font-size: 13px;
        }

        #tags button.occupied,
        #workspaces button.occupied {
          color: ${c.yellow};
        }

        #tags button.empty,
        #workspaces button.empty {
          color: ${c.fgSubtle};
        }

        #tags button.focused,
        #tags button.active,
        #workspaces button.focused,
        #workspaces button.active {
          color: ${c.bg};
          background: ${c.accent};
          font-weight: 800;
        }

        #tags button.urgent,
        #workspaces button.urgent {
          color: ${c.bg};
          background: ${c.red};
        }

        #tags button:hover,
        #workspaces button:hover {
          background: ${c.surfaceAlt};
          color: ${c.fg};
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
          background: ${c.surface};
          border: 1px solid ${c.border};
          color: ${c.purple};
          border-radius: 8px;
          padding: 2px 10px;
          margin: 4px 3px;
          transition: all 0.2s ease-in-out;
        }

        #custom-layout:hover {
          background: ${c.purple};
          color: ${c.bg};
          border-color: ${c.pink};
        }

        #window,
        #custom-window {
          color: ${c.fgMuted};
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
          background: ${c.surface};
          border: 1px solid ${c.border};
          color: ${c.accent};
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
          background: ${c.surface};
          border: 1px solid ${c.border};
          border-radius: 8px;
          padding: 2px 8px;
          margin: 4px 2px;
        }

        #cpu {
          color: ${c.cyan};
        }

        #temperature {
          color: ${c.orange};
        }

        #temperature.critical {
          color: ${c.red};
        }

        #memory {
          color: ${c.green};
        }

        #disk {
          color: ${c.yellow};
        }

        #network {
          color: ${c.purple};
        }

        #pulseaudio {
          color: ${c.pink};
        }

        #pulseaudio.muted {
          color: ${c.fgMuted};
          background: ${c.bgDark};
        }

        #backlight {
          color: ${c.yellow};
        }

        #battery {
          color: ${c.green};
        }

        #battery.charging {
          color: ${c.teal};
        }

        #battery.warning:not(.charging) {
          color: ${c.orange};
        }

        #battery.critical:not(.charging) {
          color: ${c.red};
          animation: blink 1s steps(2) infinite;
        }

        @keyframes blink {
          to {
            background-color: ${c.red};
            color: ${c.bg};
          }
        }

        #custom-power {
          background: ${c.surface};
          border: 1px solid ${c.red};
          color: ${c.red};
          border-radius: 8px;
          padding: 2px 10px;
          margin: 4px 2px 4px 4px;
          transition: all 0.2s ease-in-out;
        }

        #custom-power:hover {
          background: ${c.red};
          color: ${c.bg};
          border-color: ${c.red};
        }
      '';
    };
  };
}
