{ config, lib, pkgs, ... }: {
  config = {
    desktop.display-servers.backend = "x11";
    services = {
      xserver = {
        enable = true;
      };
    };
  };
}
