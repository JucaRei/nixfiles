{ pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.features.virtualisation.k3s;
in
{
  options.features.virtualisation.k3s = {
    enable = mkEnableOption "Enables k3s kubernetes";
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 6443 ];
    services = {
      k3s.enable = true;
      k3s.role = "server";
      # services.k3s.extraFlags = toString [ "--TBD" ];
    };
    environment.systemPackages = with pkgs; [ k3s lvm2 helm ];

    # Needed for rook
    boot.kernelModules = [ "ceph" ];
  };
}
