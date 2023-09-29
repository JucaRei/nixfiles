{ config, lib, pkgs, hostname, desktop, ... }: {
  #https://nixos.wiki/wiki/Podman

  environment.systemPackages = with pkgs; [
    buildah # Container build tool
    unstable.distrobox
    podman-tui
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
    unstable.pods
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
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      dockerSocket.enable = true;
      #extraPackages = [ pkgs.zfs ];  # Using podman with ZFS
      dockerCompat = true;
      enable = true;
      # enableNvidia = lib.elem (
      #   if builtins.isString hostname != "air"
      #   then "nvidia" config.services.xserver.videoDrivers
      #   else false
      # );
      # enableNvidia = true;
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
        containers.dns_servers = [ "8.8.8.8" "8.8.4.4" ];
      };
      ## for ZFS
      # storage = {
      #   settings = {
      #     driver = "zfs";
      #     graphroot = "/var/lib/containers/storage";
      #     runroot = "/run/containers/storage";
      #     options.zfs.fsname = "zroot/podman";
      #   };
      # };
    };
  };
  systemd = {
    services.podman-auto-update.enable = true;
    timers.podman-auto-update.enable = true;
  };
}
