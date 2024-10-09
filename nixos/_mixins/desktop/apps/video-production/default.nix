{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.video-production;
in
{
  options = {
    desktop.apps.video-production = {
      enable = mkEnableOption "Enable some softwares for videos productions.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (davinci-resolve.override {
        studioVariant = true;
      })
      shotcut
    ];
  };
}
