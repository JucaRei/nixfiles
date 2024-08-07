{ config, ... }: {
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
}
