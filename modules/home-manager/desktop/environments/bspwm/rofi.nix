{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.rofi;
in
{
  options.desktop.bspwm.rofi = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable rofi application launcher for bspwm";
    };
  };

  config = mkIf cfg.enable {
    desktop.shared.rofi.enable = true;
  };
}
