{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkDefault
    concatMapStringsSep
    optionals
    types
    ;

  cfg = config.desktop;
  backend = config.desktop.display-servers.backend or null;

  rotateMap = {
    "normal" = "normal";
    "90" = "right";
    "180" = "inverted";
    "270" = "left";
    "flipped" = "normal";
    "flipped-90" = "right";
    "flipped-180" = "inverted";
    "flipped-270" = "left";
  };

  transformMap = {
    "normal" = "0";
    "90" = "1";
    "180" = "2";
    "270" = "3";
    "flipped" = "4";
    "flipped-90" = "5";
    "flipped-180" = "6";
    "flipped-270" = "7";
  };

  # Helper para formatar inteiros e floats sem decimais desnecessários (ex: 1 em vez de 1.000000)
  formatNum = n: if (builtins.floor n) == n then toString (builtins.floor n) else toString n;

  hasMonitors = cfg.monitors != [ ];

  # Script universal de inicialização de monitores para Wayland e X11
  setupMonitorsScript = pkgs.writeShellScriptBin "setup-monitors" ''
    set -euo pipefail

    # --- 1. Wayland (wlr-randr / wlroots) ---
    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      if command -v ${pkgs.wlr-randr}/bin/wlr-randr >/dev/null 2>&1; then
        ${concatMapStringsSep "\n        " (m:
          if m.enabled then
            let
              transformArg = if m.transform != "normal" then " --transform ${m.transform}" else "";
            in
            "${pkgs.wlr-randr}/bin/wlr-randr --output ${m.name} --mode ${toString m.width}x${toString m.height}@${formatNum m.refresh}Hz --pos ${toString m.x},${toString m.y} --scale ${formatNum m.scale}${transformArg} 2>/dev/null || true"
          else
            "${pkgs.wlr-randr}/bin/wlr-randr --output ${m.name} --off 2>/dev/null || true"
        ) cfg.monitors}
      fi
    fi

    # --- 2. X11 (xrandr) ---
    if [ -n "''${DISPLAY:-}" ]; then
      if command -v ${pkgs.xrandr}/bin/xrandr >/dev/null 2>&1; then
        ${concatMapStringsSep "\n        " (m:
          if m.enabled then
            let
              rotateArg = if m.transform != "normal" then " --rotate ${rotateMap.${m.transform}}" else "";
              primaryArg = if m.primary then " --primary" else "";
            in
            "${pkgs.xrandr}/bin/xrandr --output ${m.name} --mode ${toString m.width}x${toString m.height} --rate ${formatNum m.refresh} --pos ${toString m.x}x${toString m.y}${rotateArg}${primaryArg} 2>/dev/null || true"
          else
            "${pkgs.xrandr}/bin/xrandr --output ${m.name} --off 2>/dev/null || true"
        ) cfg.monitors}
      fi
    fi
  '';
in
{
  options.desktop = {
    monitors = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "eDP-1";
              description = "Identificador da saída/monitor (ex: eDP-1, HDMI-A-1, DP-1, Virtual-1)";
            };

            width = mkOption {
              type = types.int;
              default = 1920;
              example = 1366;
              description = "Largura em pixels da resolução nativa ou desejada";
            };

            height = mkOption {
              type = types.int;
              default = 1080;
              example = 768;
              description = "Altura em pixels da resolução nativa ou desejada";
            };

            refresh = mkOption {
              type = types.either types.int types.float;
              default = 60;
              example = 60;
              description = "Taxa de atualização em Hz";
            };

            x = mkOption {
              type = types.int;
              default = 0;
              description = "Posição X horizontal no canvas de monitores";
            };

            y = mkOption {
              type = types.int;
              default = 0;
              description = "Posição Y vertical no canvas de monitores";
            };

            scale = mkOption {
              type = types.either types.int types.float;
              default = 1.0;
              description = "Fator de escala de renderização (DPI scale)";
            };

            primary = mkOption {
              type = types.bool;
              default = false;
              description = "Define se o monitor é primário (relevante no X11/xrandr)";
            };

            enabled = mkOption {
              type = types.bool;
              default = true;
              description = "Se o monitor está ativo e habilitado";
            };

            transform = mkOption {
              type = types.enum [
                "normal"
                "90"
                "180"
                "270"
                "flipped"
                "flipped-90"
                "flipped-180"
                "flipped-270"
              ];
              default = "normal";
              description = "Rotação e orientação da tela";
            };
          };
        }
      );
      default = [ ];
      description = "Lista declarativa de monitores e resoluções unificada para todos os ambientes de desktop e WMs";
    };

    monitorsFontRendering = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Otimizar nitidez de renderização de fontes (subpixel RGB + slight hinting + RGBA antialiasing)";
      };
    };
  };

  config = {
    # --------------------------------------------------------------------------
    # 1. Integração com MangoWM (Wayland Compositor)
    # --------------------------------------------------------------------------
    desktop.mangowm.monitorRules = mkIf (hasMonitors && (config.desktop.mangowm.enable or false)) (
      mkDefault (
        map (
          m:
          if m.enabled then
            "name:${m.name},width:${toString m.width},height:${toString m.height},refresh:${formatNum m.refresh},x:${toString m.x},y:${toString m.y},scale:${formatNum m.scale}"
          else
            "name:${m.name},disable:1"
        ) cfg.monitors
      )
    );

    # --------------------------------------------------------------------------
    # 2. Integração com Hyprland (Wayland Compositor)
    # --------------------------------------------------------------------------
    desktop.hyprland.monitors = mkIf (hasMonitors && (config.desktop.hyprland.enable or false)) (
      mkDefault (
        map (
          m:
          if m.enabled then
            let
              transformArg =
                if m.transform != "normal" then ", transform, ${transformMap.${m.transform}}" else "";
            in
            "${m.name}, ${toString m.width}x${toString m.height}@${formatNum m.refresh}, ${toString m.x}x${toString m.y}, ${formatNum m.scale}${transformArg}"
          else
            "${m.name}, disable"
        ) cfg.monitors
      )
    );

    # --------------------------------------------------------------------------
    # 3. Integração com Kanshi (Wayland Output Management Daemon)
    # --------------------------------------------------------------------------
    services.kanshi = mkIf (hasMonitors && backend == "wayland") {
      enable = mkDefault true;
      systemdTarget = "graphical-session.target";
      settings = [
        {
          profile.name = "default";
          profile.outputs = map (m: {
            criteria = m.name;
            mode = "${toString m.width}x${toString m.height}@${formatNum m.refresh}Hz";
            position = "${toString m.x},${toString m.y}";
            scale = m.scale;
            status = if m.enabled then "enable" else "disable";
          }) cfg.monitors;
        }
      ];
    };

    # --------------------------------------------------------------------------
    # 4. Integração com X11 / BSPWM / XFCE4 / Sessões Xorg
    # --------------------------------------------------------------------------
    xsession.initExtra = mkIf hasMonitors (
      let
        xrandrCommands = concatMapStringsSep "\n" (
          m:
          if m.enabled then
            let
              rotateArg = if m.transform != "normal" then " --rotate ${rotateMap.${m.transform}}" else "";
              primaryArg = if m.primary then " --primary" else "";
            in
            "${pkgs.xrandr}/bin/xrandr --output ${m.name} --mode ${toString m.width}x${toString m.height} --rate ${formatNum m.refresh} --pos ${toString m.x}x${toString m.y}${rotateArg}${primaryArg} 2>/dev/null || true"
          else
            "${pkgs.xrandr}/bin/xrandr --output ${m.name} --off 2>/dev/null || true"
        ) cfg.monitors;
      in
      ''
        # --- Configuração declarativa de monitores (desktop.monitors) ---
        ${xrandrCommands}
      ''
    );

    # --------------------------------------------------------------------------
    # 5. Utilitários no PATH e Autostart para Full Desktop Environments (GNOME, KDE, XFCE4)
    # --------------------------------------------------------------------------
    home.packages =
      optionals hasMonitors [ setupMonitorsScript ]
      ++ optionals (hasMonitors && (backend == "x11" || config.xsession.enable)) [
        pkgs.xrandr
      ]
      ++ optionals (hasMonitors && (backend == "wayland")) [
        pkgs.wlr-randr
      ];

    xdg.configFile."autostart/setup-monitors.desktop" = mkIf hasMonitors {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Setup Monitors
        Exec=${setupMonitorsScript}/bin/setup-monitors
        Hidden=false
        NoDisplay=true
        X-GNOME-Autostart-enabled=true
        X-KDE-autostart-phase=1
        Comment=Aplica resolução e layout de tela configurados declarativamente
      '';
    };

    # --------------------------------------------------------------------------
    # 6. Otimização de Renderização de Fontes para Monitores (Fontconfig & GTK DConf)
    # --------------------------------------------------------------------------
    fonts.fontconfig = mkIf cfg.monitorsFontRendering.enable {
      enable = mkDefault true;
      antialiasing = mkDefault true;
      hinting = mkDefault "slight";
      subpixelRendering = mkDefault "rgb";
    };

    dconf.settings = mkIf cfg.monitorsFontRendering.enable {
      "org/gnome/desktop/interface" = {
        font-antialiasing = mkDefault "rgba";
        font-hinting = mkDefault "slight";
        font-rgba-order = mkDefault "rgb";
      };
    };
  };
}
