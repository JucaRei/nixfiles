{ config, isWorkstation, lib, pkgs, username, hostname, ... }:
let
  installFor = [ "juca" ];
  hasNvidiaGPU = lib.elem "nvidia" config.services.xserver.videoDrivers;
  dockerEnabled = config.virtualisation.docker.enable;
in
lib.mkIf (lib.elem "${username}" installFor) {
  config =
    ### Podman
    if (isWorkstation && hostname != "soyo") then {
      boot.kernel.sysctl = {
        "net.ipv4.ip_unprivileged_port_start" = 80; # Podman access port 80
      };

      #https://nixos.org/wiki/Podman
      environment = {
        systemPackages =
          with pkgs;
          [
            distrobox
            fuse-overlayfs # Container overlay+shiftfs
            flyctl
          ]
          ++ lib.optionals isWorkstation [
            boxbuddy
            pods
            podman-compose
            # podman-tui
            #conmon           # Container monitoring
            #skopeo           # Container registry utility
            #syft             # Container SBOM generator
            #buildah          # Container build tool
            #dive             # Container analyzer
            #grype            # Container vulnerability scanner
            # runc
            # conmon # Container monitoring
            # aardvark-dns
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
          # registries = {
          #   search = [
          #     "docker.io"
          #     "quay.io"
          #     "ghcr.io"
          #   ];
          #   #   insecure = [
          #   #     "registry.fedoraproject.org"
          #   #     "quay.io"
          #   #     # "registry.access.redhat.com"
          #   #     # "registry.centos.org"
          #   #   ];
          # };
        };
        podman = {
          defaultNetwork.settings = {
            dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
          };
          dockerCompat = true;
          dockerSocket.enable = true;
          enable = true;
          enableNvidia = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
        };
      };

      security = {
        # Disable unprivileged user namespaces, unless containers are enabled
        # required by podman to run containers in rootless mode.
        unprivilegedUsernsClone = config.virtualisation.containers.enable;
      };

      users.users.${username}.extraGroups = lib.optional config.virtualisation.podman.enable "podman";
    } else {
      ### Docker
      virtualisation = {
        docker = {
          enable = true;
          storageDriver = "overlay2";
          logDriver = "json-file";
          # extraOptions = "-H 0.0.0.0:2376 --tlsverify --tlscacert /run/keys/docker/ca.pem --tlscert /run/keys/docker/server-cert.pem --tlskey /run/keys/docker/server-key.pem";

          # https://docs.docker.com/build/buildkit/
          #daemon.settings = { "features" = { "buildkit" = true; }; };

          # enableOnBoot = lib.mkDefault true;
          # enableNvidia = true;
          # extraOptions = "--default-runtime=nvidia";
          # rootless = {
          #   enable = false; # true;
          #   setSocketVariable = true;
          #   package = pkgs.docker;
          # };
          # autoPrune = {
          #   enable = true;
          #   dates = "monthly";
          # };
        };
      };
      users.users.${username}.extraGroups = [ "docker" ];
      environment.systemPackages = with pkgs; [
        docker-compose
        lazydocker
        # distrobox
        fuse-overlayfs # Container overlay+shiftfs
        flyctl
      ];
    };
}
