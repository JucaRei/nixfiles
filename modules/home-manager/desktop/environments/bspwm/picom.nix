{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.picom;
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
      backend = "xrender"; # glx causa crash no Nouveau (NV50/GeForce 8600M GT)
      vSync = false; # VSync via glx não funciona com Nouveau; usar xrandr --setprovideroutputsource

      shadow = true;
      shadowOpacity = 0.6;
      shadowOffsets = [ (-12) (-12) ];
      shadowExclude = [
        "name = 'Notification'"
        "class_g = 'Polybar'"
        "class_g = 'Rofi'"
        "class_g = 'slop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      fade = true;
      fadeDelta = 4;
      fadeSteps = [ 0.03 0.03 ];

      settings = {
        corner-radius = 8;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'Polybar'"
        ];

        # Opacidade: sem dimming em hardware antigo
        active-opacity = 1.0;
        inactive-opacity = 1.0;
        inactive-opacity-override = false;
        focus-exclude = [
          "class_g = 'Polybar'"
          "class_g = 'Rofi'"
          "class_g = 'flameshot'"
        ];

        # Melhorar desempenho no xrender
        use-damage = true;
      };
    };
  };
}
