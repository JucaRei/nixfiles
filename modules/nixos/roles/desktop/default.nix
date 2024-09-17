{ config, lib, namespace, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.roles.desktop;
in
{
  options.${namespace}.roles.desktop = {
    enable = mkEnableOption "Enable desktop configuration";
  };

  config = mkIf cfg.enable {
    excalibur = {
      roles = {
        common.enable = true;
      };

      hardware = {
        audio.enable = true;
      };

      services = {
        avahi.enable = true;
      };

      system = {
        fonts.enable = true;
      };

      user = {
        name = "juca";
        initialPassword = "password";
      };
    };

    services.avahi.enable = true;
  };
}
