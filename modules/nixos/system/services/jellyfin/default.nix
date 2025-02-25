{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  installOn = [ "soyo" ];
  cfg = config.system.services.jellyfin;
in
# mkIf (lib.elem config.networking.hostName installOn) {}
{
  options = {
    system.services.jellyfin = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enable Jellyfin media server";
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      jellyfin = {
        enable = true;
        dataDir = "/srv/state/jellyfin";
        openFirewall = true;
      };
    };
  };
}
