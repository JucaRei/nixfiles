{ config, lib, hostname, ... }:
with lib;
let
  # Firewall configuration variable for syncthing
  syncthing = {
    hosts = [
      "air"
      "rocinante"
      "DietPi"
      "nitro"
      "vm"
      "minimech"
      "soyo"
      "scrubber"
    ];
    tcpPorts = [ 22000 443 22 2375 9091 ];
    udpPorts = [ 22000 21027 53 5353 ];
    allowedTCPPorts = [
      21 # FTP
      53 # DNS
      80 # HTTP
      443 # HTTPS
      143 # IMAP
      389 # LDAP
      139 # Samba
      445 # Samba
      25 # SMTP
      22 # SSH
      5432 # PostgreSQL
      3306 # MySQL/MariaDB
      3307 # MySQL/MariaDB
      111 # NFS
      2049 # NFS
      2375 # Docker
      22000 # Syncthing port
      9091 # Transmission
      51413 # Transmission
      80 # For gnomecast server
      8010 # For gnomecast server
      8888 # For gnomecast server
      5357 # wsdd : samba
      # Open KDE Connect
      {
        from = 1714;
        to = 1764;
      }
      # Teamviewer
      # 5938
      8200
    ];

    allowedUDPPorts = [
      53 # DNS
      137 # NetBIOS Name Service
      138 # NetBIOS Datagram Service
      3702 # wsdd : samba
      51413 # Transmission
      5353 # For device discovery
      21027 # Syncthing port
      # Teamviewer
      # 5938
      # Open KDE Connect
      {
        from = 1714;
        to = 1764;
      }
      22000 # Syncthing port
      8200 # Syncthing port
    ];
  };

  cfg = config.services.firewall;
in
{
  options.services.firewall.enable = mkEnableOption "Weather enable or not Firewall";
  config = mkIf cfg.enable {
    networking = {
      firewall = {
        interfaces."podman[0-9]+".allowedUDPPorts = [ 53 ];
        allowPing = true;
        enable = true;
        allowedTCPPorts =
          [
            # syncthing.allowedTCPPorts
          ]
          ++ lib.optionals (builtins.elem hostname syncthing.hosts)
            syncthing.tcpPorts;
        allowedUDPPorts =
          [
            # syncthing.allowedUDPPorts
          ]
          ++ lib.optionals (builtins.elem hostname syncthing.hosts)
            syncthing.udpPorts;

        #---------------------------------------------------------------------
        # Adding a rule to the iptables firewall to allow NetBIOS name
        # resolution traffic on UDP port 137
        #---------------------------------------------------------------------

        extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
      };
    };
  };
}
