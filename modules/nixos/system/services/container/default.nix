{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool enum;
  cfg = config.system.services.container;
in
{
  imports = [
    ./docker
    ./podman
  ];

  options = {
    system.services.container = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enables container manager";
      };
      manager = mkOption {
        type = enum [ "docker" "podman" null ];
        default = null;
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
