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

  colors = import ./colors.nix;
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
      ];
      default = "zproger";
      description = "Estilo visual da Polybar: 'zproger'/'pills' (cápsulas flutuantes em pills #2b2f37) ou 'modern' (estilo Waybar / Catppuccin coeso)";
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
    ] ++ lib.optionals cfg.tray.enable [
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
          isPills = cfg.style == "zproger" || cfg.style == "pills";
          hasTray = cfg.tray.enable;
          modernTray = if hasTray then " sep tray" else "";
          pillsTray = if hasTray then " sp round-left tray round-right" else "";

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

            border-size = 1;
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
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard${modernTray} sep date sep powermenu";
          };

          modernPrimaryBar = modernBaseBar // {
            modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "cpu memory temperature disk sep network dots netspeed sep uptime${modernTray}";
          };

          modernSecondaryBar = modernBaseBar // {
            modules-left = "bspwm sep polywins";
            modules-center = "xwindow";
            modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift${modernTray} sep date sep powermenu";
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

            line-size = 2;
            line-color = colors.gray;

            border-size = 1;
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

            cursor-click = "pointer";
            cursor-scroll = "ns-resize";

            enable-ipc = true;
            wm-restack = "bspwm";
            screenchange-reload = true;
          };

          pillsMainBar = pillsBaseBar // {
            modules-left = "launcher sp round-left bspwm round-right sp bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio dots backlight dots battery sep keyboard${pillsTray} sp round-left date round-right sp powermenu";
          };

          pillsPrimaryBar = pillsBaseBar // {
            modules-left = "launcher sp round-left bspwm round-right sp bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "cpu memory temperature disk sep network dots netspeed sep uptime${pillsTray}";
          };

          pillsSecondaryBar = pillsBaseBar // {
            modules-left = "round-left bspwm round-right sp polywins";
            modules-center = "xwindow";
            modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift${pillsTray} sp round-left date round-right sp powermenu";
          };

          # Overrides aplicados aos módulos existentes quando o estilo pills/zproger está ativo.
          # 1. Workspaces com números coloridos pastel (#F9DE8F, #ff9b93, #95e1d3, #81A1C1, #A3BE8C) dentro da cápsula #2b2f37
          # 2. Playerctl/Media no centro, idêntico ao estilo moderno
          # 3. Módulos com ícone único sem duplicações (sem prefixos colidindo com scripts)
          # 4. Relógio dentro da cápsula #2b2f37 com ícone único  em cinza suave #888e96
          pillModuleOverrides = lib.optionalAttrs isPills {
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

              label-focused = "%{T3}%icon%%{T-}";
              label-focused-foreground = colors.text-alt;
              label-focused-underline = colors.gray;
              label-focused-background = colors.pill;
              label-focused-padding = 1;
              label-focused-margin = 0;

              label-occupied = "%{T3}%icon%%{T-}";
              label-occupied-foreground = colors.muted;
              label-occupied-background = colors.pill;
              label-occupied-padding = 1;
              label-occupied-margin = 0;

              label-urgent = "%{T3}%icon%%{T-}";
              label-urgent-foreground = colors.nord;
              label-urgent-background = colors.pill;
              label-urgent-padding = 1;
              label-urgent-margin = 0;

              label-empty = "%{T3}%icon%%{T-}";
              label-empty-foreground = colors.surface1;
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

          /*
            # =========================================================================
            # [CONFIGURAÇÃO ANTERIOR - DESATIVADA, NÃO APAGADA]
            # Conforme solicitado ("não apague como esta agora, somente comente desativando"):
            #
            # "bar/main" = modernMainBar;
            # "bar/primary" = modernPrimaryBar;
            # "bar/secondary" = modernSecondaryBar;
            # =========================================================================
          */

          # --- Definição das Barras Ativas (Alternável via desktop.bspwm.polybar.style: "zproger"/"pills" ou "modern") ---
          "bar/main" = if isPills then pillsMainBar else modernMainBar;
          "bar/primary" = if isPills then pillsPrimaryBar else modernPrimaryBar;
          "bar/secondary" = if isPills then pillsSecondaryBar else modernSecondaryBar;
        };
    };
  };
}
