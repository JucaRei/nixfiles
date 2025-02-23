{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.types) str listOf;
  cfg = config.system.locales;
in
{
  options = {
    system.locales = {
      enable = mkEnableOption "Enable locales support";
      addionalLocales = lib.mkOption {
        type = listOf str;
        default = [ ];
        description = "Additional locales to be generated.";
      };
    };
  };

  config = mkIf cfg.enable {

    i18n = {
      defaultLocale = "en_US.utf8";
      extraLocaleSettings = {
        #LC_CTYPE =  "pt_BR.UTF-8"; # Fix ç in us-intl.
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
      supportedLocales = [
        "pt_BR.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ] ++ cfg.addionalLocales;
    };

    environment = {
      variables = {
        # Set locale archive variable in case it isn't being set properly
        LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";
      };
    };

  };
}
