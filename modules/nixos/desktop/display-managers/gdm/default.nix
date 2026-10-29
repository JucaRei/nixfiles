{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.display-managers.gdm;
in
{
  options = {
    desktop.display-managers.gdm = {
      enable = lib.my.mkBool false "Enable GDM as the display manager.";
    };
  };
  config = mkIf cfg.enable {
    services = {
      xserver = {
        displayManager = {
          gdm = {
            autoSuspend = false;
            settings = {
              daemon = {
                # Enable fingerprint authentication in GDM
                FingerprintAuthentication = mkIf config.services.fprintd.enable true;
              };
              Theme = {
                CursorTheme = {
                  name = "layan-border_cursors";
                  package = pkgs.layan-cursors;
                  size = 24;
                };
              };
            };
          };
        };
      };
    };
  };
}
