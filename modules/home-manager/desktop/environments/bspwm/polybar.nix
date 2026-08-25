{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.polybar;

  # --- Script de Controle de Mídia via playerctl ---
  mediaScript = pkgs.writeShellScript "polybar-media" ''
    if ! command -v ${pkgs.playerctl}/bin/playerctl >/dev/null 2>&1; then
      exit 0
    fi
    status=$(${pkgs.playerctl}/bin/playerctl status 2>/dev/null)
    if [ "$status" = "Playing" ]; then
      artist=$(${pkgs.playerctl}/bin/playerctl metadata artist 2>/dev/null)
      title=$(${pkgs.playerctl}/bin/playerctl metadata title 2>/dev/null)
      echo "󰎈 $artist - $title" | cut -c1-35
    elif [ "$status" = "Paused" ]; then
      echo "󰏤 Pausado"
    else
      echo ""
    fi
  '';

  # --- Menu Interativo de Redes Wi-Fi com Rofi ---
  rofiWifiMenu = pkgs.writeShellScript "rofi-wifi-menu" ''
    # Notificar varredura
    ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 -t 1500 "Escaneando redes Wi-Fi..."

    # Obter lista de redes Wi-Fi formatadas
    wifi_list=$(nmcli --fields "SECURITY,SSID,BARS" device wifi list --rescan yes | sed 1d | sed -E "s/  +/ /g" | sed -E "s/^ *//" | grep -v "^--" | awk -F' ' '{
      sec=$1;
      bars=$NF;
      $1="";
      $NF="";
      ssid=$0;
      gsub(/^ +| +$/, "", ssid);
      if (ssid != "") {
        icon = (sec ~ /WPA|WEP/) ? "󰌾" : "󰤨";
        printf "%s  %-25s [%s]\n", icon, ssid, bars;
      }
    }' | sort -u)

    if [ -z "$wifi_list" ]; then
      ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u normal -i "network-wireless-offline" -r 9994 "Nenhuma rede Wi-Fi encontrada"
      exit 0
    fi

    # Seleção de Rede via Rofi
    chosen_line=$(echo -e "$wifi_list\n󰑐  Escanear novamente\n󰤮  Desconectar Wi-Fi" | ${pkgs.rofi}/bin/rofi \
      -dmenu \
      -i \
      -p "Redes Wi-Fi" \
      -theme-str 'window {width: 380px; border-radius: 12px;} listview {lines: 10;}' \
      -no-custom)

    if [ -z "$chosen_line" ]; then
      exit 0
    fi

    if [[ "$chosen_line" =~ "Desconectar" ]]; then
      nmcli device disconnect wlan0 2>/dev/null || nmcli device disconnect wlp3s0 2>/dev/null || nmcli radio wifi off
      ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u low -i "network-wireless-offline" -r 9994 "Wi-Fi desconectado"
      exit 0
    fi

    if [[ "$chosen_line" =~ "Escanear" ]]; then
      exec "$0"
    fi

    # Extrair SSID limpo
    chosen_ssid=$(echo "$chosen_line" | awk -F'  ' '{print $2}' | sed 's/ \[.*//' | sed 's/^ *//;s/ *$//')

    if [ -n "$chosen_ssid" ]; then
      # Verificar se a rede já é conhecida
      saved_conn=$(nmcli -g NAME connection show | grep -Fx "$chosen_ssid")
      if [ -n "$saved_conn" ]; then
        ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 "Conectando a \"$chosen_ssid\"..."
        if nmcli connection up "$chosen_ssid"; then
          ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u normal -i "network-wireless" -r 9994 "Conectado a \"$chosen_ssid\" com sucesso!"
        else
          ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u critical -i "network-wireless-offline" -r 9994 "Falha ao conectar a \"$chosen_ssid\""
        fi
      else
        # Solicitar senha se for rede protegida
        if [[ "$chosen_line" =~ "󰌾" ]]; then
          wifi_pass=$(${pkgs.rofi}/bin/rofi -dmenu -password -p "Senha para $chosen_ssid" -theme-str 'window {width: 320px; border-radius: 12px;}')
          if [ -n "$wifi_pass" ]; then
            ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 "Conectando a \"$chosen_ssid\"..."
            if nmcli device wifi connect "$chosen_ssid" password "$wifi_pass"; then
              ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u normal -i "network-wireless" -r 9994 "Conectado a \"$chosen_ssid\"!"
            else
              ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u critical -i "network-wireless-offline" -r 9994 "Senha incorreta ou erro de conexão"
            fi
          fi
        else
          # Rede aberta
          ${pkgs.dunst}/bin/dunstify -a "Wi-Fi" -u low -i "network-wireless" -r 9994 "Conectando a \"$chosen_ssid\"..."
          nmcli device wifi connect "$chosen_ssid"
        fi
      fi
    fi
  '';

  # --- Menu de Desligamento com Rofi ---
  rofiPowerMenu = pkgs.writeShellScript "rofi-powermenu" ''
    chosen=$(printf "󰐥  Desligar\n󰜉  Reiniciar\n󰤄  Suspender\n󰒲  Hibernar\n󰈆  Sair (logout)\n󰌾  Bloquear" \
      | ${pkgs.rofi}/bin/rofi \
          -dmenu \
          -i \
          -p "Power Menu" \
          -theme-str 'window {width: 280px; border-radius: 12px;} listview {lines: 6;}' \
          -no-custom)
    case "$chosen" in
      *"Desligar")    systemctl poweroff ;;
      *"Reiniciar")   systemctl reboot ;;
      *"Suspender")   systemctl suspend ;;
      *"Hibernar")    systemctl hibernate ;;
      *"Sair"*)       bspc quit ;;
      *"Bloquear")    loginctl lock-session ;;
    esac
  '';
