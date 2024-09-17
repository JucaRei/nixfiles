{ config, lib, namespace, ... }:
let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.system.locale;
in
{
  options.${namespace}.system.locale = {
    enable = mkBoolOpt false "Whether or not to manage locale settings.";
  };

  config = mkIf cfg.enable {
    i18n = {
      defaultLocale = mkDefault "en_US.UTF-8";
      extraLocaleSettings = mkDefault {
        #LC_CTYPE = mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = mkForce "us";
    };

    time.timeZone = mkDefault "America/Sao_Paulo";
  };
}
