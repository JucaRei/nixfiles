{ config, lib, pkgs, ... }:
{
  networking = {
    # firewall = {
    #   allowedTCPPorts = [ 5355 ];
    #   allowedUDPPorts = [ 5353 5355 ];
    # };
    networkmanager = {
      enable = true;
      # Append Cloudflare and Google DNS servers
      appendNameservers = [ "1.1.1.1" "8.8.8.8" ];

      #---------------------------------------------------------------------
      # Prevent fragmentation and reassembly, which can improve network performance
      #---------------------------------------------------------------------
      connectionConfig = {
        "ethernet.mtu" = 1462;
        "wifi.mtu" = 1462;
      };

      # Use AdGuard Public DNS with ad/tracker blocking
      #  - https://adguard-dns.io/en/public-dns.html
      # insertNameservers = [ "94.140.14.14" "94.140.15.15" ];
      wifi = {
        backend = "iwd";
        powersave = false;
        #macAddress = "random";
        #scanRandMacAddress = true;
      };
      ethernet = {
        #macAddress = "random";
      };
      # plugins = with pkgs; [
      #   networkmanager-openvpn
      #   networkmanager-openconnect
      # ];

      # defaultGateway = "192.168.1.1";
      # interfaces.enp3s0.ipv4.addresses = [{
      #  address = "192.168.0.13";
      #  prefixLength = 24;
      # }];

      # terminal: arp -a
    };
    wireless.iwd.package = pkgs.unstable.iwd;
  };

  # services = {
  #   resolved = {
  #     enable = true;
  #     dnssec = "allow-downgrade";
  #     fallbackDns = [
  #       "1.1.1.1"
  #       "8.8.8.8"
  #     ];
  #     llmnr = "true";
  #     extraConfig = ''
  #       Domains=~.
  #       MulticastDNS=true
  #     '';
  #   };
  # };

  # system.nssDatabases.hosts = lib.mkMerge [
  #   (lib.mkBefore [ "mdns_minimal [NOTFOUND=return]" ])
  #   (lib.mkAfter [ "mdns" ])
  # ];
}
