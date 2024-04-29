{ pkgs, lib, config, ... }:
with lib;
with lib.hm.gvariant;
let
  cfg = config.services.aria2;
in
{
  options.services.aria2 = {
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
        listen-port = "6881-6999";
        dht-listen-port = "6881-6999";
        rpcListenPort = 6881;
        # rpcSecretFile = /run/secrets/aria2-rpc-token.txt;
      };
    };
    systemd.user.services.ariang = {
      description = "Server aria_ng";
      path = [ pkgs.static-web-server ];
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        ExecStart = "${pkgs.static-web-server}/bin/static-web-server -p 6999 -d ${pkgs.ariang}";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
