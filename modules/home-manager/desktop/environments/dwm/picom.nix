{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm.picom;

  gpuDriver = osConfig.hardware.graphics.cards.gpu or "unknown";
  isNvidiaLegacy = gpuDriver == "nvidia-legacy";
  isNouveauOrLegacy =
    isNvidiaLegacy || gpuDriver == "nouveau" || gpuDriver == "unknown" || gpuDriver == null;
in
{
  options.desktop.dwm.picom = {
    enable = lib.my.mkBool config.desktop.dwm.enable "Enable picom compositor for dwm";

    backend = lib.my.mkEnum [
      "xrender"
      "glx"
      "egl"
    ] (if isNouveauOrLegacy then "xrender" else "glx") "Picom rendering backend";
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      package = pkgs.picom;
      inherit (cfg) backend;
      vSync = true;
      shadow = true;
      shadowOpacity = 0.6;
      shadowOffsets = [
        (-12)
        (-12)
      ];
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
