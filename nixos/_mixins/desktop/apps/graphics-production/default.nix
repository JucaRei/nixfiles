{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.graphics-production;
in
{
  options = {
    desktop.apps.graphics-production = {
      enable = mkEnableOption "Whether enable graphics for production.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inkscape
      pinta
    ];
  };
}
