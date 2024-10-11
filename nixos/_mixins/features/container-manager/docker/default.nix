{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkIf mkForce;
  cfg = config.features.container-manager;
  hasNvidiaGPU = lib.elem "nvidia" config.services.xserver.videoDrivers;
  docker_storage_driver =
    if config.fileSystems."/".fsType == "btrfs"
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

      sessionVariables = {
        DOCKER_HOST = "unix:///var/run/docker.sock";
      };
    };

    hardware.nvidia-container-toolkit.enable = hasNvidiaGPU;

    virtualisation = {
      oci-containers.backend = mkForce "docker";
      containers = {
        registries.search = [
          "docker.io"
          "gcr.io"
          "quay.io"
        ];
        storage.settings = {
          storage = {
            driver = if docker_storage_driver == "btrfs" then "btrfs" else "overlay";
            graphroot = "/var/lib/containers/storage";
            runroot = "/run/containers/storage";
          };
        };
      };
      docker = {
        enable = true;
        enableOnBoot = false;
        # enableNvidia = hasNvidiaGPU;
        storageDriver = docker_storage_driver;
        logDriver = "json-file";
        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {
            dns = [ "1.1.1.1" "8.8.8.8" ];
            runtimes = mkIf (hasNvidiaGPU) {
              nvidia = {
                path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
              };
            };
          };
        };
      };

    };
    users.users.${username}.extraGroups = [ "docker" ];
  };
}
