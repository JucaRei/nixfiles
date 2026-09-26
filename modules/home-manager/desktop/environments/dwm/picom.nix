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
  cfg = config.desktop.dwm.picom;

  gpuDriver = osConfig.hardware.graphics.cards.gpu or "unknown";
  isNvidiaLegacy = gpuDriver == "nvidia-legacy";
  isNouveauOrLegacy = isNvidiaLegacy || gpuDriver == "nouveau" || gpuDriver == "unknown" || gpuDriver == null;
in
{
  options.desktop.dwm.picom = {
    enable = mkOption {
      type = bool;
      default = config.desktop.dwm.enable;
      description = "Enable picom compositor for dwm";
    };

    backend = mkOption {
      type = lib.types.enum [ "xrender" "glx" "egl" ];
      default = if isNouveauOrLegacy then "xrender" else "glx";
      description = "Picom rendering backend";
    };
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      package = pkgs.picom;
      backend = cfg.backend;
      vSync = true;
      shadow = true;
      shadowOpacity = 0.6;
      shadowOffsets = [ (-12) (-12) ];
      fade = true;
      fadeDelta = 4;
      settings = {
        shadow-radius = 14;
        corner-radius = 8;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'dwm'"
        ];
        shadow-exclude = [
          "name = 'Notification'"
          "class_g = 'Conky'"
          "class_g ?= 'Notify-osd'"
          "class_g = 'Cairo-clock'"
          "_GTK_FRAME_EXTENTS@:c"
        ];
      };
    };
  };
}
