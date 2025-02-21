{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.security.keyring;
  gnome-env = config.${namespace}.desktop.environment.gnome;
in
{
  options.${namespace}.system.security.keyring = with types; {
    enable = mkBoolOpt false "Whether to enable gnome keyring.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome.gnome-keyring
      gnome.libgnome-keyring
    ];

    security = {
      pam.services = mkIf gnome-env {
        gdm.enableGnomeKeyring = true;
      };
    };
  };
}
