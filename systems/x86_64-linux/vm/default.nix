{ lib, pkgs, config, namespace, ... }:
with lib;
with lib.${namespace};
{
  imports = [ ./hardware.nix ];

  ${namespace} = {
    nix = enabled;

    archetypes = {
      workstation = enabled;
    };

    desktop = {
      environment = {
        gnome = {
          enable = true;
        };
      };
    };

    system = {
      xkb = {
        keyboards = "ptBR";
      };
    };
  };

  system.stateVersion = "22.11";
}
