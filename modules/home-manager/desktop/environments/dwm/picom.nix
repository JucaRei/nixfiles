{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm.picom;
in
{
  options.desktop.dwm.picom = {
    enable = lib.my.mkBool config.desktop.dwm.enable "Enable picom compositor for dwm";

    backend = lib.my.mkOpt (lib.types.nullOr (
      lib.types.enum [
        "xrender"
        "glx"
        "egl"
      ]
    )) null "Picom rendering backend override";
  };

  config = mkIf cfg.enable {
    desktop.shared.picom = {
      enable = true;
      environment = "dwm";
    }
    // lib.optionalAttrs (cfg.backend != null) {
      inherit (cfg) backend;
    };
  };
}
