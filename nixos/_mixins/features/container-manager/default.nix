{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.features.container-manager;
in
{
  imports = [
    ./docker
    ./podman
  ];

  options = {
    features.container-manager = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enables container manager";
      };
      manager = mkOption {
        type = types.enum [ "docker" "podman" ];
        default = "podman";
        description = "Default container manager.";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80; # enable access port 80
    };
  };
}
