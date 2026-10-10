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
  isNouveauOrLegacy = isNvidiaLegacy || gpuDriver == "nouveau" || gpuDriver == "unknown" || gpuDriver == null;
  hasBlur = cfg.blur.enable && (!isNouveauOrLegacy) && (cfg.backend != "xrender");
in
{
  options.desktop.bspwm.picom = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable picom compositor for bspwm";
    };

    backend = mkOption {
      type = lib.types.enum [ "xrender" "glx" "egl" ];
      default = if isNouveauOrLegacy then "xrender" else "glx";
      description = "Picom rendering backend (glx for GPU acceleration, xrender for VMs/legacy)";
    };

    blur = {
      enable = mkOption {
        type = bool;
        default = !isNouveauOrLegacy && cfg.backend != "xrender";
        description = "Enable dual_kawase background blur (requires glx/egl backend and capable GPU)";
      };

      strength = mkOption {
        type = lib.types.int;
        default = 6;
        description = "Dual-Kawase blur strength (1-20, default 6 for optimal frosted glass aesthetics)";
      };
    };

    animations = {
      enable = mkOption {
        type = bool;
        default = !isNouveauOrLegacy;
        description = "Enable modern smooth window animations in picom (requires glx/egl backend)";
      };
    };

    shadows = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable window shadows in picom";
      };
    };

    useDamage = mkOption {
      type = bool;
      default = isNouveauOrLegacy; # true por padrão em hardware legado para minimizar repintura de tela
      description = "Only repaint modified regions of the screen to save CPU/GPU cycles";
    };
  };

  config = mkIf (config.desktop.bspwm.enable && cfg.enable) {
    home.packages = [ pkgs.picom ];

    # Recarregar automaticamente o compositor Picom ao rodar switch-home
    home.activation.reloadPicom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD systemctl --user restart picom 2>/dev/null || (${pkgs.procps}/bin/pkill -x picom 2>/dev/null && ${pkgs.picom}/bin/picom -b 2>/dev/null || true)
    '';

    # Em vez de utilizar services.picom do Home Manager (que injeta diretivas obsoletas da v10
    # como inactive-opacity, active-opacity, shadow-exclude, fade-exclude, wintypes, gerando popup de warnings),
    # escrevemos diretamente o picom.conf moderno e puro no padrão libconfig da v12.
    xdg.configFile."picom/picom.conf".text = ''
      # ==============================================================================
      #  PICOM v12 MODERNO — CONFIGURAÇÃO PURA (SEM WARNINGS & ESTÉTICA FROSTED GLASS)
      # ==============================================================================

      # --- 1. Backend e Renderização ---
      backend = "${cfg.backend}";
      vsync = ${if !isNouveauOrLegacy then "true" else "false"};
      use-damage = ${if cfg.useDamage then "true" else "false"};

      dithered-present = false;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      detect-client-leader = false;
      use-ewmh-active-win = true;
      unredir-if-possible = false;

      corner-radius = ${if isNouveauOrLegacy then "8" else "12"};

      # --- 2. Sombras Suaves (Soft Elevation) ---
      shadow = ${if cfg.shadows.enable then "true" else "false"};
      shadow-radius = 16;
      shadow-opacity = 0.55;
      shadow-offset-x = -14;
      shadow-offset-y = -14;
      shadow-color = "#000000";

      # --- 3. Transições e Fading Suave ---
      fading = true;
      fade-in-step = 0.035;
      fade-out-step = 0.035;
      fade-delta = ${if isNouveauOrLegacy then "4" else "6"};
      no-fading-openclose = false;
      no-fading-destroyed-argb = false;

      # --- 4. Background Blur Dual-Kawase (Frosted Glass) ---
      ${lib.optionalString hasBlur ''
      blur: {
        method = "dual_kawase";
        strength = ${toString cfg.blur.strength};
        background = false;
        background-frame = false;
        background-fixed = false;
      };
      ''}

      # --- 5. Regras Declarativas Modernas (Rules v12) ---
      rules = (
        # Regra padrão: sem blur e sem fade desnecessários em janelas genéricas
        {
          blur-background = false;
          fade = false;
        },

        # Janelas normais: sombra, cantos arredondados, fade suave e opacidade diferenciada
        {
          match = "window_type = 'normal'";
          fade = true;
          shadow = true;
          corner-radius = ${if isNouveauOrLegacy then "8" else "12"};
          ${lib.optionalString hasBlur "blur-background = true;"}
          ${lib.optionalString cfg.animations.enable ''
          animations = (
            {
              triggers = ["close"];
              opacity = {
                curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                duration = 0.22;
                start = "window-raw-opacity-before";
                end = 0;
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              scale-x = {
                curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                duration = 0.22;
                start = 1;
                end = 0.90;
              };
              scale-y = "scale-x";
              offset-x = "(1 - scale-x) / 2 * window-width";
              offset-y = "(1 - scale-y) / 2 * window-height";
              shadow-scale-x = "scale-x";
              shadow-scale-y = "scale-y";
              shadow-offset-x = "offset-x";
              shadow-offset-y = "offset-y";
            },
            {
              triggers = ["open"];
              opacity = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.26;
                start = 0;
                end = "window-raw-opacity";
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              scale-x = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.26;
                start = 0.90;
                end = 1;
              };
              scale-y = "scale-x";
              offset-x = "(1 - scale-x) / 2 * window-width";
              offset-y = "(1 - scale-y) / 2 * window-height";
              shadow-scale-x = "scale-x";
              shadow-scale-y = "scale-y";
              shadow-offset-x = "offset-x";
              shadow-offset-y = "offset-y";
            },
            {
              triggers = ["geometry"];
              scale-x = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.28;
                start = "window-width-before / window-width";
                end = 1;
              };
              scale-y = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.28;
                start = "window-height-before / window-height";
                end = 1;
              };
              offset-x = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.28;
                start = "window-x-before - window-x";
                end = 0;
              };
              offset-y = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.28;
                start = "window-y-before - window-y";
                end = 0;
              };
              shadow-scale-x = "scale-x";
              shadow-scale-y = "scale-y";
              shadow-offset-x = "offset-x";
              shadow-offset-y = "offset-y";
            }
          );
          ''}
        },

        # Foco e opacidade refinados para janelas normais (substitui active-opacity e inactive-opacity)
        {
          match = "window_type = 'normal' && focused";
          opacity = 1.0;
        },
        {
          match = "window_type = 'normal' && !focused";
          opacity = 0.93;
        },

        # Diálogos, popups e tooltips
        {
          match = "window_type = 'dialog'";
          shadow = true;
          fade = true;
          corner-radius = 12;
        },
        {
          match = "window_type = 'tooltip'";
          corner-radius = 8;
          opacity = 0.95;
          shadow = true;
          fade = true;
          ${lib.optionalString hasBlur "blur-background = true;"}
        },
        {
          match = "fullscreen";
          corner-radius = 0;
          shadow = false;
        },

        # Barras e Docks (Polybar, Eww): integradas ao visual moderno com cantos arredondados
        {
          match = "window_type = 'dock' || class_g = 'Polybar' || class_g = 'eww-bar'";
          corner-radius = 10;
          fade = true;
          shadow = false;
          ${lib.optionalString hasBlur "blur-background = true;"}
          opacity = 0.96;
          unredir-if-possible = false;
        },

        # Menus de contexto GTK/Qt
        {
          match = "window_type = 'dropdown_menu' || window_type = 'menu' || window_type = 'popup' || window_type = 'popup_menu'";
          corner-radius = 8;
          shadow = true;
          fade = true;
        },

        # Terminais modernos (Alacritty, Kitty, st, FloaTerm): frosted glass translúcido
        {
          match = "class_g = 'Alacritty' || class_g = 'st-256color' || class_g = 'kitty' || class_g = 'FloaTerm'";
          opacity = 0.88;
          corner-radius = 12;
          ${lib.optionalString hasBlur "blur-background = true;"}
        },

        # Scratchpads flutuantes (bspwm-scratch): slide vertical suave descendo do topo
        {
          match = "class_g = 'bspwm-scratch' || class_g = 'Updating' || class_g = 'Voiceassistantoverlay'";
          opacity = 0.85;
          corner-radius = 12;
          shadow = true;
          ${lib.optionalString hasBlur "blur-background = true;"}
          ${lib.optionalString cfg.animations.enable ''
          animations = (
            {
              triggers = ["close", "hide"];
              opacity = {
                curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                duration = 0.22;
                start = "window-raw-opacity-before";
                end = 0;
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              offset-y = {
                curve = "cubic-bezier(0.6, 0, 0.735, 0.045)";
                duration = 0.22;
                start = 0;
                end = "-80";
              };
            },
            {
              triggers = ["open", "show"];
              opacity = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.26;
                start = 0;
                end = "window-raw-opacity";
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              offset-y = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.26;
                start = "-80";
                end = 0;
              };
            }
          );
          ''}
        },

        # Menu Rofi (Quick settings, app launcher, bluetooth, wifi): scale e fade cinematográfico
        {
          match = "class_g = 'Rofi'";
          opacity = 0.92;
          corner-radius = 14;
          shadow = true;
          ${lib.optionalString hasBlur "blur-background = true;"}
          ${lib.optionalString cfg.animations.enable ''
          animations = (
            {
              triggers = ["close", "hide"];
              opacity = {
                curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                duration = 0.18;
                start = "window-raw-opacity-before";
                end = 0;
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              scale-x = {
                curve = "cubic-bezier(0.6, 0, 0.735, 0.045)";
                duration = 0.18;
                start = 1;
                end = 0.92;
              };
              scale-y = "scale-x";
              offset-x = "(1 - scale-x) / 2 * window-width";
              offset-y = "(1 - scale-y) / 2 * window-height";
            },
            {
              triggers = ["open", "show"];
              opacity = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.22;
                start = 0;
                end = "window-raw-opacity";
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              scale-x = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.22;
                start = 0.92;
                end = 1;
              };
              scale-y = "scale-x";
              offset-x = "(1 - scale-x) / 2 * window-width";
              offset-y = "(1 - scale-y) / 2 * window-height";
            }
          );
          ''}
        },

        # Visualizadores de imagem e reprodutores multimídia
        {
          match = "class_g = 'Viewnior' || class_g = 'mpv' || class_g = 'retroarch'";
          corner-radius = 12;
        },

        # Notificações Dunst: cantos suaves, sombra destacada e slide lateral da direita
        {
          match = "name = 'Notification' || class_g ?= 'Notify-osd' || class_g = 'Dunst'";
          shadow = true;
          corner-radius = 12;
          opacity = 0.92;
          ${lib.optionalString hasBlur "blur-background = true;"}
          ${lib.optionalString cfg.animations.enable ''
          animations = (
            {
              triggers = ["close", "hide"];
              opacity = {
                curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                duration = 0.20;
                start = "window-raw-opacity-before";
                end = 0;
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              offset-x = {
                curve = "cubic-bezier(0.6, 0, 0.735, 0.045)";
                duration = 0.20;
                start = 0;
                end = "80";
              };
            },
            {
              triggers = ["open", "show"];
              opacity = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.25;
                start = 0;
                end = "window-raw-opacity";
              };
              blur-opacity = "opacity";
              shadow-opacity = "opacity";
              offset-x = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                duration = 0.25;
                start = "80";
                end = 0;
              };
            }
          );
          ''}
        },

        # Exclusão de sombras em apps que desenham suas próprias bordas ou onde causa artefatos
        {
          match = "class_g = 'Polybar' || class_g = 'Eww' || class_g = 'jgmenu' || class_g = 'Spotify' || class_g = 'retroarch' || class_g = 'firefox' || class_g = 'Screenkey' || class_g = 'mpv' || class_g = 'Viewnior' || _GTK_FRAME_EXTENTS@";
          shadow = false;
        }
        ${lib.optionalString cfg.animations.enable ''
        ,
        {
          match = "_MY_CUSTOM_WORKSPACE_SWITCH@ = 1 && window_type = 'normal' && !class_g = 'Polybar' && !class_g = 'eww-bar' && !class_g = 'Dunst'";
          animations = (
            {
              triggers = ["show"];
              offset-x = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                start = "-1920";
                end = "0";
                duration = 0.28;
              };
              shadow-offset-x = "offset-x";
            },
            {
              triggers = ["hide"];
              opacity = {
                curve = "linear";
                duration = 0.25;
                start = "window-raw-opacity-before";
                end = "window-raw-opacity-before";
              };
              blur-opacity = 0;
              shadow-opacity = "opacity";
              offset-x = {
                curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                start = "0";
                end = "-1920";
                duration = 0.20;
              };
              shadow-offset-x = "offset-x";
            }
          );
        },
        {
          match = "_MY_CUSTOM_WORKSPACE_SWITCH@ = 2 && window_type = 'normal' && !class_g = 'Polybar' && !class_g = 'eww-bar' && !class_g = 'Dunst'";
          animations = (
            {
              triggers = ["show"];
              offset-x = {
                curve = "cubic-bezier(0.16, 1, 0.3, 1)";
                start = "1920";
                end = "0";
                duration = 0.28;
              };
              shadow-offset-x = "offset-x";
            },
            {
              triggers = ["hide"];
              opacity = {
                curve = "linear";
                duration = 0.25;
                start = "window-raw-opacity-before";
                end = "window-raw-opacity-before";
              };
              blur-opacity = 0;
              shadow-opacity = "opacity";
              offset-x = {
                curve = "cubic-bezier(0.25, 0.46, 0.45, 0.94)";
                start = "0";
                end = "1920";
                duration = 0.20;
              };
              shadow-offset-x = "offset-x";
            }
          );
        }
        ''}
      );
    '';

    # Serviço systemd do usuário gerenciando o compositor Picom
    systemd.user.services.picom = {
      Unit = {
        Description = "Picom X11 compositor";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.picom}/bin/picom";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
