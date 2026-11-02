{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm;
  sets = import ../../packages/sets.nix { inherit pkgs; };
in
{
  config = mkIf cfg.enable {
    home.packages =
      sets.x11
      ++ (with pkgs; [
        # Utilitários específicos do DWM e scripts do Titus
        dmenu
        slstatus
        rofi-power-menu
        betterlockscreen
        i3lock-color
        lightlocker
        inotify-tools
        sxiv
        gawk
        gnused
        coreutils
      ]);
  };
}
