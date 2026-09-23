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
  polybarModules = import ./modules.nix { inherit lib pkgs colors scripts; };
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

        export PATH="${lib.makeBinPath [ pkgs.xorg.xrandr pkgs.gnugrep pkgs.coreutils pkgs.procps ]}:$PATH"

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

        # --- Barra Principal (Floating Capsules / gh0stzk style) ---
        "bar/main" = {
          monitor = "\${env:MONITOR:}";
          width = "100%";
          height = "30";
          radius = 0;
          fixed-center = true;

          background = colors.transparent;
          foreground = colors.text;

          line-size = 2;
          line-color = colors.blue;

          border-size = 0;
          padding-left = 1;
          padding-right = 1;
          module-margin = 0;

          font-0 = "Inter:weight=SemiBold:size=10;3";
          font-1 = "Symbols Nerd Font:size=12;3";
          font-2 = "JetBrainsMono Nerd Font:weight=Medium:size=10;3";
          font-3 = "Symbols Nerd Font:size=15;4"; # Ícone do lançador e power
          font-4 = "Symbols Nerd Font:size=17;4"; # Glyphs das cápsulas  e 
          font-5 = "Symbols Nerd Font Mono:size=12;3";

          # --- Organização em Cápsulas/Pills (gh0stzk Rice Style) ---
          modules-left = "bi launcher bd sep bi bspwm bd sep bi polywins bd";
          # modules-left = "bi launcher bd sep bi bspwm bd sep bi xwindow bd sep minimized"; # Layout anterior com xwindow e contador minimizado
          modules-center = "media";
          modules-right = "bi cpu dots memory dots temperature bd sep bi network dots bluetooth bd sep bi pulseaudio backlight battery bd sep bi date bd sep bi powermenu bd";

          # --- Layout alternativo completo (descomente caso deseje exibir netspeed, layout do teclado ou redshift):
          # modules-right = "bi cpu dots memory dots temperature bd sep bi network dots bluetooth bd sep bi pulseaudio backlight redshift battery bd sep bi date bd sep bi powermenu bd"; # Com Redshift
          # modules-right = "bi cpu dots memory dots temperature bd sep bi network dots bluetooth bd sep bi netspeed bd sep bi pulseaudio backlight battery bd sep bi keyboard bd sep bi date bd sep bi powermenu bd";
          # modules-right = "bi cpu dots memory bd sep bi network bd sep bi pulseaudio backlight battery bd sep bi date bd sep bi powermenu bd"; # Versão ultra minimalista

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
