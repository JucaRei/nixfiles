# modules/home-manager/system/services/podman/options.nix
# Opções declarativas para o serviço Podman rootless e ferramentas de container.
{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
in
{
  options.system.services.podman = {
    enable = mkEnableOption "Podman rootless container engine with best practices and upstream Home Manager integration.";

    package = lib.my.mkPkg pkgs.podman "The Podman package to use.";

    dockerCompat = lib.my.mkBool true "Enable Docker compatibility (docker CLI wrapper, DOCKER_HOST variable and docker.sock symlink).";

    enableSocket = lib.my.mkBool true "Enable Podman API systemd user socket for Docker API compatibility (DevContainers, Compose, etc.).";

    cgroupManager = lib.my.mkEnum [
      "systemd"
      "cgroupfs"
    ] "systemd" "Cgroup manager to use for rootless containers.";

    runtime = lib.my.mkEnum [
      "crun"
      "runc"
    ] "crun" "OCI container runtime (crun is fast, lightweight, and modern).";

    network =
      lib.my.mkEnum
        [
          "pasta"
          "slirp4netns"
        ]
        "pasta"
        "Default rootless network mode (pasta is high-performance, slirp4netns is classic fallback).";

    registries = {
      search = lib.my.mkListOf lib.types.str [
        "docker.io"
        "quay.io"
        "ghcr.io"
        "registry.fedoraproject.org"
      ] "List of registries to search when image name is unqualified.";

      insecure = lib.my.mkListOf lib.types.str [ ] "List of insecure registries (HTTP or untrusted TLS).";

      block = lib.my.mkListOf lib.types.str [ ] "List of blocked registries.";

      shortNameMode =
        lib.my.mkEnum
          [
            "permissive"
            "enforcing"
            "disabled"
          ]
          "permissive"
          "Short-name resolution mode. 'permissive' avoids interactive prompt blocking in scripts.";
    };

    storage = {
      driver = lib.my.mkStr "overlay" "Storage driver to use.";

      runroot =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) null
          "Path to the storage runroot (tmpfs). Defaults to /run/user/<UID>/containers.";

      graphroot =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) null
          "Path to the storage graphroot. Defaults to ~/.local/share/containers/storage.";

      mountProgram =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs"
          "Mount program for rootless overlay (fuse-overlayfs ensures high compatibility).";
    };

    autoPrune = {
      enable = lib.my.mkBool false "Enable periodic systemd user timer to prune unused containers, images, and volumes.";

      schedule = lib.my.mkStr "weekly" "Systemd OnCalendar expression for auto-prune.";

      flags = lib.my.mkListOf lib.types.str [
        "--all"
        "--volumes"
        "--force"
        "--filter"
        "until=168h"
      ] "Flags passed to 'podman system prune'.";
    };

    autoUpdate = {
      enable = lib.my.mkBool false "Enable periodic systemd user timer to auto-update containers via upstream Home Manager services.podman.";

      schedule = lib.my.mkStr "daily" "Systemd OnCalendar expression for auto-update.";
    };

    containers =
      lib.my.mkOpt (lib.types.attrsOf lib.types.anything) { }
        "Declarative container definitions forwarded to upstream Home Manager 'services.podman.containers'.";

    networks =
      lib.my.mkOpt (lib.types.attrsOf lib.types.anything) { }
        "Declarative network definitions forwarded to upstream Home Manager 'services.podman.networks'.";

    volumes =
      lib.my.mkOpt (lib.types.attrsOf lib.types.anything) { }
        "Declarative volume definitions forwarded to upstream Home Manager 'services.podman.volumes'.";

    quadlets =
      lib.my.mkOpt (lib.types.attrsOf lib.types.lines) { }
        "Raw Quadlet definitions placed in ~/.config/containers/systemd/.";

    extraPackages = {
      compose = lib.my.mkBool true "Install podman-compose and docker-compose.";

      tui = lib.my.mkBool true "Install podman-tui (terminal UI for Podman).";

      lazydocker = lib.my.mkBool true "Install lazydocker (rich interactive TUI dashboard for containers).";

      inspection = lib.my.mkBool true "Install skopeo, buildah, and dive for image inspection, building, and layer analysis.";

      packages = lib.my.mkListOf lib.types.package [ ] "Additional container packages to install.";
    };

    aliases = {
      enable = lib.my.mkBool true "Enable convenient shell aliases for Podman and Docker.";
    };
  };
}

