{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.polybar;

  colors = import ./colors.nix;
  scripts = import ./scripts.nix { inherit pkgs colors; };
  polybarModules = import ./modules.nix {
    inherit
      lib
      pkgs
      colors
      scripts
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
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "rofi-bluetooth" ''exec ${scripts.rofiBluetoothMenu} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-bluetooth" ''exec ${scripts.rofiBluetoothMenu} "$@"'')
      (pkgs.writeShellScriptBin "rofi-wifi-menu" ''exec ${scripts.rofiWifiMenu} "$@"'')
      (pkgs.writeShellScriptBin "bspwm-wifi" ''exec ${scripts.rofiWifiMenu} "$@"'')
      (pkgs.writeShellScriptBin "rofi-bsp-layout" ''exec ${scripts.rofiLayoutMenu} "$@"'')
      (pkgs.writeShellScriptBin "bsp-layout-switch" ''exec ${scripts.bspLayoutSwitchScript} "$@"'')
    ];

    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        pulseSupport = true;
        i3Support = false;
      };
      script = ''
        polybar-msg cmd quit 2>/dev/null || true
        pkill -x polybar || true
        while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

        export PATH="${
          lib.makeBinPath [
            pkgs.xrandr
            pkgs.gnugrep
            pkgs.coreutils
            pkgs.procps
          ]
        }:$PATH"

        if command -v xrandr >/dev/null 2>&1; then
          primary_mon=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
          if [ -z "$primary_mon" ]; then
            primary_mon=$(xrandr --query | grep " connected" | head -n1 | cut -d" " -f1)
          fi

          for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            if [ "$m" = "$primary_mon" ]; then
              MONITOR=$m polybar --reload main &
            else
              MONITOR=$m polybar --reload secondary &
            fi
          done
        else
          polybar --reload main &
        fi
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
            modules-left = "launcher bspwm sep bsp-layout sep polywins";
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

          # --- Barra Principal (Floating Modern Bar - com System Tray) ---
          "bar/main" = baseBar // {
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard sep tray sep date powermenu";
          };

          # --- Barra Secundária para Monitores Adicionais (sem conflito de Tray) ---
          "bar/secondary" = baseBar // {
            modules-right = "cpu memory temperature sep network dots bluetooth sep pulseaudio battery sep keyboard sep date powermenu";
          };
        };
    };
  };
}
