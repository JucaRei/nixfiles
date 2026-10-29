{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm.rofi;
in
{
  options.desktop.dwm.rofi = {
    enable = lib.my.mkBool config.desktop.dwm.enable "Enable rofi application launcher for dwm";
  };

  config = mkIf cfg.enable {
    desktop.shared.rofi.enable = true;
  };
}
