{ lib, config, username, hostname, ... }:
let
  inherit (lib) mkDefault;
in
{
  #######################
  ### Default Locales ###
  #######################
  i18n = {
    defaultLocale = mkDefault "en_US.utf8";
    extraLocaleSettings = {
      #LC_CTYPE =  "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = mkDefault "pt_BR.UTF-8";
      LC_IDENTIFICATION = mkDefault "pt_BR.UTF-8";
      LC_MEASUREMENT = mkDefault "pt_BR.UTF-8";
      LC_MONETARY = mkDefault "pt_BR.UTF-8";
      LC_NAME = mkDefault "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = mkDefault "pt_BR.UTF-8";
      LC_TELEPHONE = mkDefault "pt_BR.UTF-8";
      LC_TIME = mkDefault "pt_BR.UTF-8";
    };
    supportedLocales = mkDefault [
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
    ];
  };
}
