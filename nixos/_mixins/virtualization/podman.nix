{ config, lib, pkgs, hostname, desktop, ... }:
let
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  dockerEnabled = config.virtualisation.docker.enable;
in
{
  #https://nixos.wiki/wiki/Podman

  environment.systemPackages = with pkgs;
    [
      # buildah # Container build tool
      # podman-tui
      podman
      podman-compose
      podman-tui
      # aardvark-dns
      # conmon # Container monitoring
      # runc
      # skopeo # Container registry utility
      fuse-overlayfs # Container overlay+shiftfs
      #dive             # Container analyzer
      #grype            # Container vulnerability scanner
      #conmon           # Container monitoring
      #skopeo           # Container registry utility
      #syft             # Container SBOM generator
    ];

  ### podman-shell.nix /examples_helper/shells/podman-shell.nix

  # podman-desktop; only if desktop defined.
  virtualisation = {
    ### Run Podman containers as systemd services "https://nixos.wiki/wiki/Podman"
    oci-containers = {
      backend = "podman";
      # containers = {
      # container-name = {
      # image = "container-image";
      #  autoStart = true;
      #  ports = [ "127.0.0.1:1234:1234" ];
      # };
    };

    podman = {
      defaultNetwork = {
        settings = {
          dns_enabled =
            true; # Required for containers under podman-compose to be able to talk to each other.
        };
      };
      dockerCompat = !dockerEnabled;
      dockerSocket.enable = !dockerEnabled;
      enable = true;
      enableNvidia = hasNvidia;
    };
    containers = {
      containersConf.settings = {
        containers.dns_servers = [
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
      registries = {
        search = [
          "docker.io"
          "quay.io"
        ];
        #   insecure = [
        #     "registry.fedoraproject.org"
        #     "quay.io"
        #     # "registry.access.redhat.com"
        #     # "registry.centos.org"
        #   ];
      };
    };
  };
}
