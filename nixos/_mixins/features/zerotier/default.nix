{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.features.zerotier;
in
{
  options = {
    features.zerotier = {
      enable = mkEnableOption "Whether enable zerotier.";
    };
  };
  config = mkIf cfg.enable {
    networking = {
      firewall = {
        checkReversePath = "loose";
        allowedUDPPorts = [ config.services.zerotierone.port ];
        trustedInterfaces = [ "ztwfukvgqh" ];
      };
    };
    services.zerotierone = {
      enable = true;
      joinNetworks = [ "a0cbf4b62aa0391f" ];
    };
  };
}
