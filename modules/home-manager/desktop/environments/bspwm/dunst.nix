{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.dunst;
in
{
  options.desktop.bspwm.dunst = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable dunst notification daemon for bspwm";
    };
  };

  config = mkIf cfg.enable {
    desktop.shared.dunst.enable = true;
  };
}
