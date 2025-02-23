{ options, config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.system.security.keyring;
  gnome-env = config.desktop.environment.gnome;
in
{
  options.system.security.keyring = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Whether to enable gnome keyring.";
    };
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
