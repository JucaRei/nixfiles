{ config, ... }:
let
  torrent = "transmission-gtk.desktop";
in
{
  config = {
    # networking.firewall.allowedTCPPorts = [ 9091 ];
    services.transmission = {
      enable = true;
      downloadDirPermissions = "775";
      openFirewall = true;
      settings = {
        alt-speed-down = 3000;
        alt-speed-enabled = true;
        alt-speed-time-begin = 1000;
        alt-speed-time-day = 10270;
        alt-speed-time-enabled = true;
        alt-speed-time-end = 1380;
        alt-speed-up = 4000;
        download-dir = "$HOME/Downloads/transmission/Downloads";
        incomplete-dir = "$HOME/Downloads/transmission/.incomplete";
        ratio-limit-enabled = true;
        rpc-bind-address = "0.0.0.0";
        rpc-enabled = true;
        rpc-port = 9091;
        # rpc-host-whitelist = "${config.networking.hostName}";
        # rpc-whitelist = "10.100.0.*,10.0.0.*,192.168.100.*";
        rpc-whitelist = "127.0.0.1,192.168.*.*";
        rpc-host-whitelist = "*";
        rpc-host-whitelist-enabled = true;
      };
    };

    xdg.mimeApps = rec {
      enable = true;
      associations.added = defaultApplications;
      defaultApplications = { "x-scheme-handler/magnet" = torrent; };
    };

    # user.extraGroups = [ "transmission" ];
  };
}
