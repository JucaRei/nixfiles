{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
  device = config.features.graphics;
in
{
  config = mkIf (device.backend == "x11") {
    environment = {
      # Fix issue with java applications and tiling window managers.
      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
      };
    };
    services = {
      gvfs = {
        enable = mkDefault true;
      };

      gnome.gnome-keyring = {
        enable = mkDefault true;
      };

      xserver = {
        enable = mkDefault true;
        desktopManager = {
          xterm.enable = mkDefault false;
        };
        displayManager = {
          sessionCommands = ''
            # GTK2_RC_FILES must be available to the display manager.
            export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
          '';
        };
      };
    };
  };
}
