{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.picom;

  # Detecta se o módulo nvidia-legacy está ativo via osConfig (NixOS integrado)
  gpuDriver = osConfig.hardware.graphics.cards.gpu or "unknown";
  isNvidiaLegacy = gpuDriver == "nvidia-legacy";
  isNouveauOrLegacy = isNvidiaLegacy || gpuDriver == "nouveau" || gpuDriver == "unknown";
in
{
    options.desktop.bspwm.picom = {
      enable = mkOption {
        type = bool;
        default = config.desktop.bspwm.enable;
        description = "Enable picom compositor for bspwm";
      };

      animations = {
        enable = mkOption {
          type = bool;
          default = !isNouveauOrLegacy;
          description = "Enable modern smooth window animations in picom";
        };
      };
    };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      package = pkgs.picom;
      # nvidia-legacy 340 e Nouveau usam xrender para estabilidade; GPUs modernas usam glx
      backend = lib.mkDefault (if isNouveauOrLegacy then "xrender" else "glx");
      vSync = lib.mkDefault (!isNouveauOrLegacy);

      shadow = lib.mkDefault true;
      shadowOpacity = 0.6;
      shadowOffsets = [
        (-12)
        (-12)
      ];
      shadowExclude = [
        "name = 'Notification'"
        "class_g = 'Polybar'"
        "class_g = 'Rofi'"
        "class_g = 'slop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      fade = true;
      fadeDelta = 4;
      fadeSteps = [
        0.03
        0.03
      ];

      settings = {
        corner-radius = 8;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'Polybar'"
        ];

        active-opacity = 1.0;
        inactive-opacity = if isNouveauOrLegacy then 1.0 else 0.95;
        inactive-opacity-override = false;
        focus-exclude = [
          "class_g = 'Polybar'"
          "class_g = 'Rofi'"
          "class_g = 'flameshot'"
        ];

        use-damage = true;
        # Performance extras para GPUs antigas
        glx-no-stencil = true;
        glx-no-rebind-pixmap = true;

        # Regras de Animações Fluídas estilo Hyprland/Modern Picom
        rules = lib.mkIf cfg.animations.enable [
          # 1. Animações para Janelas Normais (Abrir, Fechar, Mover e Redimensionar)
          {
            match = "window_type = 'normal'";
            animations = [
              {
                triggers = [ "close" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.35;
                  start = "window-raw-opacity-before";
                  end = 0;
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                scale-x = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.35;
                  start = 1;
                  end = 0.85;
                };
                scale-y = "scale-x";

                offset-x = "(1 - scale-x) / 2 * window-width";
                offset-y = "(1 - scale-y) / 2 * window-height";

                shadow-scale-x = "scale-x";
                shadow-scale-y = "scale-y";
                shadow-offset-x = "offset-x";
                shadow-offset-y = "offset-y";
              }
              {
                triggers = [ "open" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.4;
                  start = 0;
                  end = "window-raw-opacity";
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                scale-x = {
                  curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                  duration = 0.4;
                  start = 0.85;
                  end = 1;
                };
                scale-y = "scale-x";

                offset-x = "(1 - scale-x) / 2 * window-width";
                offset-y = "(1 - scale-y) / 2 * window-height";

                shadow-scale-x = "scale-x";
                shadow-scale-y = "scale-y";
                shadow-offset-x = "offset-x";
                shadow-offset-y = "offset-y";
              }
              {
                triggers = [ "geometry" ];
                scale-x = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.4;
                  start = "window-width-before / window-width";
                  end = 1;
                };
                scale-y = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.4;
                  start = "window-height-before / window-height";
                  end = 1;
                };
                offset-x = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.4;
                  start = "window-x-before - window-x";
                  end = 0;
                };
                offset-y = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.4;
                  start = "window-y-before - window-y";
                  end = 0;
                };
                shadow-scale-x = "scale-x";
                shadow-scale-y = "scale-y";
                shadow-offset-x = "offset-x";
                shadow-offset-y = "offset-y";
              }
            ];
          }

          # 2. Animações para Rofi Launcher (Scale suave + Fade)
          {
            match = "class_g = 'Rofi'";
            animations = [
              {
                triggers = [ "close" "hide" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.25;
                  start = "window-raw-opacity-before";
                  end = 0;
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                scale-x = {
                  curve = "cubic-bezier(0.6, 0, 0.735, 0.045)";
                  duration = 0.25;
                  start = 1;
                  end = 0.9;
                };
                scale-y = "scale-x";

                offset-x = "(1 - scale-x) / 2 * window-width";
                offset-y = "(1 - scale-y) / 2 * window-height";
              }
              {
                triggers = [ "open" "show" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.3;
                  start = 0;
                  end = "window-raw-opacity";
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                scale-x = {
                  curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                  duration = 0.3;
                  start = 0.9;
                  end = 1;
                };
                scale-y = "scale-x";

                offset-x = "(1 - scale-x) / 2 * window-width";
                offset-y = "(1 - scale-y) / 2 * window-height";
              }
            ];
          }

          # 3. Animações para Notificações Dunst (Slide lateral)
          {
            match = "class_g = 'Dunst'";
            animations = [
              {
                triggers = [ "close" "hide" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.25;
                  start = "window-raw-opacity-before";
                  end = 0;
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                offset-x = {
                  curve = "cubic-bezier(0.6, 0, 0.735, 0.045)";
                  duration = 0.25;
                  start = 0;
                  end = "100";
                };
              }
              {
                triggers = [ "open" "show" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.3;
                  start = 0;
                  end = "window-raw-opacity";
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                offset-x = {
                  curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                  duration = 0.3;
                  start = "100";
                  end = 0;
                };
              }
            ];
          }

          # 4. Animações para Terminal Scratchpad (Slide do topo)
          {
            match = "class_g = 'bspwm-scratch' || class_g = 'Alacritty' && name = 'tdrop'";
            animations = [
              {
                triggers = [ "close" "hide" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.3;
                  start = "window-raw-opacity-before";
                  end = 0;
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                offset-y = {
                  curve = "cubic-bezier(0.6, 0, 0.735, 0.045)";
                  duration = 0.3;
                  start = 0;
                  end = "-100";
                };
              }
              {
                triggers = [ "open" "show" ];
                opacity = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  duration = 0.35;
                  start = 0;
                  end = "window-raw-opacity";
                };
                blur-opacity = "opacity";
                shadow-opacity = "opacity";

                offset-y = {
                  curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                  duration = 0.35;
                  start = "-100";
                  end = 0;
                };
              }
            ];
          }
        ];
      };
    };
  };
}
