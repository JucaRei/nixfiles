{ config, lib, pkgs, username, ... }:
let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.programs.graphical.apps.social.telegram;
in
{
  options.programs.graphical.apps.social.telegram = {
    enable = mkEnableOption "Installs telegram.";
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        unstable.telegram-desktop
      ];
    };
  };
}
