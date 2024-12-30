{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf mkForce types;
  cfg = config.console.aria2;
  configDownloads = config.home.homeDirectory + "/Downloads";
in
{
  options.console.aria2 = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      aria
      ariang
    ];
    programs.aria2 = {
      enable = true;
      settings = {
        # Download directory
        dir = mkForce "${configDownloads}/aria";
        check-integrity = true;

        ## General optimization
        # Don't download files if they're already in the download directory
        conditional-get = true;
        # file-allocation = "falloc"; # Assume ext4, this is faster there
        optimize-concurrent-downloads = true;
        # disk-cache = "512M"; # In-memory cache to avoid fragmentation

        ## Torrent options
        bt-force-encryption = true;
        bt-detach-seed-only = true; # Don't block downloads when seeding
        seed-ratio = 2;
        seed-time = 60;

        listen-port = "6881-6999";
        dht-listen-port = "6881-6999";
        rpcListenPort = 6881;
        # rpcSecretFile = /run/secrets/aria2-rpc-token.txt;
      };
    };
    # systemd.user.services.ariang = {
    #   description = "Server aria_ng";
    #   path = [ pkgs.static-web-server ];
    #   unitConfig = {
    #     Type = "simple";
    #   };
    #   serviceConfig = {
    #     ExecStart = "${pkgs.static-web-server}/bin/static-web-server -p 6999 -d ${pkgs.ariang}";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };
  };
}
