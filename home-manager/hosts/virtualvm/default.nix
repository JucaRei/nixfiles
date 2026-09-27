{ config, lib, ... }: {
  config = {
    system.programs = {
      browsers.firefox.enable = true;
      terminal = {
        enable = true;
        name = "alacritty";
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
