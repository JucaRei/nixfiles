{ config, lib, pkgs, ... }:
{
  networking = {
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
    # Workaround https://github.com/NixOS/nixpkgs/issues/180175
    services.NetworkManager-wait-online.enable = false;
    # Speed up boot
    # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
    services.systemd-udev-settle.enable = false;
  };
}
