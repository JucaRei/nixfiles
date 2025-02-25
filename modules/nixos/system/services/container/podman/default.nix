{ config, isWorkstation, lib, pkgs, username, ... }:
let
  inherit (lib) mkIf mkForce;
  cfg = config.system.services.container;
  hasNvidiaGPU = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  config = mkIf (cfg.manager == "podman") {
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
      oci-containers.backend = mkForce "podman";
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
        storage.settings = {
          storage = {
            driver = "overlay";
            graphroot = "/var/lib/containers/storage";
            runroot = "/run/containers/storage";
          };
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

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 10485760;
      "fs.inotify.max_user_instances" = 1024;
    };

    users.users.${username}.extraGroups = lib.optional config.virtualisation.podman.enable "podman";
  };
}
