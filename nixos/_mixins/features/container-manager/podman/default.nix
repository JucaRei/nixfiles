{ config, isWorkstation, lib, pkgs, username, ... }:
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
  config = mkIf cfg.manager == "podman" {
    #https://nixos.org/wiki/Podman
    environment = {
      systemPackages =
        with pkgs;
        [
          distrobox
          podman-compose
          docker-compose-check
          fuse-overlayfs
        ]
        ++ lib.optionals isWorkstation [
          boxbuddy
          pods
        ];
    };

    hardware.nvidia-container-toolkit.enable = hasNvidiaGPU;

    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings = {
          # containers.dns_servers = [
          #   "8.8.8.8"
          #   "8.8.4.4"
          # ];
        };
        registries = {
          search = [
            "docker.io"
            "ghcr.io"
          ];
          insecure = [
            "registry.fedoraproject.org"
            "quay.io"
            "registry.access.redhat.com"
            "registry.centos.org"
          ];
        };
      };
      podman = {
        defaultNetwork.settings = {
          dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
        };
        dockerCompat = true;
        dockerSocket.enable = true;
        enable = true;
      };
    };

    security = {
      # Disable unprivileged user namespaces, unless containers are enabled
      # required by podman to run containers in rootless mode.
      unprivilegedUsernsClone = config.virtualisation.containers.enable;
    };

    users.users.${username}.extraGroups = lib.optional config.virtualisation.podman.enable "podman";
  };
}
