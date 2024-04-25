{ config, ... }: {
  programs = {
    rofi = {
      enable = true;
    };
  };

  home.file = {
    "${config.xdg.configHome}/rofi/theme" = {
      source = ../../../config/rofi/dark;
      recursive = true;
    };
  };
}
