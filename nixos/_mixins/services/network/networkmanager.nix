{ config, lib, pkgs, ... }:
{
  networking = {
    # firewall = {
    #   allowedTCPPorts = [ 5355 ];
    #   allowedUDPPorts = [ 5353 5355 ];
    # };
    networkmanager = {
      enable = true;
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
    };
    wireless.iwd.package = pkgs.unstable.iwd;
  };
  systemd = {
    services = {
      # Workaround https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = false;
      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd-udev-settle.enable = false;
      # systemd-user-sessions.enable = false;
    };
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
