{
  cfg,
  colors,
  pillsContext,
}:
let
  inherit (pillsContext)
    isPills
    wsLeft
    wsRight
    statsLeft
    statsRight
    netspeedLeft
    netspeedRight
    dateLeft
    dateRight
    trayLeft
    trayRight
    ;
  modernTray = if cfg.tray.enable then " sep tray" else "";
  pillsTray = if cfg.tray.enable then " sp ${trayLeft} tray ${trayRight}" else "";

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
    modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard dots notifications${modernTray} sep date sep powermenu";
  };

  modernPrimaryBar = modernBaseBar // {
    modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
    modules-center = "media";
    modules-right = "cpu memory temperature disk sep network dots netspeed sep uptime";
  };

  modernSecondaryBar = modernBaseBar // {
    modules-left = "bspwm sep polywins";
    modules-center = "xwindow";
    modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications${modernTray} sep date sep powermenu";
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
    modules-right = "${statsLeft} cpu memory temperature ${statsRight} sp network dots bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots notifications${pillsTray} sp ${dateLeft} date ${dateRight} sp powermenu";
  };

  pillsPrimaryBar = pillsBaseBar // {
    modules-left = "launcher sp ${wsLeft} bspwm ${wsRight} sp bsp-layout sep polywins minimized";
    modules-center = "media";
    modules-right = "${statsLeft} cpu memory temperature disk ${statsRight} sp network sp ${netspeedLeft} netspeed ${netspeedRight} sep uptime";
  };

  pillsSecondaryBar = pillsBaseBar // {
    modules-left = "${wsLeft} bspwm ${wsRight} sp polywins";
    modules-center = "xwindow";
    modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift dots notifications${pillsTray} sp ${dateLeft} date ${dateRight} sp powermenu";
  };

in
{
  # --- Definição das Barras Ativas (Alternável via desktop.bspwm.polybar.style: "zproger"/"pills"/"shapes" ou "modern") ---
  "bar/main" = if isPills then pillsMainBar else modernMainBar;
  "bar/primary" = if isPills then pillsPrimaryBar else modernPrimaryBar;
  "bar/secondary" = if isPills then pillsSecondaryBar else modernSecondaryBar;
}
