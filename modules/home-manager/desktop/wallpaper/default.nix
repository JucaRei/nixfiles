# desktop.wallpaper — gerenciador e aplicador agnóstico de papéis de parede.
#
# Suporta X11 (BSPWM, DWM, i3 via feh) e Wayland (MangoWM, Hyprland, Sway via swaybg/hyprpaper/swww).
# No modo random ou multi-monitor, seleciona wallpapers diferentes para cada monitor conectado.
# Suporta rotação automática periódica por timer (systemd timer e modo daemon).
#
# Uso no host (ex: home-manager/hosts/<host>/default.nix):
#   desktop.wallpaper = {
#     enable = true;
#     directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
#     randomOnStart = true;
#     interval = "15m"; # 30s | 5m | 15m | 1h
#     mode = "fill";    # fill | center | tile | scale | max
#   };
{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.desktop.wallpaper;

  # Script agnóstico para definir e gerenciar wallpaper com suporte multi-monitor e timer
  setWallpaperScript = pkgs.writeShellApplication {
    name = "set-wallpaper";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.gawk
      pkgs.procps
      pkgs.libnotify
      pkgs.feh
      pkgs.xrandr
      (nixGLWrapper pkgs.swaybg)
    ];
    runtimeEnv = {
      CONFIGURED_DIR = if cfg.directory != null then cfg.directory else "";
      CONFIGURED_DEFAULT = if cfg.default != null then toString cfg.default else "";
      CONFIGURED_MODE = cfg.mode;
      CONFIGURED_BACKEND = cfg.backend;
      CONFIGURED_INTERVAL = if cfg.interval != null then cfg.interval else "";
    };
    text = builtins.readFile ./scripts/set-wallpaper.sh;
  };

in
{
  options.desktop.wallpaper = {
    enable = mkEnableOption "gerenciador e script agnóstico de wallpaper (X11 / Wayland) com suporte multi-monitor e timer";

    directory = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/home/juca/Pictures/Wallpapers";
      description = "Caminho da pasta de wallpapers no host.";
    };

    default = mkOption {
      type = types.nullOr (types.either types.path types.str);
      default = null;
      example = "/home/juca/Pictures/Wallpapers/default.png";
      description = "Imagem específica padrão (opcional). Se omitido, restaura as últimas ou sorteia da pasta.";
    };

    interval = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "15m";
      description = "Intervalo de tempo para rotacionar o wallpaper automaticamente (ex: '30s', '5m', '15m', '1h'). Se null, não rotaciona por tempo.";
    };

    mode = mkOption {
      type = types.enum [
        "fill"
        "center"
        "tile"
        "scale"
        "max"
      ];
      default = "fill";
      description = "Modo de preenchimento ou ajuste da imagem na tela.";
    };

    backend = mkOption {
      type = types.enum [
        "auto"
        "feh"
        "swaybg"
        "hyprpaper"
        "swww"
        "xfconf"
        "gsettings"
      ];
      default = "auto";
      description = "Backend para aplicar o wallpaper ('auto' detecta o desktop/display server automaticamente).";
    };

    randomOnStart = mkOption {
      type = types.bool;
      default = false;
      description = "Se verdadeiro, sorteia wallpapers aleatórios e diferentes para cada monitor ao iniciar a sessão.";
    };

    autostart = mkOption {
      type = types.bool;
      default = true;
      description = "Iniciar automaticamente ao abrir a sessão gráfica (via XDG autostart).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      setWallpaperScript
      (pkgs.writeShellScriptBin "wallpaper" ''exec ${setWallpaperScript}/bin/set-wallpaper "$@"'')
      pkgs.feh
      (nixGLWrapper pkgs.swaybg)
    ];

    xdg.configFile."autostart/set-wallpaper.desktop" = mkIf cfg.autostart {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Set Wallpaper
        Exec=${setWallpaperScript}/bin/set-wallpaper ${
          if cfg.randomOnStart then "--random" else "--restore"
        } --quiet
        Hidden=false
        NoDisplay=true
        X-GNOME-Autostart-enabled=true
        X-KDE-autostart-phase=1
        Comment=Aplica papel de parede configurado declarativamente
      '';
    };

    # Timer e serviço systemd de rotação periódica quando interval estiver definido
    systemd.user.services.wallpaper-rotate = mkIf (cfg.interval != null) {
      Unit = {
        Description = "Rotacionar papel de parede periodicamente";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${setWallpaperScript}/bin/set-wallpaper --random --quiet";
        PassEnvironment = [
          "DISPLAY"
          "XAUTHORITY"
          "WAYLAND_DISPLAY"
          "XDG_RUNTIME_DIR"
          "XDG_SESSION_TYPE"
          "XDG_CURRENT_DESKTOP"
        ];
      };
    };

    systemd.user.timers.wallpaper-rotate = mkIf (cfg.interval != null) {
      Unit = {
        Description = "Timer para rotação periódica de papel de parede";
        PartOf = [ "graphical-session.target" ];
      };
      Timer = {
        OnUnitActiveSec = cfg.interval;
        OnBootSec = cfg.interval;
      };
      Install = {
        WantedBy = [
          "timers.target"
          "graphical-session.target"
        ];
      };
    };
  };
}
