{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.podman;
  mkToml = (pkgs.formats.toml { }).generate;
  mkJson = (pkgs.formats.json { }).generate;
in
{
  options.services.podman.enable = mkEnableOption "Configure podman for rootless container use";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      buildah
      cosign
      podman
      podman-compose
      skopeo
    ];

    xdg.configFile = {
      "containers/containers.conf".source = mkToml "containers.conf" {
        containers = {
          default_sysctls = [
            "net.ipv4.conf.all.arp_filter=1"
            "net.ipv4.conf.all.rp_filter=1"
          ];

          init = true;
          init_path = lib.getExe pkgs.catatonit;
          ipcns = "private"; # Why is "sharable" the default???
          seccomp_profile = config.xdg.configFile."containers/seccomp.json".source.outPath;
          tz = "local";
          # userns = "private";
        };

        network.cni_plugin_dirs = [ "${pkgs.cni-plugins}/bin" ];
      };

      "containers/storage.conf".source = mkToml "storage.conf" {
        storage = {
          driver = "overlay";
          options.mount_program = lib.getExe pkgs.fuse-overlayfs;
        };
      };

      "containers/seccomp.json".source = mkJson "seccomp.json" {
        defaultAction = "SCMP_ACT_ALLOW";

        architectures = [
          "SCMP_ARCH_X86_64"
          "SCMP_ARCH_X86"
        ];

        syscalls = [ ];
      };

      "containers/registries.conf".source = mkToml "registries.conf" {
        registries.search.registries = [ "docker.io" ];
      };

      "containers/policy.json".source = mkJson "policy.json" {
        default = [{
          # type = "reject";
          type = "insecureAcceptAnything";
        }];

        transports = {
          dir."" = [{ type = "insecureAcceptAnything"; }];
          oci."" = [{ type = "insecureAcceptAnything"; }];
          tarball."" = [{ type = "insecureAcceptAnything"; }];
          docker-daemon."" = [{ type = "insecureAcceptAnything"; }];
          docker-archive."" = [{ type = "insecureAcceptAnything"; }];
          oci-archive."" = [{ type = "insecureAcceptAnything"; }];

          docker = {
            "" = [{
              # type = "reject";
              type = "insecureAcceptAnything";
            }];
            "docker.io/library" = [{ type = "insecureAcceptAnything"; }];
            "docker.io/nixos" = [{ type = "insecureAcceptAnything"; }];
            "docker.io/fireflyiii" = [{ type = "insecureAcceptAnything"; }];
          };
        };
      };
    };
  };
}
