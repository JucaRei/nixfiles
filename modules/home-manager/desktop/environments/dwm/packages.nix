{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm;

  # Script de captura de tela gerenciado via maim + slop (compatível com os atalhos do dwm-titus)
  dwmScreenshot = pkgs.writeShellScriptBin "dwm-screenshot" ''
    set -euo pipefail

    TARGET_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
    mkdir -p "$TARGET_DIR"
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    FILENAME="$TARGET_DIR/Screenshot_$TIMESTAMP.png"

    notify() {
      if command -v ${pkgs.libnotify}/bin/notify-send >/dev/null 2>&1; then
        ${pkgs.libnotify}/bin/notify-send -a "dwm-screenshot" -i camera-photo "Captura de Tela" "$1"
      fi
    }

    # Detecta o monitor sob o cursor do mouse
    active_monitor_geometry() {
      local monitor_list monitor_count
      monitor_list=$(${pkgs.xorg.xrandr}/bin/xrandr --listmonitors 2>/dev/null || true)
      monitor_count=$(awk 'NR == 1 && $1 == "Monitors:" { print $2 }' <<<"$monitor_list")

      if [ -n "$monitor_count" ] && [ "$monitor_count" -gt 1 ]; then
        eval "$(${pkgs.xdotool}/bin/xdotool getmouselocation --shell 2>/dev/null || true)"
        if [ -n "''${X:-}" ] && [ -n "''${Y:-}" ]; then
          while IFS= read -r line; do
            if [[ $line =~ ([0-9]+)/[0-9]+x([0-9]+)/[0-9]+\+([0-9]+)\+([0-9]+) ]]; then
              w=''${BASH_REMATCH[1]}
              h=''${BASH_REMATCH[2]}
              x=''${BASH_REMATCH[3]}
              y=''${BASH_REMATCH[4]}
              if (( X >= x && X < x + w && Y >= y && Y < y + h )); then
                echo "''${w}x''${h}+''${x}+''${y}"
                return 0
              fi
            fi
          done <<< "$monitor_list"
        fi
      fi
      return 1
    }

    case "''${1:-gui}" in
      screen)
        geom=$(active_monitor_geometry || true)
        if [ -n "$geom" ]; then
          ${pkgs.maim}/bin/maim -g "$geom" "$FILENAME"
        else
          ${pkgs.maim}/bin/maim "$FILENAME"
        fi
        notify "Monitor salvo em $FILENAME"
        ;;
      full)
        ${pkgs.maim}/bin/maim "$FILENAME"
        notify "Tela inteira salva em $FILENAME"
        ;;
      gui)
        if ${pkgs.maim}/bin/maim -s "$FILENAME"; then
          notify "Área salva em $FILENAME"
        fi
        ;;
      clip)
        if ${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png; then
          notify "Área copiada para a área de transferência"
        fi
        ;;
      *)
        echo "Uso: dwm-screenshot [screen|gui|clip|full]"
        exit 1
        ;;
    esac
  '';
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Utilitários do DWM
      dmenu
      slstatus
      xdotool
      wmctrl
      xorg.xsetroot
      xorg.xrandr
      xorg.xrdb
      xorg.xinput
      picom
      rofi-power-menu
      brightnessctl
      networkmanagerapplet
      libnotify

      # Wallpaper e Visualização de Imagens
      feh   # Gerenciador de papel de parede
      sxiv  # Visualizador leve de imagens do ecossistema suckless/X11

      # Screenshots gerenciados com maim
      dwmScreenshot
      maim
      slop
      xclip
    ];

    # Associações padrão de mimetypes para imagens usando sxiv
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/png" = [ "sxiv.desktop" ];
        "image/jpeg" = [ "sxiv.desktop" ];
        "image/jpg" = [ "sxiv.desktop" ];
        "image/gif" = [ "sxiv.desktop" ];
        "image/webp" = [ "sxiv.desktop" ];
        "image/bmp" = [ "sxiv.desktop" ];
      };
    };
  };
}
