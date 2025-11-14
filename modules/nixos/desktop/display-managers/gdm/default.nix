{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.display-managers.gdm;
in
{
  options = {
    desktop.display-managers.gdm = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable GDM as the display manager.";
      };
      wayland-session = mkOption {
        type = bool;
        default = false;
        description = "Enable Wayland support.";
      };
    };
  };
  config = {
    services = {
      xserver = {
        displayManager = {
          gdm = {
            wayland = cfg.wayland-session;
            autoSuspend = false;
            settings = {
              daemon = {
                # Enable fingerprint authentication in GDM
                FingerprintAuthentication = mkIf (config.services.fprintd.enable) true;
              };
              Theme = {
                CursorTheme = {
                  name = "layan-border_cursors";
                  package = pkgs.layan-cursors;
                  size = 24;
                };
                # cursorTheme = {
                #   name = "Dracula-cursors";
                #   package = pkgs.dracula-theme;
                #   size = 16;
                # };
              };
            };
          };
        };
      };
    };
  };
}
