{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm.dunst;
in
{
  options.desktop.bspwm.dunst = {
    enable = lib.my.mkBool config.desktop.bspwm.enable "Enable dunst notification daemon for bspwm";
  };

  config = mkIf cfg.enable {
    desktop.shared.dunst.enable = true;
  };
}
