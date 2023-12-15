{ config, lib, pkgs, hostname, desktop, ... }:

{
  #https://nixos.wiki/wiki/Podman


  environment.systemPackages = with pkgs; [
    buildah # Container build tool
    unstable.distrobox
    # podman-tui
    podman-compose
    aardvark-dns
    fuse-overlayfs # Container overlay+shiftfs
    #dive             # Container analyzer
    #grype            # Container vulnerability scanner
    #conmon           # Container monitoring
    #skopeo           # Container registry utility
    #syft             # Container SBOM generator
  ] ++ lib.optionals (desktop != null) [
    distrobox
    # unstable.pods
    xorg.xhost
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
          dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
        };
      };
      dockerSocket.enable = true;
      extraPackages = with pkgs; [
        #zfs ## Using podman with ZFS
        conmon
        runc
        skopeo
      ];
      dockerCompat = true;
      enable = true;
      # enableNvidia = lib.elem (
      #   if builtins.isString hostname != "air"
      #   then "nvidia" config.services.xserver.videoDrivers
      #   else false
      # );
      # enableNvidia = true;
      # autoPrune = {
      #   enable = true;
      #   dates = "04:30:00";
      #   flags = [ "--all" "--filter" "until=${builtins.toString (7*24)}h" ];
      # };
    };
    containers = {
      registries.search = [
        "docker.io"
        # "registry.fedoraproject.org"
        "quay.io"
        # "registry.access.redhat.com"
        # "registry.centos.org"
      ];

      # https://nixos.wiki/wiki/Podman
      # containersConf.settings = {
      #   engine.helper_binaries_dir = [ "${pkgs.netavark}/bin" ];
      # };

      containersConf.settings = {
        containers = {
          dns_servers = [ "8.8.8.8" "8.8.4.4" ];
          userns = "auto"; # Create unique User Namespace for the container
        };
      };
      storage.settings = {
        # defaults
        storage = {
          driver = "overlay";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";

          # SUB_UID_MAX: https://man7.org/linux/man-pages/man5/login.defs.5.html
          options.auto-userns-max-size = 600100000;
        };
      };

      ## for ZFS
      # storage = {
      # settings = {
      # driver = "zfs";
      # graphroot = "/var/lib/containers/storage";
      # runroot = "/run/containers/storage";
      # options.zfs.fsname = "zroot/podman";
      # };
      # };
    };
  };
  systemd = {
    services.podman-auto-update.enable = true;
    timers.podman-auto-update.enable = true;
  };

  users = {
    users."containers" = {
      isSystemUser = true;
      group = "containers";
      subUidRanges = [{
        startUid = 60100000;
        count = 60000000;
      }];
      subGidRanges = [{
        startGid = 60100000;
        count = 60000000;
      }];
    };
    groups.containers = { };
  };
}