in
{
  options.desktop.bspwm.polybar = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable modern polybar for bspwm";
    };
  };

  config = mkIf cfg.enable {
    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        pulseSupport = true;
        i3Support = false;
      };
      script = ''
        polybar-msg cmd quit 2>/dev/null || true
        pkill -x polybar || true
        while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

        if type xrandr >/dev/null 2>&1; then
          for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload main &
          done
        else
          polybar --reload main &
        fi
      '';
      config = {
        # --- Paleta Catppuccin Mocha ---
        "colors" = {
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
          surface0 = "#313244";
          surface1 = "#45475a";
          surface2 = "#585b70";
          text = "#cdd6f4";
          subtext0 = "#a6adc8";
          subtext1 = "#bac2de";
          blue = "#89b4fa";
          lavender = "#b4befe";
          sapphire = "#74c7ec";
          sky = "#89dceb";
          teal = "#94e2d5";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          peach = "#fab387";
          maroon = "#eba0ac";
          red = "#f38ba8";
          mauve = "#cba6f7";
          flamingo = "#f2cdcd";
          rosewater = "#f5e0dc";
          transparent = "#00000000";
        };

        # --- Barra Principal (Moderna & Elegante) ---
        "bar/main" = {
          width = "100%";
          height = "30";
          radius = 0;
          fixed-center = true;

          background = "\${colors.base}";
          foreground = "\${colors.text}";

          line-size = 2;
          line-color = "\${colors.blue}";

          border-size = 0;
          padding-left = 1;
          padding-right = 1;
          module-margin = 1;

          font-0 = "Inter:weight=SemiBold:size=10;3";
          font-1 = "Symbols Nerd Font:size=12;3";
          font-2 = "JetBrainsMono Nerd Font:weight=Medium:size=10;3";
          font-3 = "Symbols Nerd Font:size=14;4";

          modules-left = "launcher bspwm xwindow";
          modules-center = "media";
          modules-right = "pulseaudio backlight battery network cpu memory date powermenu";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";

          enable-ipc = true;
          wm-restack = "bspwm";
        };

        # --- Lançador de Aplicativos (Spotlight / Rofi) ---
        "module/launcher" = {
          type = "custom/text";
          format = "<label>";
          label = " 󱄅 ";
          label-font = 4;
          label-foreground = "\${colors.blue}";
          label-background = "\${colors.surface0}";
          label-padding = 1;
          click-left = "${pkgs.rofi}/bin/rofi -show drun";
        };

        # --- Workspaces do BSPWM (Pills Dinâmicos com Ícones) ---
        "module/bspwm" = {
          type = "internal/bspwm";
          pin-workspaces = true;
          enable-click = true;
          enable-scroll = true;
          reverse-scroll = false;
          inline-mode = false;

          format = "<label-state> <label-mode>";

          label-focused = "󰮯 %name%";
          label-focused-foreground = "\${colors.base}";
          label-focused-background = "\${colors.blue}";
          label-focused-padding = 2;
          label-focused-margin = 0;

          label-occupied = "󰊠 %name%";
          label-occupied-foreground = "\${colors.text}";
          label-occupied-background = "\${colors.surface0}";
          label-occupied-padding = 2;
          label-occupied-margin = 0;

          label-urgent = "󰀦 %name%";
          label-urgent-foreground = "\${colors.base}";
          label-urgent-background = "\${colors.red}";
          label-urgent-padding = 2;
          label-urgent-margin = 0;

          label-empty = "%name%";
          label-empty-foreground = "\${colors.surface2}";
          label-empty-background = "\${colors.mantle}";
          label-empty-padding = 2;
          label-empty-margin = 0;

          label-monocle = " 󰍉 ";
          label-monocle-foreground = "\${colors.yellow}";
          label-floating = " 󰖲 ";
          label-floating-foreground = "\${colors.peach}";
          label-fullscreen = " 󰊓 ";
          label-fullscreen-foreground = "\${colors.mauve}";
        };

        # --- Título da Janela Ativa ---
        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:35:...%";
          label-foreground = "\${colors.subtext0}";
          label-padding = 1;
        };

        # --- Mídia / Playerctl ---
        "module/media" = {
          type = "custom/script";
          exec = "${mediaScript}";
          interval = 2;
          format = "<label>";
          format-foreground = "\${colors.lavender}";
          label = "%output%";
          click-left = "${pkgs.playerctl}/bin/playerctl play-pause";
          click-right = "${pkgs.playerctl}/bin/playerctl next";
        };

        # --- Uso de CPU ---
        "module/cpu" = {
          type = "internal/cpu";
          interval = 2;
          format = "<label>";
          format-prefix = "󰍛 ";
          format-prefix-foreground = "\${colors.teal}";
          label = "%percentage:2%%";
          label-foreground = "\${colors.text}";
        };

        # --- Uso de Memória ---
        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format = "<label>";
          format-prefix = "󰘚 ";
          format-prefix-foreground = "\${colors.mauve}";
          label = "%percentage_used:2%%";
          label-foreground = "\${colors.text}";
        };

        # --- Volume & Áudio ---
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          use-ui-max = true;
          interval = 2;

          format-volume = "<ramp-volume> <label-volume>";
          label-volume = "%percentage%%";
          label-volume-foreground = "\${colors.text}";

          ramp-volume-0 = "󰕿";
          ramp-volume-1 = "󰖀";
          ramp-volume-2 = "󰕾";
          ramp-volume-foreground = "\${colors.blue}";

          format-muted = "<label-muted>";
          format-muted-prefix = "󰝟 ";
          format-muted-prefix-foreground = "\${colors.red}";
          label-muted = "0%";
          label-muted-foreground = "\${colors.subtext0}";

          click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        # --- Brilho da Tela ---
        "module/backlight" = {
          type = "internal/backlight";
          card = "nv_backlight";
          use-actual-brightness = true;
          enable-scroll = true;

          format = "<ramp> <label>";
          label = "%percentage%%";
          label-foreground = "\${colors.text}";

          ramp-0 = "󰃞";
          ramp-1 = "󰃝";
          ramp-2 = "󰃟";
          ramp-3 = "󰃠";
          ramp-foreground = "\${colors.yellow}";
        };

        # --- Bateria ---
        "module/battery" = {
          type = "internal/battery";
          full-at = 98;
          low-at = 15;
          battery = "BAT0";
          adapter = "ADP1";
          poll-interval = 5;

          format-charging = "<animation-charging> <label-charging>";
          format-discharging = "<ramp-capacity> <label-discharging>";
          format-full = "<ramp-capacity> <label-full>";

          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";
          label-full = "100%";

          ramp-capacity-0 = "󰂎";
          ramp-capacity-1 = "󰁺";
          ramp-capacity-2 = "󰁻";
          ramp-capacity-3 = "󰁼";
          ramp-capacity-4 = "󰁽";
          ramp-capacity-5 = "󰁾";
          ramp-capacity-6 = "󰁿";
          ramp-capacity-7 = "󰂀";
          ramp-capacity-8 = "󰂁";
          ramp-capacity-9 = "󰂂";
          ramp-capacity-10 = "󰁹";
          ramp-capacity-foreground = "\${colors.green}";

          animation-charging-0 = "󰂆";
          animation-charging-1 = "󰂇";
          animation-charging-2 = "󰂈";
          animation-charging-3 = "󰂉";
          animation-charging-4 = "󰂊";
          animation-charging-5 = "󰂋";
          animation-charging-6 = "󰂅";
          animation-charging-foreground = "\${colors.green}";
          animation-charging-framerate = 750;
        };

        # --- Rede (Wi-Fi com Menu Interativo ao Clicar) ---
        "module/network" = {
          type = "internal/network";
          interface-type = "wireless";
          interval = 3;

          format-connected = "<ramp-signal> <label-connected>";
          label-connected = "%essid%";
          label-connected-foreground = "\${colors.text}";

          ramp-signal-0 = "󰤯";
          ramp-signal-1 = "󰤟";
          ramp-signal-2 = "󰤢";
          ramp-signal-3 = "󰤥";
          ramp-signal-4 = "󰤨";
          ramp-signal-foreground = "\${colors.teal}";

          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "󰤮 ";
          format-disconnected-prefix-foreground = "\${colors.red}";
          label-disconnected = "Offline";
          label-disconnected-foreground = "\${colors.subtext0}";

          # Clique abre menu interativo de redes Wi-Fi
          click-left = "${rofiWifiMenu}";
          click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        # --- Data & Hora ---
        "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%d/%m";
          time = "%H:%M";
          date-alt = "%A, %d de %B de %Y";
          time-alt = "%H:%M:%S";

          format = "<label>";
          format-prefix = "󰥔 ";
          format-prefix-foreground = "\${colors.sapphire}";
          label = "%date% %time%";
          label-foreground = "\${colors.text}";
        };

        # --- Botão Power Menu ---
        "module/powermenu" = {
          type = "custom/text";
          format = "<label>";
          label = " 󰐥 ";
          label-font = 4;
          label-foreground = "\${colors.red}";
          label-background = "\${colors.surface0}";
          label-padding = 1;
          click-left = "${rofiPowerMenu}";
        };

        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = false;
        };
      };
    };
  };
}
