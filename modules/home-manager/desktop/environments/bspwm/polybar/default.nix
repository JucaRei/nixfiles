{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool str;
  cfg = config.desktop.bspwm.polybar;

  colors = import ./colors.nix { theme = config.desktop.theme; };
  polybarPkg = pkgs.polybar.override {
    pulseSupport = true;
    i3Support = false;
  };
  scripts = import ./scripts.nix {
    inherit pkgs colors;
    polybar = polybarPkg;
  };
  polybarModules = import ./modules.nix {
    inherit
      lib
      pkgs
      colors
      scripts
      cfg
      ;
  };
in
{
  options.desktop.bspwm.polybar = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable modular Polybar for bspwm";
    };

    style = mkOption {
      type = lib.types.enum [
        "modern"
        "zproger"
        "pills"
        "shapes"
      ];
      default = "zproger";
      description = "Estilo visual da Polybar: 'zproger'/'pills' (cápsulas flutuantes em pills #2b2f37), 'shapes' (estilo shapes / pixelated squares / como no debian-bspwm-e300) ou 'modern' (estilo Waybar / Catppuccin coeso)";
    };

    encapsulation = mkOption {
      type =
        lib.types.coercedTo
          (lib.types.enum [
            "pill"
            "shapes"
            "slant"
            "powerline"
          ])
          (val: {
            default = val;
            workspaces = "default";
            date = "default";
            tray = "default";
          })
          (
            lib.types.submodule {
              options = {
                default = mkOption {
                  type = lib.types.enum [
                    "pill"
                    "shapes"
                    "slant"
                    "powerline"
                  ];
                  default = "pill";
                  description = "Encapsulamento padrão para todas as cápsulas";
                };

                workspaces = mkOption {
                  type = lib.types.enum [
                    "default"
                    "pill"
                    "shapes"
                    "slant"
                    "powerline"
                  ];
                  default = "default";
                  description = "Encapsulamento específico da cápsula de workspaces (ou 'default' para herdar)";
                };

                date = mkOption {
                  type = lib.types.enum [
                    "default"
                    "pill"
                    "shapes"
                    "slant"
                    "powerline"
                  ];
                  default = "default";
                  description = "Encapsulamento específico da cápsula de data/relógio (ou 'default' para herdar)";
                };

                tray = mkOption {
                  type = lib.types.enum [
                    "default"
                    "pill"
                    "shapes"
                    "slant"
                    "powerline"
                  ];
                  default = "default";
                  description = "Encapsulamento específico da cápsula da bandeja (ou 'default' para herdar)";
                };
              };
            }
          );
      default = "pill";
      description = ''
        Formato de encapsulamento das cápsulas. Pode ser uma string direta ("pill", "shapes", "slant", "powerline")
        ou uma configuração granular para misturar estilos:
          {
            default = "pill";
            workspaces = "shapes"; # usa  e  nos workspaces
            date = "pill";         # usa  e  no relógio
          }
        Também é possível usar diretamente os módulos 'round-left'/'round-right', 'shape-left'/'shape-right',
        'slant-left'/'slant-right' ou 'powerline-left'/'powerline-right' na lista de módulos das barras.
      '';
    };

    battery = mkOption {
      type = str;
      default = "BAT0";
      description = "Nome do dispositivo da bateria em /sys/class/power_supply";
    };

    adapter = mkOption {
      type = str;
      default = "ADP1";
      description = "Nome do adaptador AC em /sys/class/power_supply";
    };

    tray = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Habilitar módulo e serviço de bandeja do sistema (Stalonetray) na Polybar";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      polybarPkg
      (pkgs.writeShellScriptBin "rofi-bluetooth" ''exec ${scripts.rofiBluetoothMenu} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-bluetooth" ''exec ${scripts.rofiBluetoothMenu} "$@"'')
      (pkgs.writeShellScriptBin "rofi-wifi-menu" ''exec ${scripts.rofiWifiMenu} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-wifi" ''exec ${scripts.rofiWifiMenu} "$@"'')
      (pkgs.writeShellScriptBin "rofi-bsp-layout" ''exec ${scripts.rofiLayoutMenu} "$@"'')
      (pkgs.writeShellScriptBin "bsp-layout-switch" ''exec ${scripts.bspLayoutSwitchScript} "$@"'')
      (pkgs.writeShellScriptBin "polybar-os-logo" ''exec ${scripts.osLogoScript} "$@"'')
      (pkgs.writeShellScriptBin "polybar-launch" ''exec ${scripts.polybarLaunchScript} "$@"'')
      (pkgs.writeShellScriptBin "polybar-media-control" ''exec ${scripts.mediaControlScript} "$@"'')
      (pkgs.writeShellScriptBin "rofi-notifications" ''exec ${scripts.rofiNotificationMenu} "$@"'')
      (pkgs.writeShellScriptBin "polybar-notifications" ''exec ${scripts.notificationStatusScript} "$@"'')
    ]
    ++ lib.optionals cfg.tray.enable [
      pkgs.stalonetray
      (pkgs.writeShellScriptBin "stalonetray-toggle" ''exec ${scripts.stalonetrayToggleScript} "$@"'')
    ];

    # Serviços do Stalonetray (apenas se bandeja habilitada na Polybar)
    services.stalonetray = mkIf cfg.tray.enable {
      enable = true;
      package = pkgs.stalonetray;
      config = {
        background = "#2b2f37";
        decorations = "none";
        dockapp_mode = "none";
        geometry = "5x1-16+44";
        max_geometry = "8x1-16+44";
        grow_gravity = "NW";
        icon_gravity = "NE";
        icon_size = 20;
        slot_size = 24;
        sticky = true;
        skip_taskbar = true;
        window_type = "dock";
        window_layer = "top";
        kludges = "force_icons_size";
        ignore_classes = "nm-applet Nm-applet blueman-applet Blueman-applet blueman-tray Blueman-tray fcitx fcitx5 Fcitx5 solaar Solaar";
      };
    };

    # Recarregar automaticamente o Stalonetray ao rodar switch-home se habilitado
    home.activation.reloadStalonetray = mkIf (cfg.tray.enable && config.services.stalonetray.enable) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD systemctl --user restart stalonetray 2>/dev/null || (${pkgs.procps}/bin/pkill -x stalonetray 2>/dev/null && ${pkgs.stalonetray}/bin/stalonetray 2>/dev/null || true) &
      ''
    );

    # Recarregar automaticamente a Polybar ao rodar switch-home
    home.activation.reloadPolybar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v polybar-launch >/dev/null 2>&1; then
        $DRY_RUN_CMD polybar-launch 2>/dev/null || true
      else
        $DRY_RUN_CMD ${polybarPkg}/bin/polybar-msg cmd restart 2>/dev/null || true
      fi
    '';

    services.polybar = {
      enable = true;
      package = polybarPkg;
      script = ''
        exec ${scripts.polybarLaunchScript}
      '';
      config =
        let
          isPills = cfg.style == "zproger" || cfg.style == "pills" || cfg.style == "shapes";
          hasTray = cfg.tray.enable;

          # Resolução do tipo de encapsulamento por módulo (permite misturar livremente)
          rawDefaultEncap =
            if builtins.isAttrs cfg.encapsulation then
              cfg.encapsulation.default
            else if cfg.encapsulation != "pill" then
              cfg.encapsulation
            else if cfg.style == "shapes" then
              "shapes"
            else
              "pill";

          resolveEncap =
            specific:
            let
              s =
                if builtins.isAttrs cfg.encapsulation then
                  (cfg.encapsulation.${specific} or "default")
                else
                  "default";
            in
            if s != "default" then s else rawDefaultEncap;

          wsEncap = resolveEncap "workspaces";
          dateEncap = resolveEncap "date";
          trayEncap = resolveEncap "tray";

          # Normalizar prefixo do módulo (shapes -> shape, pill -> round)
          normalizeEncap =
            e:
            if e == "shapes" then
              "shape"
            else if e == "pill" then
              "round"
            else
              e;

          wsLeft = "${normalizeEncap wsEncap}-left";
          wsRight = "${normalizeEncap wsEncap}-right";
          dateLeft = "${normalizeEncap dateEncap}-left";
          dateRight = "${normalizeEncap dateEncap}-right";
          trayLeft = "${normalizeEncap trayEncap}-left";
          trayRight = "${normalizeEncap trayEncap}-right";

          modernTray = if hasTray then " sep tray" else "";
          pillsTray = if hasTray then " sp ${trayLeft} tray ${trayRight}" else "";

          # =========================================================================
          # ESTILO 1: MODERNO (WAYBAR / CATPPUCCIN COESO)
          # =========================================================================
          modernBaseBar = {
            monitor = "\${env:MONITOR:}";
            width = "99.2%";
            offset-x = "0.4%";
            offset-y = 6;
            height = 32;
            radius = 10;
            fixed-center = true;

            background = colors.base;
            foreground = colors.text;

            line-size = 2;
            line-color = colors.blue;

            border-size = 0;
            border-color = colors.surface0;
            padding-left = 2;
            padding-right = 2;
            module-margin = 0;

            font-0 = "Inter:weight=SemiBold:size=10;3";
            font-1 = "Symbols Nerd Font:size=11;3";
            font-2 = "JetBrainsMono Nerd Font:weight=Medium:size=10;3";
            font-3 = "Symbols Nerd Font:size=13;3"; # Ícone do lançador e power
            font-4 = "Symbols Nerd Font:size=15;4"; # Glyphs das cápsulas  e  (mantidas para compatibilidade)
            font-5 = "Symbols Nerd Font Mono:size=11;3";
            font-6 = "Noto Sans CJK JP:weight=Medium:size=10;2"; # Kanji (Workspaces 一 二 三 四 五 六 七 八 九 十)
            font-7 = "IPAGothic:size=10;2";
            font-8 = "Noto Sans CJK SC:weight=Medium:size=10;2";

            # --- Layout Moderno Coeso (Inspirado no Waybar do Hyprland / MangoWM) ---
            modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
            modules-center = "media";

            cursor-click = "pointer";
            cursor-scroll = "ns-resize";

            enable-ipc = true;
            wm-restack = "bspwm";
            screenchange-reload = true;
          };

          modernMainBar = modernBaseBar // {
            modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
            modules-center = "media";
            # modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard dots notifications${modernTray} sep date sep powermenu";
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard dots notifications sep date sep powermenu";
          };

          modernPrimaryBar = modernBaseBar // {
            modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "cpu memory temperature disk sep network dots netspeed sep uptime";
          };

          modernSecondaryBar = modernBaseBar // {
            modules-left = "bspwm sep polywins";
            modules-center = "xwindow";
            # modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications${modernTray} sep date sep powermenu";
            modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications sep date sep powermenu";
          };

          # =========================================================================
          # ESTILO 2: ZPROGER / PILLS (https://github.com/Zproger/bspwm-dotfiles)
          # Flutuante, cápsulas arredondadas (#2b2f37) para workspaces e relógio,
          # com dimensões 100% uniformes ao estilo moderno e paleta vibrante pastel.
          # =========================================================================
          pillsBaseBar = {
            monitor = "\${env:MONITOR:}";
            width = "99.2%";
            offset-x = "0.4%";
            offset-y = 6;
            height = 32;
            radius = 10;
            fixed-center = true;
            bottom = false;

            background = colors.dark;
            foreground = colors.text-alt;

            line-size = 0;
            line-color = colors.gray;

            border-size = 0;
            border-color = colors.pill;
            padding-left = 2;
            padding-right = 2;
            module-margin = 0;

            font-0 = "Inter:weight=SemiBold:size=10;3";
            font-1 = "Symbols Nerd Font:size=11;3";
            font-2 = "JetBrainsMono Nerd Font:weight=Bold:size=11;3"; # T3: Números dos workspaces (sutilmente maior que 10)
            font-3 = "Symbols Nerd Font:size=13;3"; # Ícone do lançador e power
            font-4 = "JetBrainsMono Nerd Font:size=24;6"; # Glyphs das cápsulas  e  (T5 - preenchimento vertical contínuo de 32px)
            font-5 = "Symbols Nerd Font Mono:size=11;3";
            font-6 = "Noto Sans CJK JP:weight=Medium:size=10;2";
            font-7 = "IPAGothic:size=10;2";
            font-8 = "Noto Sans CJK SC:weight=Medium:size=10;2";
            font-9 = "Symbols Nerd Font:size=5;9"; # T10: Ponto indicador rebaixado abaixo do número

            cursor-click = "pointer";
            cursor-scroll = "ns-resize";

            enable-ipc = true;
            wm-restack = "bspwm";
            screenchange-reload = true;
          };

          pillsMainBar = pillsBaseBar // {
            modules-left = "launcher sp ${wsLeft} bspwm ${wsRight} sp bsp-layout sep polywins minimized";
            modules-center = "media";
            # modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots notifications${pillsTray} sp ${dateLeft} date ${dateRight} sp powermenu";
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots notifications sp ${dateLeft} date ${dateRight} sp powermenu";
          };

          pillsPrimaryBar = pillsBaseBar // {
            modules-left = "launcher sp ${wsLeft} bspwm ${wsRight} sp bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "shape-left sp cpu memory temperature disk shape-right sep network dots netspeed sep uptime";
          };

          pillsSecondaryBar = pillsBaseBar // {
            modules-left = "${wsLeft} bspwm ${wsRight} sp polywins";
            modules-center = "xwindow";
            # modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications${pillsTray} sp ${dateLeft} date ${dateRight} sp powermenu";
            modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications sp ${dateLeft} date ${dateRight} sp powermenu";
          };

          # Overrides aplicados aos módulos existentes quando o estilo pills/zproger ou shapes está ativo.
          # 1. Workspaces com números coloridos pastel (#F9DE8F, #ff9b93, #95e1d3, #81A1C1, #A3BE8C) dentro da cápsula #2b2f37
          # 2. Playerctl/Media no centro, idêntico ao estilo moderno
          # 3. Módulos com ícone único sem duplicações (sem prefixos colidindo com scripts)
          # 4. Relógio dentro da cápsula #2b2f37 com ícone único  em cinza suave #888e96
          pillModuleOverrides =
            lib.optionalAttrs isPills {
              "module/bspwm" = {
                ws-icon-0 = "1;%{F${colors.yellow-alt}}1%{F-}";
                ws-icon-1 = "2;%{F${colors.coral}}2%{F-}";
                ws-icon-2 = "3;%{F${colors.mint}}3%{F-}";
                ws-icon-3 = "4;%{F${colors.nord}}4%{F-}";
                ws-icon-4 = "5;%{F${colors.green-alt}}5%{F-}";
                ws-icon-5 = "6;%{F${colors.yellow-alt}}6%{F-}";
                ws-icon-6 = "7;%{F${colors.coral}}7%{F-}";
                ws-icon-7 = "8;%{F${colors.mint}}8%{F-}";
                ws-icon-8 = "9;%{F${colors.nord}}9%{F-}";
                ws-icon-9 = "0;%{F${colors.green-alt}}10%{F-}";
                ws-icon-10 = "10;%{F${colors.green-alt}}10%{F-}";
                ws-icon-default = "%name%";

                # Workspace focado: Pac-Man (󰮯) no workspace ativo mantendo o número colorido e cápsula elevada
                label-focused = "%{T2}%{F${colors.yellow-alt}}󰮯 %{F-}%{T-}%{T3}%icon%%{T-}";
                label-focused-foreground = colors.text;
                label-focused-background = colors.pill-alt;
                label-focused-padding = 1;
                label-focused-margin = 0;

                # Workspace ocupado (com janelas): número colorido pastel no fundo padrão
                label-occupied = "%{T3}%icon%%{T-}";
                label-occupied-foreground = colors.text;
                label-occupied-background = colors.pill;
                label-occupied-padding = 1;
                label-occupied-margin = 0;

                # Workspace com urgência / alerta: fantasma do Pac-Man (󰊠) em vermelho
                label-urgent = "%{T2}%{F${colors.red}}󰊠 %{F-}%{T-}%{T3}%icon%%{T-}";
                label-urgent-foreground = colors.nord;
                label-urgent-background = colors.pill;
                label-urgent-padding = 1;
                label-urgent-margin = 0;

                # Workspace vazio: número atenuado e sutil (%name%), sem cor de ícone ativa
                label-empty = "%{T3}%name%%{T-}";
                label-empty-foreground = colors.muted;
                label-empty-background = colors.pill;
                label-empty-padding = 1;
                label-empty-margin = 0;

                label-separator = "";
                label-separator-background = colors.pill;
              };

              "module/cpu" = {
                format = "<label>";
                format-prefix = " ";
                format-prefix-foreground = colors.purple;
                label = "%percentage%%";
                label-foreground = colors.text-alt;
                label-padding = 0;
              };

              "module/memory" = {
                format = "<label>";
                format-prefix = " ";
                format-prefix-foreground = colors.orange;
                label = "%percentage_used%%";
                label-foreground = colors.text-alt;
                label-padding = 0;
              };

              "module/temperature" = {
                type = "internal/temperature";
                thermal-zone = 0;
                warn-temperature = 75;
                format = "<ramp> <label>";
                format-warn = "<ramp> <label-warn>";
                format-padding = 0;
                label = "%temperature-c%";
                label-warn = "%temperature-c%";
                label-foreground = colors.text-alt;
                ramp-0 = "";
                ramp-foreground = colors.ice;
              };

              "module/pulseaudio" = {
                label-foreground = colors.red-alt;
              };

              "module/bluetooth" = {
                label-foreground = colors.blue-alt;
              };

              "module/backlight" = {
                format = "<label>";
                format-prefix = "";
              };

              "module/battery" = {
                ramp-capacity-foreground = colors.bat-green;
                animation-charging-foreground = colors.bat-charging;
                label-charging-foreground = colors.text-alt;
                label-discharging-foreground = colors.text-alt;
                label-full-foreground = colors.text-alt;
              };

              "module/keyboard" = {
                format-prefix-foreground = colors.text-alt;
                label-layout-foreground = colors.text-alt;
              };

              "module/date" = {
                interval = 1;
                format = "<label>";
                format-prefix = "";
                format-prefix-foreground = colors.pill;
                format-background = colors.pill;
                date = "%{F${colors.time-alt}}  %H:%M:%S%{F-}";
                date-alt = "%{F${colors.blue-alt}}  %a, %d %b %Y  %{F${colors.time-alt}}  %H:%M:%S%{F-}";
                time = "";
                time-alt = "";
                label = "%date%";
                label-foreground = colors.time-alt;
                label-background = colors.pill;
                label-padding = 1;
              };

              "module/network" = {
                label-foreground = colors.green-alt;
              };

              "module/netspeed" = {
                label-foreground = colors.nord;
              };

              "module/disk" = {
                format-mounted-prefix-foreground = colors.orange;
                label-mounted-foreground = colors.text-alt;
              };

              "module/uptime" = {
                label-foreground = colors.mint;
              };

              "module/bsp-layout" = {
                label-foreground = colors.coral;
              };

              "module/media" = {
                label-foreground = colors.purple;
              };

              "module/minimized" = {
                label-foreground = colors.yellow-alt;
              };

              "module/powermenu" = {
                label = "";
                label-foreground = colors.red-alt;
              };

              "module/notifications" = {
                label-foreground = colors.text-alt;
              };
            }
            // lib.optionalAttrs hasTray {
              "module/tray" = {
                format-background = colors.pill;
                label-background = colors.pill;
                label-foreground = colors.blue-alt;
              };
            };
        in
        (lib.recursiveUpdate polybarModules pillModuleOverrides)
        // {
          "colors" = colors;

          # --- Definição das Barras Ativas (Alternável via desktop.bspwm.polybar.style: "zproger"/"pills"/"shapes" ou "modern") ---
          "bar/main" = if isPills then pillsMainBar else modernMainBar;
          "bar/primary" = if isPills then pillsPrimaryBar else modernPrimaryBar;
          "bar/secondary" = if isPills then pillsSecondaryBar else modernSecondaryBar;
        };
    };
  };
}
