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
      type = lib.types.enum [ "modern" "zproger" ];
      default = "modern";
      description = "Estilo visual da Polybar: 'zproger' (cápsulas flutuantes com workspaces coloridos) ou 'modern' (estilo Waybar / Catppuccin coeso)";
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
    ];

    services.polybar = {
      enable = true;
      package = polybarPkg;
      script = ''
        exec ${scripts.polybarLaunchScript}
      '';
      config =
        let
          isZproger = cfg.style == "zproger";

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
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard sep date sep powermenu";
          };

          modernPrimaryBar = modernBaseBar // {
            modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "cpu memory temperature disk sep network dots netspeed sep uptime";
          };

          modernSecondaryBar = modernBaseBar // {
            modules-left = "bspwm sep polywins";
            modules-center = "xwindow";
            modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift sep date sep powermenu";
          };

          # =========================================================================
          # ESTILO 2: ZPROGER (https://github.com/Zproger/bspwm-dotfiles)
          # Flutuante, cápsulas arredondadas #2b2f37, workspaces numerados e coloridos
          # =========================================================================
          zprogerBaseBar = {
            monitor = "\${env:MONITOR:}";
            width = "98%";
            offset-x = "1%";
            offset-y = 6;
            height = 28;
            fixed-center = true;
            bottom = false;

            background = "#1e222a";
            foreground = "#abb2bf";

            line-size = 3;
            line-color = "#565c64";

            padding-left = 1;
            padding-right = 1;
            module-margin = 0;

            font-0 = "JetBrainsMono Nerd Font:weight=Bold:size=10;3";
            font-1 = "Symbols Nerd Font:size=12;3";
            font-2 = "JetBrainsMono Nerd Font:size=14;4";
            font-3 = "Symbols Nerd Font:size=15;4"; # Cápsulas  e  (T4)
            font-4 = "Symbols Nerd Font Mono:size=11;3";
            font-5 = "Noto Sans CJK JP:weight=Medium:size=10;2";
            font-6 = "IPAGothic:size=10;2";
            font-7 = "Inter:weight=SemiBold:size=10;3";

            cursor-click = "pointer";
            cursor-scroll = "ns-resize";

            enable-ipc = true;
            wm-restack = "bspwm";
            screenchange-reload = true;
          };

          zprogerMainBar = zprogerBaseBar // {
            modules-left = "z-launcher z-round-left z-bspwm z-round-right";
            modules-center = "z-temperature z-space z-space z-memory z-space z-space z-cpu";
            modules-right = "z-battery z-backlight bluetooth z-space pulseaudio z-xkeyboard z-round-left z-time z-round-right z-space z-wlan tray z-powermenu";
          };

          zprogerPrimaryBar = zprogerBaseBar // {
            modules-left = "z-launcher z-round-left z-bspwm z-round-right";
            modules-center = "z-temperature z-space z-space z-memory z-space z-space z-cpu";
            modules-right = "z-battery z-backlight disk z-space z-wlan uptime";
          };

          zprogerSecondaryBar = zprogerBaseBar // {
            modules-left = "z-round-left z-bspwm z-round-right";
            modules-center = "xwindow";
            modules-right = "bluetooth z-space pulseaudio z-space z-xkeyboard z-round-left z-time z-round-right z-space z-powermenu";
          };
        in
        polybarModules // {
          "colors" = colors;

          /*
          # =========================================================================
          # [CONFIGURAÇÃO ANTERIOR - DESATIVADA, NÃO APAGADA]
          # Conforme solicitado ("não apague como esta agora, somente comente desativando"):
          #
          # "bar/main" = baseBar // {
          #   modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
          #   modules-center = "media";
          #   modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard sep date sep powermenu";
          # };
          #
          # "bar/primary" = baseBar // {
          #   modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
          #   modules-center = "media";
          #   modules-right = "cpu memory temperature disk sep network dots netspeed sep uptime";
          # };
          #
          # "bar/secondary" = baseBar // {
          #   modules-left = "bspwm sep polywins";
          #   modules-center = "xwindow";
          #   modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift sep date sep powermenu";
          # };
          # =========================================================================
          */

          # --- Definição das Barras Ativas (Alternável via desktop.bspwm.polybar.style: "zproger" ou "modern") ---
          "bar/main" = if isZproger then zprogerMainBar else modernMainBar;
          "bar/primary" = if isZproger then zprogerPrimaryBar else modernPrimaryBar;
          "bar/secondary" = if isZproger then zprogerSecondaryBar else modernSecondaryBar;
        };
    };
  };
}
