{ lib, hostname, ... }: {
  #######################
  ### Default Locales ###
  #######################

  i18n = {
    defaultLocale = lib.mkForce "en_US.utf8";
    extraLocaleSettings = lib.mkDefault {
      #LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
      #LC_COLLATE = "pt_BR.UTF-8";
      #LC_MESSAGES = "pt_BR.UTF-8";
    };
    # supportedLocales = [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" ];
  };

  ########################
  ### Default Timezone ###
  ########################

  time.timeZone = lib.mkDefault "America/Sao_Paulo";
  location = {
    latitude = -23.53938;
    longitude = -46.65253;
  };

  # console = { useXkbConfig = true; };
}
