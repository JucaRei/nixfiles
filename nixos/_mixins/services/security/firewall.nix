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
    # tcpPorts = [ 22000 ];
    # udpPorts = [ 22000 21027 53 5353 ];
    allowedTCPPorts = [
      # FTP
      21
      # DNS
      53
      # HTTP
      80
      # HTTPS
      443
      # IMAP
      143
      # LDAP
      389
      # Samba
      139
      445
      # SMTP
      25
      # SSH
      22
      # PostgreSQL
      5432
      # MySQL/MariaDB
      3306
      3307
      # NFS
      111
      2049
      # Docker
      2375
      # Syncthing port
      22000
      # Transmission
      9091
      60450
      # For gnomecast server
      80
      8010
      8888
      # wsdd : samba
      5357
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
      # DNS
      53
      # NetBIOS Name Service
      137
      # NetBIOS Datagram Service
      138
      # wsdd : samba
      3702
      # For device discovery
      5353
      # Syncthing port
      21027
      # Teamviewer
      # 5938
      # Open KDE Connect
      {
        from = 1714;
        to = 1764;
      }
      # Syncthing port
      22000
      8200
    ];
  };
in
{
  networking = {
    firewall = {
      allowPing = true;
      enable = true;
      allowedTCPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.tcpPorts;
      allowedUDPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.udpPorts;

      #---------------------------------------------------------------------
      # Adding a rule to the iptables firewall to allow NetBIOS name
      # resolution traffic on UDP port 137
      #---------------------------------------------------------------------

      extraCommands =
        "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
    };
  };
}
