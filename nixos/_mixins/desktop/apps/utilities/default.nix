{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.utilities;
in
{
  options = {
    desktop.apps.utilities = {
      enable = mkEnableOption "Enable some utilities for desktop.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cpu-x
      gnome.dconf-editor
      pika-backup
      squirreldisk
      usbimager
    ];

    programs = {
      dconf.profiles.user.databases = [
        {
          settings = with lib.gvariant; {
            "ca/desrt/dconf-editor" = {
              show-warning = false;
            };
          };
        }
      ];
    };
  };
}
