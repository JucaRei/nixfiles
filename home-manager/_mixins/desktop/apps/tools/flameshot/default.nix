{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.desktop.apps.tools.flameshot;
in
{
  options.desktop.apps.tools.flameshot = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Only evaluate code if using X11
    services = {
      # sxhkd shortcut = Printscreen button (Print)
      flameshot = {
        enable = true;
        settings = {
          General = {
            # Settings
            savePath = "${config.home.homeDirectory}/Pictures/screenshots";
            saveAsFileExtension = ".png";
            uiColor = "#2d0096";
            showHelp = "false";
            disabledTrayIcon = "true"; # Hide from systray
          };
        };
      };
    };
  };
}
