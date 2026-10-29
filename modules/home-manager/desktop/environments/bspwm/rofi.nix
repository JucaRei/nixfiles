{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm.rofi;
in
{
  options.desktop.bspwm.rofi = {
    enable = lib.my.mkBool config.desktop.bspwm.enable "Enable rofi application launcher for bspwm";
  };

  config = mkIf cfg.enable {
    desktop.shared.rofi.enable = true;
  };
}
