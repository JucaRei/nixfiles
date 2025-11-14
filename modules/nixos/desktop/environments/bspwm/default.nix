{ config, lib, pkgs, ... }: {
  config = {
    desktop.display-servers.backend = "x11";
    services = {
      displayManager = {
        enable = true;
        defaultSession = "none+bspwm";
      };
    };
  };
}
