{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm.dunst;
in
{
  options.desktop.dwm.dunst = {
    enable =
      lib.my.mkBool (config.desktop.dwm.enable && config.desktop.dwm.bar != "quickshell")
        "Enable dunst notification daemon for dwm (automatically disabled when Quickshell is active to prevent D-Bus collision)";
  };

  config = mkIf cfg.enable {
    desktop.shared.dunst.enable = true;
  };
}
