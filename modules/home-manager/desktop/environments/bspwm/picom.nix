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
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      package = pkgs.picom;
      # nvidia-legacy 340 e Nouveau usam xrender para estabilidade; GPUs modernas usam glx
      backend = if isNouveauOrLegacy then "xrender" else "glx";
      vSync = !isNouveauOrLegacy;

      shadow = true;
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
      };
    };
  };
}
