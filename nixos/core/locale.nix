{ lib, config, username, hostname, ... }:
let
  inherit (lib) mkDefault;
  variables = import ../hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check
in
{
  #######################
  ### Default Locales ###
  #######################
  i18n = {
    defaultLocale = mkDefault "${variables.df-locale}";
    extraLocaleSettings = mkDefault {
      #LC_CTYPE = mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "${variables.extra-locale}";
      LC_IDENTIFICATION = "${variables.extra-locale}";
      LC_MEASUREMENT = "${variables.extra-locale}";
      LC_MONETARY = "${variables.extra-locale}";
      LC_NAME = "${variables.extra-locale}";
      LC_NUMERIC = "${variables.extra-locale}";
      LC_PAPER = "${variables.extra-locale}";
      LC_TELEPHONE = "${variables.extra-locale}";
      LC_TIME = "${variables.extra-locale}";
      #LC_COLLATE = "${variables.extra-locale}";
      #LC_MESSAGES = "${variables.extra-locale}";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
    ];
  };
}
