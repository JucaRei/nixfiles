{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.desktop.display-managers.lightdm;
in
{
  options.${namespace}.desktop.display-managers.lightdm = {
    enable = mkBoolOpt false "Whether or not to enable lightdm.";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager.lightdm = {
        enable = true;

        greeters = {
          gtk = {
            enable = true;

            cursorTheme = {
              inherit (config.${namespace}.desktop.addons.gtk.cursor) name;
              package = config.${namespace}.desktop.addons.gtk.cursor.pkg;
            };

            iconTheme = {
              inherit (config.${namespace}.desktop.addons.gtk.icon) name;
              package = config.${namespace}.desktop.addons.gtk.icon.pkg;
            };

            theme = {
              name = "${config.${namespace}.desktop.addons.gtk.theme.name}";
              package = config.${namespace}.desktop.addons.gtk.theme.pkg;
            };
          };
        };
      };
    };

    security.pam.services.greetd = {
      enableGnomeKeyring = true;
      gnupg.enable = true;
    };
  };
}
