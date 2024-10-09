{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.libreoffice;
in
{
  options = {
    desktop.apps.blender = {
      enable = mkEnableOption "Whether enable Office packages.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ libreoffice ];
  };
}
