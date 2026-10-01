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
          for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload main &
          done
        else
          polybar --reload main &
        fi
      '';
      config = polybarModules // {
        "colors" = colors;

        # --- Barra Principal (Floating Modern Bar - Estilo Waybar / Catppuccin Mocha) ---
        "bar/main" = {
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
          modules-left = "launcher bspwm sep polywins";
          modules-center = "media";
          modules-right = "cpu memory temperature sep network bluetooth sep pulseaudio battery sep keyboard sep date powermenu";

          # --- Layout alternativo legado em cápsulas (descomente caso deseje os glifos  e ):
          # modules-left = "bi launcher bd sep bi bspwm bd sep bi polywins bd";
          # modules-right = "bi cpu memory temperature bd sep bi network dots bluetooth bd sep bi pulseaudio bd sep bi keyboard bd sep bi date bd sep bi powermenu bd";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";

          enable-ipc = true;
          wm-restack = "bspwm";
          screenchange-reload = true;
        };
      };
    };
  };
}
