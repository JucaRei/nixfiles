{ config, lib, ... }: {
  config = {
    desktop.bspwm = {
      enable = true;
      sxhkd.enable = true;
      polybar.enable = true;
      packages.enable = true;
    };

    system.programs = {
      # browsers.firefox = {
      #   enable = true;
      #   version = "firefox-devedition";
      # };
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
