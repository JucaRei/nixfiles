{ config, lib, pkgs, ... }:
{
  networking = {
    # Disabling DHCPCD in favor of NetworkManager
    dhcpcd = {
      enable = false;
    };
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
      # connectionConfig = {
      #   "ethernet.mtu" = 1462;
      #   "wifi.mtu" = 1462;
      # };

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


## DoH (DNS over HTTPS)
# services.dnscrypt-proxy2 = {
#   enable = true;
#   settings = {
#     require_dnssec = true;
#     ipv4_servers = true;
#     ipv6_servers = false;
#     dnscrypt_servers = true;
#     doh_servers = true;
#     require_nolog = true; # Server must not log user queries (declarative)

#     sources.public-resolvers = {
#       urls = [
#         "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
#         "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
#       ];
#       cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
#       minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
#     };

#     # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
#     # Leaving this off should find the fastest one automagically
#     # server_names = [ ... ];
#   };
# };
