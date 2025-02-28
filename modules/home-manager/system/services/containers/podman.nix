{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf optionals;
  inherit (lib.types) bool;
  cfg = config.system.services.containers;
in
{
  options = {
    system.services.containers = {
      podman = {
        enable = mkOption {
          type = bool;
          default = false;
          description = "Enable's podman container's on home-manager.";
        };
      };
    };
  };
  config = mkIf cfg.enable {

    services = {
      podman = {
        enable = true;
        package = pkgs.podman;
        # autoUpdate = {
        # enable = true;
        # onCalendar = "*-*-* 00:00:00";
        # };
        # containers = { };
      };
    };

    home = {
      shellAliases = {
        docker = "podman";
        docker-compose = "podman-compose";
      };

      packages = with pkgs; [
        podman-compose
        fuse-overlayfs
      ] ++ optionals (isWorkstation) [
        podman-desktop
      ];

    };

    # systemd.user.services."user@".serviceConfig = {
    systemd.user.services."podman".serviceConfig = {
      Delegate = "cpu cpuset io memory pids";
    };
  };
}
