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
  polybarModules = import ./modules.nix { inherit pkgs colors scripts; };
in
{
  options.desktop.bspwm.polybar = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable modern floating Polybar for bspwm";
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

        if command -v ${pkgs.xorg.xrandr}/bin/xrandr >/dev/null 2>&1; then
          for m in $(${pkgs.xorg.xrandr}/bin/xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload main &
          done
        else
          polybar --reload main &
        fi
      '';
      config = polybarModules // {
        "colors" = colors;

        # --- Barra Principal Flutuante (Floating Pill Style) ---
        "bar/main" = {
          monitor = "\${env:MONITOR:}";
          width = "100%:-28";
          height = "34";
          offset-x = "14";
          offset-y = "8";
          radius = 12;
          fixed-center = true;

          background = "#e61e1e2e"; # Catppuccin Base semi-translúcido (90%)
          foreground = colors.text;

          line-size = 2;
          line-color = colors.mauve;

          border-size = 1;
          border-color = "#45475a"; # Catppuccin Surface1 sutil

          padding-left = 2;
          padding-right = 2;
          module-margin = 1;

          font-0 = "Inter:weight=SemiBold:size=10;3";
          font-1 = "FiraCode Nerd Font:size=11;3";
          font-2 = "JetBrainsMono Nerd Font:weight=Medium:size=10;3";
          font-3 = "Symbols Nerd Font:size=14;3";

          modules-left = "launcher sep bspwm sep xwindow";
          modules-center = "date";
          modules-right = "cpu memory pulseaudio backlight battery network sep powermenu";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";

          enable-ipc = true;
          wm-restack = "bspwm";
          override-redirect = true;
          screenchange-reload = true;
        };
      };
    };
  };
}
