{ lib, pkgs, username, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.desktop.apps.music;
in
{
  options = {
    desktop.apps.music = {
      enable = mkEnableOption "Enable some music packages";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        cider
        youtube-music
      ];
    };
  };
}
