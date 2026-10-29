{
  config,
  lib,
  pkgs,
  osConfig ? null,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm.picom;

  # Detecta se o módulo nvidia-legacy está ativo via osConfig (NixOS integrado)
  isNixOS = osConfig != null;
  gpuDriver = if isNixOS then (osConfig.hardware.graphics.cards.gpu or "generic") else "generic";
  isNvidiaLegacy = gpuDriver == "nvidia-legacy";
  isNouveauOrLegacy = isNvidiaLegacy || gpuDriver == "nouveau";
  hasBlur = cfg.blur.enable && (!isNouveauOrLegacy) && (cfg.backend != "xrender");
  picomPkg = nixGLWrapper pkgs.picom;
in
{
  options.desktop.bspwm.picom = {
    enable = lib.my.mkBool config.desktop.bspwm.enable "Enable picom compositor for bspwm";

    backend =
      lib.my.mkEnum
        [
          "xrender"
          "glx"
          "egl"
        ]
        (if isNouveauOrLegacy then "xrender" else "glx")
        "Picom rendering backend (glx for GPU acceleration, xrender for VMs/legacy)";

    cornerRadius = lib.my.mkInt (
      if isNouveauOrLegacy then 10 else 16
    ) "Raio dos cantos arredondados das janelas em pixels (ex: 16 para visual moderno e suave)";

    activeOpacity =
      lib.my.mkOpt (lib.types.numbers.between 0.0 1.0) 1.0
        "Opacidade das janelas ativas em foco (1.0 = totalmente opaco)";

    inactiveOpacity =
      lib.my.mkOpt (lib.types.numbers.between 0.0 1.0) 0.97
        "Opacidade das janelas inativas/desfocadas (menos translúcido, alta legibilidade)";

    blur = {
      enable = lib.my.mkBool (
        !isNouveauOrLegacy && cfg.backend != "xrender"
      ) "Enable dual_kawase background blur (requires glx/egl backend and capable GPU)";

      strength = lib.my.mkInt 7 "Dual-Kawase blur strength (1-20, default 7 for optimal frosted glass aesthetics)";
    };

    animations = {
      enable = lib.my.mkBool (
        !isNouveauOrLegacy
      ) "Enable modern smooth window animations in picom (requires glx/egl backend)";
    };

    shadows = {
      enable = lib.my.mkBool true "Enable window shadows in picom";
    };

    useDamage = lib.my.mkBool isNouveauOrLegacy "Only repaint modified regions of the screen to save CPU/GPU cycles";
  };

  config = mkIf (config.desktop.bspwm.enable && cfg.enable) {
    home.packages = [ picomPkg ];

    # Recarregar automaticamente o compositor Picom ao rodar switch-home
    home.activation.reloadPicom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD systemctl --user restart picom 2>/dev/null || ${pkgs.procps}/bin/pkill -USR1 -x picom 2>/dev/null || (${pkgs.procps}/bin/pkill -x picom 2>/dev/null && sleep 0.2 && ${picomPkg}/bin/picom -b 2>/dev/null || true)
    '';

    # Em vez de utilizar services.picom do Home Manager (que injeta diretivas obsoletas da v10
    # como inactive-opacity, active-opacity, shadow-exclude, fade-exclude, wintypes, gerando popup de warnings),
    # escrevemos diretamente o picom.conf moderno e puro no padrão libconfig da v12.
    xdg.configFile."picom/picom.conf".text = ''
      # ==============================================================================
      #  PICOM v12 MODERNO — CONFIGURAÇÃO PURA (CANTOS ARREDONDADOS & FROSTED GLASS)
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

      corner-radius = ${toString cfg.cornerRadius};

      # --- 2. Sombras Suaves e Profundas (Deep Soft Elevation) ---
      shadow = ${if cfg.shadows.enable then "true" else "false"};
      shadow-radius = 20;
      shadow-opacity = 0.55;
      shadow-offset-x = -16;
      shadow-offset-y = -16;
      shadow-color = "#000000"; # exceção: sombra preta de compositor

      # --- 3. Transições e Fading Suave ---
      fading = true;
      fade-in-step = 0.038;
      fade-out-step = 0.038;
      fade-delta = ${if isNouveauOrLegacy then "4" else "6"};
      no-fading-openclose = false;
      no-fading-destroyed-argb = false;

      # --- 4. Background Blur Dual-Kawase (Frosted Glass Refinado) ---
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
        # 1. Ferramentas de captura e seleção de tela (slop do maim, flameshot, slurp, xrectsel, etc):
        # PRIORIDADE MÁXIMA: NUNCA aplicar blur, sombra, cantos arredondados, fade ou animação!
        # Sem essa regra prioritária no topo, o slop (overlay de seleção do maim -s) herda o blur global do picom,
        # embaçando a tela inteira durante o recorte e impedindo a visualização da área a selecionar.
        {
          match = "class_g ?= 'slop' || class_i ?= 'slop' || name ?= 'slop' || class_g ?= 'Slop' || class_g ?= 'slurp' || class_g ?= 'flameshot' || class_g ?= 'Gnome-screenshot' || class_g ?= 'xrectsel'";
          corner-radius = 0;
          shadow = false;
          blur-background = false;
          fade = false;
          opacity = 1.0;
        },

        # 2. Bloqueador de Tela (i3lock / i3lock-color): tela cheia pura sem cantos, sem sombra e sem animações
        {
          match = "class_g ?= 'i3lock'";
          shadow = false;
          corner-radius = 0;
          fade = false;
          blur-background = false;
        },

        # Janelas normais: sombra, cantos arredondados, fade suave e opacidade diferenciada
        {
          match = "window_type = 'normal'";
          fade = true;
          shadow = true;
          corner-radius = ${toString cfg.cornerRadius};
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

        # Foco e opacidade refinados para janelas normais (alta legibilidade, sem transparência excessiva)
        {
          match = "window_type = 'normal' && focused";
          opacity = ${toString cfg.activeOpacity};
        },
        {
          match = "window_type = 'normal' && !focused";
          opacity = ${toString cfg.inactiveOpacity};
        },

        # Editores de código, IDEs e navegadores: 100% sólidos e nítidos (sem wallpaper vazando no texto)
        {
          match = "class_g ?= 'code' || class_g ?= 'Code' || class_g ?= 'antigravity' || class_g ?= 'Antigravity' || class_g ?= 'vscodium' || class_g ?= 'VSCodium' || class_g ?= 'Emacs' || class_g ?= 'gedit' || class_g ?= 'firefox' || class_g ?= 'LibreWolf' || class_g ?= 'librewolf' || class_g ?= 'chromium' || class_g ?= 'Chromium' || class_g ?= 'google-chrome' || class_g ?= 'Brave-browser' || class_g ?= 'vivaldi' || class_g ?= 'zen' || class_g ?= 'Sublime_text'";
          opacity = 1.0;
          corner-radius = ${toString cfg.cornerRadius};
          blur-background = false;
        },

        # Diálogos, popups e seletores de arquivos (Thunar, Pavucontrol, etc.)
        {
          match = "window_type = 'dialog' || class_g = 'Thunar' || class_g = 'thunar' || class_g = 'Lxappearance' || class_g = 'Pavucontrol' || class_g = 'File-roller'";
          shadow = true;
          fade = true;
          corner-radius = ${toString cfg.cornerRadius};
          opacity = 0.98;
          ${lib.optionalString hasBlur "blur-background = true;"}
        },
        {
          match = "window_type = 'tooltip'";
          corner-radius = 10;
          opacity = 0.96;
          shadow = true;
          fade = true;
          ${lib.optionalString hasBlur "blur-background = true;"}
        },
        {
          match = "fullscreen";
          corner-radius = 0;
          shadow = false;
        },

        # Barras e Docks (Polybar, Eww): a própria Polybar gerencia seu radius (10px) e transparência
        {
          match = "window_type = 'dock' || class_g ?= 'polybar' || class_g ?= 'Polybar' || class_g = 'eww-bar'";
          corner-radius = 0;
          fade = false;
          shadow = false;
          blur-background = false;
          opacity = 1.0;
          unredir-if-possible = false;
        },

        # Desktop (fundo da área de trabalho)
        {
          match = "window_type = 'desktop'";
          corner-radius = 0;
          fade = false;
          shadow = false;
          blur-background = false;
        },

        # Menus de contexto GTK/Qt
        {
          match = "window_type = 'dropdown_menu' || window_type = 'menu' || window_type = 'popup' || window_type = 'popup_menu'";
          corner-radius = 12;
          shadow = true;
          fade = true;
        },

        # Terminais modernos (Alacritty, Kitty, st, FloaTerm): efeito frosted glass nítido e elegante
        {
          match = "class_g = 'Alacritty' || class_g = 'st-256color' || class_g = 'kitty' || class_g = 'FloaTerm'";
          opacity = 0.95;
          corner-radius = ${toString cfg.cornerRadius};
          ${lib.optionalString hasBlur "blur-background = true;"}
        },

        # Scratchpads flutuantes (bspwm-scratch): slide vertical suave descendo do topo
        {
          match = "class_g = 'bspwm-scratch' || class_g = 'Updating' || class_g = 'Voiceassistantoverlay'";
          opacity = 0.95;
          corner-radius = ${toString cfg.cornerRadius};
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

        # Menu Rofi (Quick settings, app launcher, bluetooth, wifi): cantos bem arredondados e sombra premium
        {
          match = "class_g = 'Rofi'";
          opacity = 0.97;
          corner-radius = ${toString (cfg.cornerRadius + 2)};
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
          corner-radius = ${toString cfg.cornerRadius};
          opacity = 1.0;
        },

        # Notificações Dunst: cantos arredondados modernos e sombra destacada
        {
          match = "name = 'Notification' || class_g ?= 'Notify-osd' || class_g = 'Dunst'";
          shadow = true;
          corner-radius = ${toString cfg.cornerRadius};
          opacity = 0.96;
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
          match = "class_g ?= 'slop' || class_g = 'Polybar' || class_g = 'Eww' || class_g = 'jgmenu' || class_g = 'Spotify' || class_g = 'retroarch' || class_g = 'firefox' || class_g = 'LibreWolf' || class_g = 'librewolf' || class_g = 'floorp' || class_g = 'Floorp' || class_g = 'Screenkey' || class_g = 'mpv' || class_g = 'Viewnior' || class_g ?= 'i3lock' || _GTK_FRAME_EXTENTS@";
          shadow = false;
        },

        # Popups e menus de navegadores (Firefox, LibreWolf, Floorp): desenham suas próprias bordas arredondadas e sombras
        {
          match = "(class_g = 'firefox' || class_g = 'LibreWolf' || class_g = 'librewolf' || class_g = 'floorp' || class_g = 'Floorp') && (window_type = 'popup_menu' || window_type = 'dropdown_menu' || window_type = 'menu' || window_type = 'popup' || window_type = 'utility' || window_type = 'dialog')";
          corner-radius = 0;
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
        ExecStart = "${picomPkg}/bin/picom";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
