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
    desktop.shared.dunst.enable = true;

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
  };
}
