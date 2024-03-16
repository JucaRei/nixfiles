{ config, lib, pkgs, hostname, desktop, ... }:
let
  # hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  dockerEnabled = config.virtualisation.docker.enable;
in
{
  #https://nixos.wiki/wiki/Podman

  environment = {
    systemPackages = with pkgs;
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
    etc = {
      "containers/registries.conf".text = lib.mkForce ''
        unqualified-search-registries = ['docker.io']

        [[registry]]
        prefix="docker.io"
        location="docker.io"

        [[registry.mirror]]
        location="mirror.gcr.io"
      '';
    };
  };

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
      enableNvidia = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;

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

  # Fix for docker compat (vscode)
  systemd.user = {
    services = {
      "podman-prune" = {
        description = "Cleanup podman images";
        requires = [ "podman.socket" ];
        after = [ "podman.socket" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.podman} image prune --all --external --force";
        };
      };
    };
    timers."podman-prune" = {
      partOf = [ "podman-prune.service" ];
      timerConfig = {
        OnCalendar = "weekly";
        RandomizedDelaySec = "900";
        Persistent = "true";
      };
    };
  };
}
