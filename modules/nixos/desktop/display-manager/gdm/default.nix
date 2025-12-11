{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.display-managers;
in
{
  options = {
    desktop.display-managers.gdm = {
      wayland-session = mkOption {
        type = bool;
        default = if (config.desktop.backend == "wayland") then true else false;
        description = "Enable Wayland support.";
      };
    };
  };
  config = mkIf (cfg.chosen == "gdm") {
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
