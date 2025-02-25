{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.graphical.apps.davinci;
in
{
  options = {
    programs.graphical.apps.davinci = {
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
