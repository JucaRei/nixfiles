{ lib, ... }: {
  #######################
  ### Default Locales ###
  #######################

  i18n = {
    defaultLocale = lib.mkForce "en_US.utf8";
    extraLocaleSettings = lib.mkDefault {
      #LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "pt_BR.utf8";
      LC_IDENTIFICATION = "pt_BR.utf8";
      LC_MEASUREMENT = "pt_BR.utf8";
      LC_MONETARY = "pt_BR.utf8";
      LC_NAME = "pt_BR.utf8";
      LC_NUMERIC = "pt_BR.utf8";
      LC_PAPER = "pt_BR.utf8";
      LC_TELEPHONE = "pt_BR.utf8";
      LC_TIME = "pt_BR.utf8";
      #LC_COLLATE = "pt_BR.utf8";
      #LC_MESSAGES = "pt_BR.utf8";
    };
    supportedLocales = [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" ];
  };

  ########################
  ### Default Timezone ###
  ########################

  services.xserver.layout = if (builtins.isString == "nitro") then "br" else "us";
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
  location = {
    latitude = -23.539380;
    longitude = -46.652530;
  };
}
