{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkIf;
  cfg = config.features.container-manager;
  hasNvidiaGPU = lib.elem "nvidia" config.services.xserver.videoDrivers;
  docker_storage_driver =
    if config.fileSystems.fsType == "btrfs"
    then "btrfs"
    else "overlay2";
in
{
  config = mkIf (cfg.manager == "docker") {
    environment = {
      systemPackages = with pkgs; [
        distrobox
        fuse-overlayfs # Container overlay+shiftfs
        docker-compose
        docker-compose-check
      ];
    };

    hardware.nvidia-container-toolkit.enable = hasNvidiaGPU;

    virtualisation = {
      docker = {
        enable = true;
        storageDriver = docker_storage_driver;
        logDriver = "json-file";
      };
    };

    users.users.${username}.extraGroups = [ "docker" ];
  };
}
