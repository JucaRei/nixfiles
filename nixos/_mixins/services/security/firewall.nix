{ lib, hostname, ... }:
let
  # Firewall configuration variable for syncthing
  syncthing = {
    hosts = [
      "air"
      "rocinante"
      "DietPi"
      "nitro"
      "brix"
      "designare"
      "micropc"
      "nuc"
      "p1"
      "p2-max"
      "ripper"
      "skull"
      "trooper"
      "vm"
      "win2"
      "win-max"
      "zed"
    ];
    tcpPorts = [ 22000 ];
    udpPorts = [ 22000 21027 ];
  };
in
{
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.tcpPorts;
      allowedUDPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.udpPorts;
    };
  };
}
