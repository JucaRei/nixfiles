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
      description = "Enable gh0stzk-inspired modular Polybar for bspwm";
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
          baseBar = {
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
        in
        polybarModules // {
          "colors" = colors;

          # --- Barra para Monitor Único (Single Monitor - Completa com Todos os Módulos) ---
          "bar/main" = baseBar // {
            modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard sep date powermenu";
          };

          # --- Barra Primária (Multi-Monitor: Sistema, Performance, Armazenamento, Rede & Continuação) ---
          "bar/primary" = baseBar // {
            modules-left = "launcher bspwm sep bsp-layout sep polywins minimized";
            modules-center = "media";
            modules-right = "cpu memory temperature disk sep network dots netspeed sep uptime";
          };

          # --- Barra Secundária (Multi-Monitor: Continuação - Workspaces, Título, Áudio, Periféricos, Sessão) ---
          "bar/secondary" = baseBar // {
            modules-left = "bspwm sep polywins";
            modules-center = "xwindow";
            modules-right = "bluetooth sep pulseaudio dots backlight dots battery sep keyboard dots redshift sep date powermenu";
          };
        };
    };
  };
}
