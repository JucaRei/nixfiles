{ config, lib, ... }: {
  config = {
    system.programs = {
      browsers.firefox = {
        enable = true;
        version = "firefox-devedition";
      };
      console = {
        eza.enable = true;
        bat.enable = true;
      };
      shells = {
        enable = true;
      };
    };
  };
}
