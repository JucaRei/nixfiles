{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.dunst;
  c = config.desktop.theme.colors;
in
{
  options.desktop.bspwm.dunst = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable dunst notification daemon for bspwm";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.dunst
    ];

    # Recarregar ou iniciar automaticamente o Dunst ao rodar switch-home
    home.activation.reloadDunst = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "$DISPLAY" ]; then
        systemctl --user import-environment DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS 2>/dev/null || true
      fi

      pkill -f notification-daemon 2>/dev/null || true
      pkill -f xfce4-notifyd 2>/dev/null || true
      pkill -f mate-notification-daemon 2>/dev/null || true
      pkill -f mako 2>/dev/null || true

      if command -v dunstctl >/dev/null 2>&1 && dunstctl is-paused >/dev/null 2>&1; then
        $DRY_RUN_CMD dunstctl reload 2>/dev/null || true
      elif [ -x "${pkgs.dunst}/bin/dunstctl" ] && ${pkgs.dunst}/bin/dunstctl is-paused >/dev/null 2>&1; then
        $DRY_RUN_CMD ${pkgs.dunst}/bin/dunstctl reload 2>/dev/null || true
      else
        systemctl --user reset-failed dunst 2>/dev/null || true
        systemctl --user restart dunst 2>/dev/null || true
        sleep 0.2
        if ! ${pkgs.dunst}/bin/dunstctl is-paused >/dev/null 2>&1; then
          if [ -n "$DISPLAY" ] || pgrep -x bspwm >/dev/null 2>&1; then
            pkill -x dunst 2>/dev/null || true
            $DRY_RUN_CMD nohup ${pkgs.dunst}/bin/dunst >/dev/null 2>&1 &
          fi
        fi
      fi
    '';

    # Garantir que o serviço systemd do Dunst passe as variáveis de display e reinicie em caso de falha
    systemd.user.services.dunst = {
      Unit = {
        Description = "Dunst notification daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Restart = "always";
        RestartSec = 2;
        PassEnvironment = [
          "DISPLAY"
          "XAUTHORITY"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "DBUS_SESSION_BUS_ADDRESS"
        ];
      };
    };

    services.dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          font = "Inter 10";
          corner_radius = 12;
          origin = "top-right";
          offset = "(16, 46)";
          follow = "mouse";
          width = 380;
          height = "(0, 240)";
          progress_bar = true;
          progress_bar_height = 8;
          progress_bar_frame_width = 0;
          progress_bar_min_width = 160;
          progress_bar_max_width = 320;
          progress_bar_corner_radius = 4;
          highlight = c.accent;
          frame_width = 2;
          frame_color = c.accent;
          separator_color = "frame";
          gap_size = 8;
          padding = 14;
          horizontal_padding = 14;
          text_icon_padding = 12;
          icon_position = "left";
          min_icon_size = 24;
          max_icon_size = 48;
          mouse_left_click = "do_action, close_current";
          mouse_middle_click = "close_current";
          mouse_right_click = "close_all";
          history_length = 50;
        };

        urgency_low = {
          background = c.bg;
          foreground = c.fg;
          frame_color = c.border;
          timeout = 4;
        };

        urgency_normal = {
          background = c.bg;
          foreground = c.fg;
          frame_color = c.accent;
          timeout = 6;
        };

        urgency_critical = {
          background = c.bg;
          foreground = c.fg;
          frame_color = c.red;
          timeout = 8;
        };

        # Regras com timer automático para Bluetooth e Blueman (desaparecem em 4s sem exigir clique manual)
        bluetooth = {
          appname = "*[Bb]luetooth*";
          timeout = 4;
        };

        blueman = {
          appname = "*[Bb]lueman*";
          timeout = 4;
        };

        bluetooth_stack = {
          stack_tag = "bluetooth-osd";
          timeout = 4;
        };

        bluetooth_summary = {
          summary = "*[Bb]luetooth*";
          timeout = 4;
        };
      };
    };
  };
}
