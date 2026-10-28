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

  encapStyleEnum = [
    "pill"
    "shapes"
    "slant"
    "powerline"
  ];

  encapStyleWithDefaultEnum = [ "default" ] ++ encapStyleEnum;

  # Submódulo flexível para cada cápsula: aceita string de estilo ou attrset com { style, color, accent }
  mkEncapModuleType =
    {
      defaultStyle ? "default",
      allowDefault ? true,
      description ? "Configuração de estilo, cor de fundo e cor de destaque do encapsulamento",
    }:
    let
      validStyles = if allowDefault then encapStyleWithDefaultEnum else encapStyleEnum;
      submoduleType = lib.types.submodule {
        options = {
          style = mkOption {
            type = lib.types.enum validStyles;
            default = defaultStyle;
            description = "Estilo geométrico do encapsulamento ('pill', 'shapes', 'slant', 'powerline'${
              if allowDefault then ", ou 'default' para herdar" else ""
            })";
          };

          color = mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta como 'pill', 'surface', 'red', ou código HEX direto como '#29339B' ou '29339B')";
          };

          accent = mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula (nome da paleta ou código HEX direto como '#FF5555' ou 'FF5555')";
          };
        };
      };
    in
    lib.types.coercedTo (lib.types.enum validStyles) (val: {
      style = val;
      color = null;
      accent = null;
    }) submoduleType;
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
      description = "Estilo visual da Polybar: 'zproger'/'pills' (cápsulas flutuantes em pills), 'shapes' (estilo shapes / pixelated squares / como no debian-bspwm-e300) ou 'modern' (estilo Waybar / Catppuccin coeso)";
    };

    encapsulation = mkOption {
      type =
        lib.types.coercedTo (lib.types.enum encapStyleEnum)
          (val: {
            default = {
              style = val;
              color = null;
              accent = null;
            };
            workspaces = "default";
            stats = "default";
            netspeed = "default";
            date = "default";
            tray = "default";
            color = null;
            accent = null;
            colors = { };
          })
          (
            lib.types.submodule {
              options = {
                default = mkOption {
                  type = mkEncapModuleType {
                    defaultStyle = "pill";
                    allowDefault = false;
                    description = "Encapsulamento padrão herdado por todas as cápsulas";
                  };
                  default = "pill";
                  description = "Encapsulamento padrão herdado por todas as cápsulas (pode ser string 'pill'/'shapes'/'slant'/'powerline' ou attrset { style, color, accent })";
                };

                workspaces = mkOption {
                  type = mkEncapModuleType {
                    defaultStyle = "default";
                    allowDefault = true;
                    description = "Encapsulamento da cápsula de workspaces";
                  };
                  default = "default";
                  description = "Encapsulamento específico da cápsula de workspaces (string ou { style, color, accent })";
                };

                stats = mkOption {
                  type = mkEncapModuleType {
                    defaultStyle = "default";
                    allowDefault = true;
                    description = "Encapsulamento da cápsula de métricas/hardware (cpu, ram, temp, disk)";
                  };
                  default = "default";
                  description = "Encapsulamento específico da cápsula de métricas/hardware (string ou { style, color, accent })";
                };

                netspeed = mkOption {
                  type = mkEncapModuleType {
                    defaultStyle = "default";
                    allowDefault = true;
                    description = "Encapsulamento da cápsula de velocidade de rede (netspeed)";
                  };
                  default = "default";
                  description = "Encapsulamento específico da cápsula de velocidade de rede (string ou { style, color, accent })";
                };

                date = mkOption {
                  type = mkEncapModuleType {
                    defaultStyle = "default";
                    allowDefault = true;
                    description = "Encapsulamento da cápsula de data/relógio";
                  };
                  default = "default";
                  description = "Encapsulamento específico da cápsula de data/relógio (string ou { style, color, accent })";
                };

                tray = mkOption {
                  type = mkEncapModuleType {
                    defaultStyle = "default";
                    allowDefault = true;
                    description = "Encapsulamento da cápsula da bandeja (stalonetray)";
                  };
                  default = "default";
                  description = "Encapsulamento específico da cápsula da bandeja (string ou { style, color, accent })";
                };

                color = mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Cor de fundo padrão global para todas as cápsulas (nome da paleta ou HEX direto com ou sem '#')";
                };

                accent = mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Cor de destaque padrão global para todas as cápsulas (nome da paleta ou HEX direto com ou sem '#')";
                };

                colors = mkOption {
                  type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.nullOr lib.types.str));
                  default = { };
                  description = ''
                    Cores customizadas opcionais para os glifos, fundos e destaques das cápsulas.
                    Chaves suportadas:
                    - glyph: cor padrão dos glifos e fundos (ex: "pill", "red", "shade1", "#29339B")
                    - accent: cor de destaque padrão global (ex: "red", "accent", "#ff5555")
                    - workspaces: cor de fundo e glifos da cápsula de workspaces
                    - workspacesAccent / focused: cor de destaque do workspace ativo (ex: "red", "coral", "#ff5555")
                    - focusedNumber: cor do número do workspace quando focado/ativo (ex: "dark", "bgDark")
                    - stats: cor de fundo e glifos da cápsula de métricas (cpu, memory, temp, disk)
                    - statsAccent: cor de destaque dos ícones de hardware (cpu, ram, temp, disk)
                    - netspeed: cor de fundo e glifos da cápsula de velocidade de rede (netspeed)
                    - netspeedAccent: cor de destaque do texto da velocidade de rede
                    - date: cor de fundo e glifos da cápsula de data/relógio
                    - dateAccent: cor de destaque dos ícones e textos da data/relógio
                    - tray: cor de fundo e glifos da cápsula da bandeja
                    - trayAccent: cor de destaque da bandeja
                  '';
                };
              };
            }
          );
      default = "pill";
      description = ''
        Formato de encapsulamento e estilização de cores e destaques das cápsulas.
        Pode ser uma string direta ("pill", "shapes", "slant", "powerline")
        ou uma configuração granular especificando estilo, cor de fundo e cor de destaque:
          {
            default = "pill";
            accent = "#ff5555"; # Cor de destaque global padrão
            workspaces = {
              style = "powerline";
              accent = "#ff5555"; # Destaque do workspace ativo (nome da paleta ou HEX direto)
            };
            stats = {
              style = "shapes";
              color = "#1e1e2e";
              accent = "mint";    # Ícones de hardware (cpu, mem, temp, disk) destacados em mint
            };
            netspeed = {
              style = "slant";
              color = "#29339B";  # Fundo customizado da cápsula de velocidade de rede
              accent = "#8be9fd"; # Velocidade de rede em destaque ciano
            };
            date = {
              style = "pill";
              accent = "coral";   # Relógio e calendário em destaque coral
            };
            colors = {
              focusedNumber = "dark"; # Cor suave do número quando focado
            };
          }
        Também é possível usar diretamente os módulos 'round-left'/'round-right', 'shape-left'/'shape-right',
        'slant-left'/'slant-right', 'powerline-left'/'powerline-right' (ou suas variantes coloridas como 'shape-left-red') na lista de módulos das barras.
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
      scripts.rofiBluetoothMenuPkg
      (pkgs.writeShellScriptBin "bspwm-bluetooth" ''exec ${scripts.rofiBluetoothMenu} "$@"'')
      scripts.rofiWifiMenuPkg
      (pkgs.writeShellScriptBin "bspwm-wifi" ''exec ${scripts.rofiWifiMenu} "$@"'')
      scripts.rofiLayoutMenuPkg
      scripts.bspLayoutSwitchScriptPkg
      scripts.osLogoScriptPkg
      scripts.polybarLaunchScriptPkg
      scripts.mediaControlScriptPkg
      scripts.rofiNotificationMenuPkg
      scripts.notificationStatusScriptPkg
      (pkgs.writeShellScriptBin "polybar-notifications" ''exec ${scripts.notificationStatusScript} "$@"'')
    ]
    ++ lib.optionals cfg.tray.enable [
      pkgs.stalonetray
      scripts.stalonetrayToggleScriptPkg
    ];

    # Serviços do Stalonetray (apenas se bandeja habilitada na Polybar)
    services.stalonetray = mkIf cfg.tray.enable {
      enable = true;
      package = pkgs.stalonetray;
      config = {
        background = colors.surface;
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

          # Resolução e normalização granular de cada encapsulamento (style, color, accent)
          normalizeEncap =
            item: defaultStyle:
            if builtins.isAttrs item then
              {
                style = if (item.style or "default") != "default" then item.style else defaultStyle;
                color = item.color or null;
                accent = item.accent or null;
              }
            else if builtins.isString item && item != "default" then
              {
                style = item;
                color = null;
                accent = null;
              }
            else
              {
                style = defaultStyle;
                color = null;
                accent = null;
              };

          baseDefaultStyle = if cfg.style == "shapes" then "shapes" else "pill";

          defaultEncapObj =
            if builtins.isAttrs cfg.encapsulation then
              normalizeEncap (cfg.encapsulation.default or baseDefaultStyle) baseDefaultStyle
            else if builtins.isString cfg.encapsulation && cfg.encapsulation != "pill" then
              normalizeEncap cfg.encapsulation baseDefaultStyle
            else
              normalizeEncap baseDefaultStyle baseDefaultStyle;

          getEncapConfig =
            specific:
            if builtins.isAttrs cfg.encapsulation then
              normalizeEncap (cfg.encapsulation.${specific} or "default") defaultEncapObj.style
            else
              defaultEncapObj;

          resolveColor =
            val: defaultVal:
            if val == null || val == "" then
              defaultVal
            else if lib.strings.hasPrefix "#" val then
              val
            else if colors ? ${val} then
              colors.${val}
            else if
              builtins.match "^[0-9a-fA-F]{6}$" val != null || builtins.match "^[0-9a-fA-F]{8}$" val != null
            then
              "#${val}"
            else
              defaultVal;

          encapColors = if builtins.isAttrs cfg.encapsulation then (cfg.encapsulation.colors or { }) else { };

          globalEncapColor =
            if builtins.isAttrs cfg.encapsulation then
              (
                if cfg.encapsulation.color != null then
                  cfg.encapsulation.color
                else if defaultEncapObj.color != null then
                  defaultEncapObj.color
                else
                  null
              )
            else
              null;

          globalAccentFallback =
            if colors ? pill-active && colors.pill-active != "" then colors.pill-active else colors.accent;

          globalAccent = resolveColor (
            if builtins.isAttrs cfg.encapsulation then
              (
                if cfg.encapsulation.accent != null then
                  cfg.encapsulation.accent
                else if encapColors ? accent && encapColors.accent != null then
                  encapColors.accent
                else if defaultEncapObj.accent != null then
                  defaultEncapObj.accent
                else
                  null
              )
            else
              null
          ) globalAccentFallback;

          baseGlyphColor = resolveColor (encapColors.glyph or encapColors.default or globalEncapColor
          ) colors.pill;

          wsEncapCfg = getEncapConfig "workspaces";
          statsEncapCfg = getEncapConfig "stats";
          netspeedEncapCfg = getEncapConfig "netspeed";
          dateEncapCfg = getEncapConfig "date";
          trayEncapCfg = getEncapConfig "tray";

          wsColor = resolveColor (
            if wsEncapCfg.color != null then wsEncapCfg.color else encapColors.workspaces or null
          ) baseGlyphColor;
          statsColor = resolveColor (
            if statsEncapCfg.color != null then statsEncapCfg.color else encapColors.stats or null
          ) baseGlyphColor;
          netspeedColor = resolveColor (
            if netspeedEncapCfg.color != null then netspeedEncapCfg.color else encapColors.netspeed or null
          ) baseGlyphColor;
          dateColor = resolveColor (
            if dateEncapCfg.color != null then dateEncapCfg.color else encapColors.date or null
          ) baseGlyphColor;
          trayColor = resolveColor (
            if trayEncapCfg.color != null then trayEncapCfg.color else encapColors.tray or null
          ) baseGlyphColor;

          focusedWsColor = resolveColor (
            if wsEncapCfg.accent != null then
              wsEncapCfg.accent
            else if encapColors ? workspacesAccent && encapColors.workspacesAccent != null then
              encapColors.workspacesAccent
            else if encapColors ? focused && encapColors.focused != null then
              encapColors.focused
            else if encapColors ? active && encapColors.active != null then
              encapColors.active
            else
              null
          ) globalAccent;
          focusedNumColor = resolveColor (encapColors.focusedNumber or encapColors.focused_number or null
          ) colors.dark;

          statsAccent = resolveColor (
            if statsEncapCfg.accent != null then statsEncapCfg.accent else encapColors.statsAccent or null
          ) null;
          cpuIconColor = if statsAccent != null then statsAccent else colors.purple;
          memIconColor = if statsAccent != null then statsAccent else colors.orange;
          tempIconColor = if statsAccent != null then statsAccent else colors.ice;
          diskIconColor = if statsAccent != null then statsAccent else colors.orange;

          netspeedAccent = resolveColor (
            if netspeedEncapCfg.accent != null then
              netspeedEncapCfg.accent
            else
              encapColors.netspeedAccent or null
          ) colors.nord;

          dateAccent = resolveColor (
            if dateEncapCfg.accent != null then dateEncapCfg.accent else encapColors.dateAccent or null
          ) colors.time-alt;

          trayAccent = resolveColor (
            if trayEncapCfg.accent != null then trayEncapCfg.accent else encapColors.trayAccent or null
          ) colors.blue-alt;

          wsEncap = wsEncapCfg.style;
          statsEncap = statsEncapCfg.style;
          netspeedEncap = netspeedEncapCfg.style;
          dateEncap = dateEncapCfg.style;
          trayEncap = trayEncapCfg.style;

          # Glifos mapeados para os módulos de encapsulamento dedicados
          encapGlyphMap = {
            pill = {
              left = "";
              right = "";
            };
            shapes = {
              left = "";
              right = "";
            };
            shape = {
              left = "";
              right = "";
            };
            slant = {
              left = "";
              right = "";
            };
            powerline = {
              left = "";
              right = "";
            };
          };

          getGlyphs = e: encapGlyphMap.${e} or encapGlyphMap.pill;
          wsGlyphs = getGlyphs wsEncap;
          statsGlyphs = getGlyphs statsEncap;
          netspeedGlyphs = getGlyphs netspeedEncap;
          dateGlyphs = getGlyphs dateEncap;
          trayGlyphs = getGlyphs trayEncap;

          wsLeft = "encap-ws-left";
          wsRight = "encap-ws-right";
          statsLeft = "encap-stats-left";
          statsRight = "encap-stats-right";
          netspeedLeft = "encap-netspeed-left";
          netspeedRight = "encap-netspeed-right";
          dateLeft = "encap-date-left";
          dateRight = "encap-date-right";
          trayLeft = "encap-tray-left";
          trayRight = "encap-tray-right";

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
            module-margin-left = 0;
            module-margin-right = 0;

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
          # Flutuante, cápsulas arredondadas para workspaces e relógio,
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
            module-margin-left = 0;
            module-margin-right = 0;

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
            modules-right = "${statsLeft} cpu memory temperature ${statsRight} sp network dots bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots notifications sp ${dateLeft} date ${dateRight} sp powermenu";
          };

          pillsPrimaryBar = pillsBaseBar // {
            modules-left = "launcher sp ${wsLeft} bspwm ${wsRight} sp bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "${statsLeft} cpu memory temperature disk ${statsRight} sp network sp ${netspeedLeft} netspeed ${netspeedRight} sep uptime";
          };

          pillsSecondaryBar = pillsBaseBar // {
            modules-left = "${wsLeft} bspwm ${wsRight} sp polywins";
            modules-center = "xwindow";
            # modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications${pillsTray} sp ${dateLeft} date ${dateRight} sp powermenu";
            modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications sp ${dateLeft} date ${dateRight} sp powermenu";
          };

          # Overrides aplicados aos módulos existentes quando o estilo pills/zproger ou shapes está ativo.
          # 1. Workspaces com números coloridos pastel dentro da cápsula
          # 2. Playerctl/Media no centro, idêntico ao estilo moderno
          # 3. Módulos com ícone único sem duplicações (sem prefixos colidindo com scripts)
          # 4. Relógio dentro da cápsula com ícone único  em cinza suave
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

                # Workspace focado: Pac-Man (󰮯) e número com cor amena e elegante no fundo ativo
                label-focused = "%{T2}%{F${colors.dark}}󰮯 %{F-}%{T-}%{T3}%{F${focusedNumColor}}%name%%{F-}%{T-}";
                label-focused-foreground = focusedNumColor;
                label-focused-background = focusedWsColor;
                label-focused-padding = 1;
                label-focused-margin = 0;

                # Workspace ocupado (com janelas): número colorido pastel no fundo padrão da cápsula
                label-occupied = "%{T3}%icon%%{T-}";
                label-occupied-foreground = colors.text;
                label-occupied-background = wsColor;
                label-occupied-padding = 1;
                label-occupied-margin = 0;

                # Workspace com urgência / alerta: fantasma do Pac-Man (󰊠) em vermelho
                label-urgent = "%{T2}%{F${colors.red}}󰊠 %{F-}%{T-}%{T3}%icon%%{T-}";
                label-urgent-foreground = colors.nord;
                label-urgent-background = wsColor;
                label-urgent-padding = 1;
                label-urgent-margin = 0;

                # Workspace vazio: número atenuado e sutil (%name%), sem cor de ícone ativa
                label-empty = "%{T3}%name%%{T-}";
                label-empty-foreground = colors.muted;
                label-empty-background = wsColor;
                label-empty-padding = 1;
                label-empty-margin = 0;

                label-separator = "";
                label-separator-background = wsColor;
              };

              # Módulos dedicados para cada seção da barra, sincronizando glifos e cores com perfeição
              "module/encap-ws-left" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${wsGlyphs.left}%{T-}";
                label-foreground = wsColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-ws-right" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${wsGlyphs.right}%{T-}";
                label-foreground = wsColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-stats-left" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${statsGlyphs.left}%{T-}";
                label-foreground = statsColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-stats-right" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${statsGlyphs.right}%{T-}";
                label-foreground = statsColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-netspeed-left" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${netspeedGlyphs.left}%{T-}";
                label-foreground = netspeedColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-netspeed-right" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${netspeedGlyphs.right}%{T-}";
                label-foreground = netspeedColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-date-left" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${dateGlyphs.left}%{T-}";
                label-foreground = dateColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-date-right" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${dateGlyphs.right}%{T-}";
                label-foreground = dateColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-tray-left" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${trayGlyphs.left}%{T-}";
                label-foreground = trayColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/encap-tray-right" = {
                type = "custom/text";
                format = "<label>";
                label = "%{T5}${trayGlyphs.right}%{T-}";
                label-foreground = trayColor;
                format-margin = 0;
                format-padding = 0;
              };

              # Sobrescrita direta de compatibilidade para módulos shape-left/shape-right manuais
              "module/shape-left" = {
                label = "%{T5}%{T-}";
                label-foreground = statsColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/shape-right" = {
                label = "%{T5}%{T-}";
                label-foreground = statsColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/shapes-left" = {
                label = "%{T5}%{T-}";
                label-foreground = statsColor;
                format-margin = 0;
                format-padding = 0;
              };
              "module/shapes-right" = {
                label = "%{T5}%{T-}";
                label-foreground = statsColor;
                format-margin = 0;
                format-padding = 0;
              };

              "module/cpu" = {
                format = "<label>";
                format-prefix = "";
                format-background = statsColor;
                format-margin = 0;
                format-padding = 0;
                label = " %{T2}%{F${cpuIconColor}} %{F-}%{T-}%percentage%% ";
                label-foreground = colors.text-alt;
                label-background = statsColor;
                label-padding = 0;
                label-margin = 0;
              };

              "module/memory" = {
                format = "<label>";
                format-prefix = "";
                format-background = statsColor;
                format-margin = 0;
                format-padding = 0;
                label = " %{T2}%{F${memIconColor}} %{F-}%{T-}%percentage_used%% ";
                label-foreground = colors.text-alt;
                label-background = statsColor;
                label-padding = 0;
                label-margin = 0;
              };

              "module/temperature" = {
                type = "internal/temperature";
                thermal-zone = 0;
                warn-temperature = 75;
                format = "<label>";
                format-warn = "<label-warn>";
                format-prefix = "";
                format-background = statsColor;
                format-warn-background = statsColor;
                format-margin = 0;
                format-padding = 0;
                format-warn-padding = 0;
                label = " %{T2}%{F${tempIconColor}} %{F-}%{T-}%temperature-c% ";
                label-warn = " %{T2}%{F${colors.red}} %{F-}%{T-}%temperature-c% ";
                label-foreground = colors.text-alt;
                label-warn-foreground = colors.red;
                label-background = statsColor;
                label-warn-background = statsColor;
                label-padding = 0;
                label-warn-padding = 0;
                label-margin = 0;
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
                format-prefix-foreground = dateAccent;
                format-background = dateColor;
                format-margin = 0;
                format-padding = 0;
                date = "%{F${dateAccent}}  %H:%M:%S%{F-}";
                date-alt = "%{F${dateAccent}}  %a, %d %b %Y  %{F${dateAccent}}  %H:%M:%S%{F-}";
                time = "";
                time-alt = "";
                label = " %date% ";
                label-foreground = dateAccent;
                label-background = dateColor;
                label-padding = 0;
                label-margin = 0;
              };

              "module/network" = {
                label-foreground = colors.green-alt;
              };

              "module/netspeed" = {
                format = "<label>";
                format-background = netspeedColor;
                format-margin = 0;
                format-padding = 0;
                label = " %output% ";
                label-foreground = netspeedAccent;
                label-background = netspeedColor;
                label-padding = 0;
                label-margin = 0;
              };

              "module/disk" = {
                spacing = 0;
                format-mounted = "<label-mounted>";
                format-mounted-prefix = "";
                format-mounted-background = statsColor;
                format-mounted-margin = 0;
                format-mounted-padding = 0;
                label-mounted = " %{T2}%{F${diskIconColor}} %{F-}%{T-}%free% ";
                label-mounted-foreground = colors.text-alt;
                label-mounted-background = statsColor;
                label-mounted-padding = 0;
                label-mounted-margin = 0;
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
                format-background = trayColor;
                label-background = trayColor;
                label-foreground = trayAccent;
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
