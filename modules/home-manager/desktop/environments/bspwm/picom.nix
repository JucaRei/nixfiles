{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm.picom;
in
{
  options.desktop.bspwm.picom = {
    enable = lib.my.mkBool config.desktop.bspwm.enable "Enable picom compositor for bspwm";

    backend = lib.my.mkOpt (lib.types.nullOr (
      lib.types.enum [
        "xrender"
        "glx"
        "egl"
      ]
    )) null "Picom rendering backend (glx for GPU acceleration, xrender for VMs/legacy)";

    cornerRadius =
      lib.my.mkOpt (lib.types.nullOr lib.types.int) null
        "Raio dos cantos arredondados das janelas em pixels";

    activeOpacity = lib.my.mkOpt (lib.types.nullOr (
      lib.types.numbers.between 0.0 1.0
    )) null "Opacidade das janelas ativas em foco (1.0 = totalmente opaco)";

    inactiveOpacity = lib.my.mkOpt (lib.types.nullOr (
      lib.types.numbers.between 0.0 1.0
    )) null "Opacidade das janelas inativas/desfocadas";

    blur = {
      enable = lib.my.mkOpt (lib.types.nullOr lib.types.bool) null "Enable dual_kawase background blur";
      strength = lib.my.mkOpt (lib.types.nullOr lib.types.int) null "Dual-Kawase blur strength (1-20)";
    };

    animations = {
      enable =
        lib.my.mkOpt (lib.types.nullOr lib.types.bool) null
          "Enable modern smooth window animations in picom";
    };

    shadows = {
      enable = lib.my.mkOpt (lib.types.nullOr lib.types.bool) null "Enable window shadows in picom";
    };

    useDamage =
      lib.my.mkOpt (lib.types.nullOr lib.types.bool) null
        "Only repaint modified regions of the screen";
  };

  config = mkIf cfg.enable {
    desktop.shared.picom = {
      enable = true;
      environment = "bspwm";
    }
    // lib.filterAttrs (_: v: v != null) {
      inherit (cfg)
        backend
        cornerRadius
        activeOpacity
        inactiveOpacity
        useDamage
        ;
    }
    // lib.optionalAttrs (cfg.blur.enable != null) {
      blur.enable = cfg.blur.enable;
    }
    // lib.optionalAttrs (cfg.blur.strength != null) {
      blur.strength = cfg.blur.strength;
    }
    // lib.optionalAttrs (cfg.animations.enable != null) {
      animations.enable = cfg.animations.enable;
    }
    // lib.optionalAttrs (cfg.shadows.enable != null) {
      shadows.enable = cfg.shadows.enable;
    };
  };
}
