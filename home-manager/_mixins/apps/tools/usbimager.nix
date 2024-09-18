{ pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.custom.apps.usbimager;
in
{
  options.custom.apps.transmission = {
    enable = mkEnableOption "Whether enable transmission.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      usbimager
    ];

    xdg = {
      desktopEntries = {
        # The usbimager icon pasth is hardcoded, so override the desktop file
        usbimager = {
          name = "USBImager";
          exec = "${pkgs.usbimager}/bin/usbimager";
          terminal = false;
          icon = "usbimager";
          type = "Application";
          categories = [ "System" "Application" ];
        };
      };
    };
  };
}
