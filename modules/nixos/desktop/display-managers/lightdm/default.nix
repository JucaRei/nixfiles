{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf;
in
{
  options = {
    desktop.display-managers.lightdm = {
      enable = mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable LightDM as the display manager.";
      };
    };
  };

  config = {
    desktop.display-servers.backend = "x11";
    services = {
      xserver = { };
    };
  };
}

