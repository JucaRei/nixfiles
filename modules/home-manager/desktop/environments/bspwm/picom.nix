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
      shadowOpacity = 0.75;
      shadowOffsets = [
        (-12)
        (-12)
      ];

      fade = true;
      fadeDelta = 8;
      fadeSteps = [
        0.028
        0.028
      ];

      settings = {
        shadow-radius = 12;
        shadow-color = "#000000";

        no-fading-openclose = false;
        no-fading-destroyed-argb = false;

        frame-opacity = 1.0;
        corner-radius = 12;

        dithered-present = false;
        detect-rounded-corners = true;
        detect-client-opacity = true;
        detect-transient = true;
        use-damage = false;
        detect-client-leader = false;
        use-ewmh-active-win = true;
        unredir-if-possible = false;

        # Blur com dual_kawase (apenas em GPUs modernas com aceleração GLX)
        blur = lib.mkIf (!isNouveauOrLegacy) {
          method = "dual_kawase";
          strength = 8;
          background = false;
          background-frame = false;
          background-fixed = false;
        };

        # Regras de Estilo, Opacidade, Blur e Animações
        rules = [
          # Regra base padrão
          {
            blur-background = false;
            fade = false;
          }

          # Janelas normais
          {
            match = "window_type = 'normal'";
            fade = true;
            shadow = true;
            corner-radius = 12;
            blur-background = true;
            opacity = 0.90;
            animations = lib.mkIf cfg.animations.enable [
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

          # Diálogos
          {
            match = "window_type = 'dialog'";
            shadow = true;
          }

          # Tooltips
          {
            match = "window_type = 'tooltip'";
            corner-radius = 8;
            opacity = 0.95;
            shadow = true;
            blur-background = true;
          }

          # Fullscreen (sem bordas arredondadas)
          {
            match = "fullscreen";
            corner-radius = 0;
          }

          # Barra / Docks (Polybar e afins)
          {
            match = "window_type = 'dock'";
            corner-radius = 12;
            fade = true;
            blur-background = true;
            opacity = 0.85;
          }

          # Menus e Popups
          {
            match = "window_type = 'dropdown_menu' || window_type = 'menu' || window_type = 'popup' || window_type = 'popup_menu'";
            corner-radius = 8;
          }

          # Evitar bugs de sombra em elementos pequenos
          {
            match = "window_type = 'menu' || role = 'popup' || role = 'bubble'";
            shadow = false;
          }

          # Terminais (Transparência estilizada + Blur)
          {
            match = "class_g = 'Alacritty' || class_g = 'st-256color' || class_g = 'kitty' || class_g = 'FloaTerm'";
            opacity = 0.75;
            blur-background = true;
          }

          # Scratchpad / Overlays
          {
            match = "class_g = 'bspwm-scratch' || class_g = 'Updating' || class_g = 'Voiceassistantoverlay'";
            opacity = 0.70;
            blur-background = true;
            animations = lib.mkIf cfg.animations.enable [
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

          # Rofi Launcher
          {
            match = "class_g = 'Rofi'";
            opacity = 0.75;
            blur-background = true;
            corner-radius = 12;
            animations = lib.mkIf cfg.animations.enable [
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

          # Polybar
          {
            match = "class_g = 'Polybar' || class_g = 'eww-bar'";
            corner-radius = 0;
            blur-background = true;
            unredir-if-possible = false;
          }

          # Imagens, Mídia e Dunst (Cantos Arredondados)
          {
            match = "class_g = 'Viewnior' || class_g = 'mpv' || class_g = 'Dunst' || class_g = 'retroarch'";
            corner-radius = 14;
          }

          # Dunst Notificações
          {
            match = "name = 'Notification' || class_g ?= 'Notify-osd' || class_g = 'Dunst'";
            shadow = true;
            blur-background = true;
            opacity = 0.75;
            animations = lib.mkIf cfg.animations.enable [
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

          # Exclusão de sombras
          {
            match = "class_g = 'Polybar' || class_g = 'Eww' || class_g = 'jgmenu' || class_g = 'bspwm-scratch' || class_g = 'Spotify' || class_g = 'retroarch' || class_g = 'firefox' || class_g = 'Screenkey' || class_g = 'mpv' || class_g = 'Viewnior' || _GTK_FRAME_EXTENTS@";
            shadow = false;
          }

          # Animações de Troca de Workspace (bspwm-slidefx: deslizar para a direita)
          (lib.mkIf cfg.animations.enable {
            match = "_MY_CUSTOM_WORKSPACE_SWITCH@ = 1 && window_type = 'normal' && !class_g = 'Polybar' && !class_g = 'eww-bar' && !class_g = 'Dunst'";
            animations = [
              {
                triggers = [ "show" ];
                offset-x = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  start = "-1920";
                  end = "0";
                  duration = 0.3;
                };
                shadow-offset-x = "offset-x";
              }
              {
                triggers = [ "hide" ];
                opacity = {
                  curve = "linear";
                  duration = 0.3;
                  start = "window-raw-opacity-before";
                  end = "window-raw-opacity-before";
                };
                blur-opacity = 0;
                shadow-opacity = "opacity";
                offset-x = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  start = "0";
                  end = "-1920";
                  duration = 0.2;
                };
                shadow-offset-x = "offset-x";
              }
            ];
          })

          # Animações de Troca de Workspace (bspwm-slidefx: deslizar para a esquerda)
          (lib.mkIf cfg.animations.enable {
            match = "_MY_CUSTOM_WORKSPACE_SWITCH@ = 2 && window_type = 'normal' && !class_g = 'Polybar' && !class_g = 'eww-bar' && !class_g = 'Dunst'";
            animations = [
              {
                triggers = [ "show" ];
                offset-x = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  start = "1920";
                  end = "0";
                  duration = 0.3;
                };
                shadow-offset-x = "offset-x";
              }
              {
                triggers = [ "hide" ];
                opacity = {
                  curve = "linear";
                  duration = 0.3;
                  start = "window-raw-opacity-before";
                  end = "window-raw-opacity-before";
                };
                blur-opacity = 0;
                shadow-opacity = "opacity";
                offset-x = {
                  curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                  start = "0";
                  end = "1920";
                  duration = 0.2;
                };
                shadow-offset-x = "offset-x";
              }
            ];
          })
        ];
      };
    };
  };
}
