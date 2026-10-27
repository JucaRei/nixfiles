{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.dwm.rofi;
in
{
  options.desktop.dwm.rofi = {
    enable = mkOption {
      type = bool;
      default = config.desktop.dwm.enable;
      description = "Enable rofi application launcher for dwm";
    };
  };

  config = mkIf cfg.enable {
    desktop.shared.rofi.enable = true;
  };
}
