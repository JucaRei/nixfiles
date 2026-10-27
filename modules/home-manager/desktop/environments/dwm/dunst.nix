{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.dwm.dunst;
in
{
  options.desktop.dwm.dunst = {
    enable = mkOption {
      type = bool;
      default = config.desktop.dwm.enable && config.desktop.dwm.bar != "quickshell";
      description = "Enable dunst notification daemon for dwm (automatically disabled when Quickshell is active to prevent D-Bus collision)";
    };
  };

  config = mkIf cfg.enable {
    desktop.shared.dunst.enable = true;
  };
}
