{ config, lib, pkgs, modulesPath, inputs, username, ... }:
let
  inherit (lib) mkOption mkIf optionals mkForce;
  inherit (lib.types) bool;
  cfg = config.system.services.ct-podman;

  extraPackages = [ pkgs.shadow ];

  podman-unstable = pkgs.podman.override {
    extraPackages = extraPackages ++ [
      # setuid shadow ## fix for debian
      "/run/wrappers"
    ];
  };

  ### Use from podman from unstable
in
{
  disabledModules = [
    "${modulesPath}/services/podman-linux" # disable module from stable branch
  ];
  imports = [ (inputs.home-manager_unstable + "/modules/services/podman-linux") ];

  options = {
    system.services.ct-podman = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's podman rootless container's on home-manager.";
      };
    };
  };
  config = mkIf cfg.enable {

    services = {
      podman = {
        enable = true;
        package = podman-unstable;
        # autoUpdate = {
        # enable = true;
        # onCalendar = "*-*-* 00:00:00";
        # };
        # containers = { };
        settings = {
          registries = {
            block = [ ];
            insecure = [ "quay.io" "ghcr.io" ];
            search = [ "docker.io" ];
          };
        };
      };
    };

    home = {
      sessionVariables = {
        DOCKER_HOST = "unix://$(${pkgs.podman}/bin/podman system info -f json | ${pkgs.jq}/bin/jq -r .host.remoteSocket.path)";
      };

      shellAliases = mkForce {
        docker = "podman";
        docker-compose = "podman-compose";
      };

      packages = with pkgs; [
        # buildah
        # cosign
        # skopeo
        podman-compose
        fuse-overlayfs
      ]
        # ++ optionals (isWorkstation) [
        #   podman-desktop
        # ]
      ;

    };

    systemd.user.services."${username}@".serviceConfig = {
      # systemd.user.services."podman".serviceConfig = {
      Delegate = "cpu cpuset io memory pids";
    };
  };
}


# sudo chmod 4755 /usr/bin/newuidmap
# lib.getExe ${pkgs.shadow}/bin/newuidmap
# sudo chmod 4755 /usr/bin/newgidmap
# lib.getExe ${pkgs.shadow}/bin/newgidmap
# chown $USER -R '/var/tmp'
