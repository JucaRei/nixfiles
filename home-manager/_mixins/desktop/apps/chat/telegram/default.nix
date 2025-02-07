{ config, lib, pkgs, username, ... }:
let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.desktop.apps.chat.telegram;
in
{
  options.desktop.apps.chat.telegram = {
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
