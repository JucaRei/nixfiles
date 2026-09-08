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
  isNouveauOrLegacy =
    isNvidiaLegacy || gpuDriver == "nouveau" || gpuDriver == "unknown" || gpuDriver == null;
  hasBlur = cfg.blur.enable && (!isNouveauOrLegacy) && (cfg.backend != "xrender");
in
{
  options.desktop.bspwm.picom = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable modern and lightweight picom compositor for bspwm";
    };

    backend = mkOption {
      type = lib.types.enum [
        "xrender"
        "glx"
        "egl"
      ];
      default = if isNouveauOrLegacy then "xrender" else "glx";
      description = "Picom rendering backend (glx for GPU acceleration, xrender for VMs/legacy)";
    };

    blur = {
      enable = mkOption {
        type = bool;
        default = !isNouveauOrLegacy && cfg.backend != "xrender";
        description = "Enable background blur (requires glx/egl backend and capable GPU)";
      };
    };

    shadows = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable soft window shadows in picom";
      };
    };

    useDamage = mkOption {
      type = bool;
      default = true;
      description = "Only repaint modified regions of the screen to minimize CPU/GPU usage";
    };
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      package = pkgs.picom;
      backend = lib.mkDefault cfg.backend;
      vSync = lib.mkDefault (!isNouveauOrLegacy);

      # Sombras suaves e naturais
      shadow = lib.mkDefault cfg.shadows.enable;
      shadowOpacity = 0.55;
      shadowOffsets = [
        (-12)
        (-12)
      ];

      # Fading suave e ágil (sem atraso na abertura/fechamento)
      fade = true;
      fadeDelta = 6;
      fadeSteps = [
        0.04
        0.04
      ];

      settings = {
        shadow-radius = 14;
        shadow-color = "#11111b"; # Catppuccin Crust

        # Cantos arredondados modernos
        corner-radius = if isNouveauOrLegacy then 8 else 10;
        detect-rounded-corners = true;

        # Opacidades
        active-opacity = 0.98;
        inactive-opacity = 0.90;
        frame-opacity = 1.0;
        inactive-opacity-override = false;

        # Eficiência máxima de renderização
        use-damage = cfg.useDamage;
        dithered-present = false;
        detect-client-opacity = true;
        detect-transient = true;
        detect-client-leader = true;
        use-ewmh-active-win = true;
        unredir-if-possible = false;

        # Otimizações GLX
        glx-no-stencil = true;
        glx-no-rebind-pixmap = true;

        # Blur suave e leve (se ativado)
        blur = lib.mkIf hasBlur {
          method = "dual_kawase";
          strength = 5;
          background = false;
          background-frame = false;
          background-fixed = false;
        };
      };

      # Regras modernas no formato libconfig (rules)
      extraConfig = ''
        rules = (
          {
            match = "window_type = 'normal'";
            fade = true;
            shadow = true;
            ${lib.optionalString hasBlur "blur-background = true;"}
          },
          {
            match = "window_type = 'dialog'";
            shadow = true;
            corner-radius = 10;
          },
          {
            match = "window_type = 'tooltip' || window_type = 'menu' || window_type = 'dropdown_menu' || window_type = 'popup_menu'";
            corner-radius = 8;
            shadow = false;
            opacity = 0.95;
          },
          {
            match = "fullscreen";
            corner-radius = 0;
            shadow = false;
          },
          {
            match = "class_g = 'Polybar'";
            shadow = false;
            corner-radius = 12;
            opacity = 1.0;
            ${lib.optionalString hasBlur "blur-background = true;"}
          },
          {
            match = "class_g = 'Alacritty' || class_g = 'kitty'";
            opacity = 0.92;
            ${lib.optionalString hasBlur "blur-background = true;"}
          },
          {
            match = "class_g = 'Rofi'";
            opacity = 0.95;
            corner-radius = 16;
            shadow = true;
            ${lib.optionalString hasBlur "blur-background = true;"}
          },
          {
            match = "class_g = 'Dunst'";
            opacity = 0.95;
            corner-radius = 12;
            shadow = true;
            ${lib.optionalString hasBlur "blur-background = true;"}
          },
          {
            match = "class_g = 'slop' || class_g = 'Screenkey' || _GTK_FRAME_EXTENTS@";
            shadow = false;
            corner-radius = 0;
          }
        );
      '';
    };
  };
}
