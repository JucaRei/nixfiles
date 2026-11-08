{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    escapeShellArgs
    mapAttrs'
    mkEnableOption
    mkIf
    mkMerge
    nameValuePair
    optionalAttrs
    optionalString
    optionals
    ;

  cfg = config.system.services.podman;

  configs = import ./_configs.nix {
    inherit
      cfg
      pkgs
      optionalString
      concatMapStringsSep
      ;
  };
  inherit (configs)
    policyJson
    containersConf
    storageConf
    registriesConf
    dockerWrapper
    podmanDoctor
    ;
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

  config = mkIf cfg.enable {
    # Upstream Home Manager native Podman integration (services.podman)
    services.podman = {
      enable = true;
      inherit (cfg)
        package
        containers
        networks
        volumes
        ;
      autoUpdate = mkIf cfg.autoUpdate.enable {
        onCalendar = cfg.autoUpdate.schedule;
      };
    };

    home = {
      # Packages
      packages = [
        podmanDoctor
        pkgs.crun
        pkgs.conmon
        pkgs.fuse-overlayfs
        pkgs.passt
        pkgs.slirp4netns
      ]
      ++ optionals cfg.dockerCompat [
        dockerWrapper
      ]
      ++ optionals cfg.extraPackages.compose [
        pkgs.podman-compose
        pkgs.docker-compose
      ]
      ++ optionals cfg.extraPackages.tui [
        pkgs.podman-tui
      ]
      ++ optionals cfg.extraPackages.lazydocker [
        pkgs.lazydocker
      ]
      ++ optionals cfg.extraPackages.inspection [
        pkgs.skopeo
        pkgs.buildah
        pkgs.dive
      ]
      ++ cfg.extraPackages.packages;

      # Environment variables for Docker CLI and API compatibility
      sessionVariables = mkIf cfg.dockerCompat {
        DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
      };

      # Activation hook to guarantee docker.sock symlink is active immediately
      activation.podmanDockerCompat = mkIf (cfg.enableSocket && cfg.dockerCompat) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ -n "''${XDG_RUNTIME_DIR:-}" ]; then
            mkdir -p "$XDG_RUNTIME_DIR/podman"
            ln -sfn "$XDG_RUNTIME_DIR/podman/podman.sock" "$XDG_RUNTIME_DIR/docker.sock" 2>/dev/null || true
          fi
        ''
      );

      # Shell aliases
      shellAliases = mkIf cfg.aliases.enable (
        {
          # Native Podman aliases
          p = "podman";
          p-ps = "podman ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'";
          p-psa = "podman ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'";
          p-img = "podman images";
          p-stop = "podman stop $(podman ps -q)";
          p-rm = "podman rm -f $(podman ps -aq)";
          p-rmi = "podman rmi -f $(podman images -q)";
          p-prune = "podman system prune -af --volumes";
          p-logs = "podman logs -f";
          p-exec = "podman exec -it";
          p-stats = "podman stats --no-stream";
          p-top = "podman top";
        }
        // optionalAttrs cfg.dockerCompat {
          # Docker compatibility aliases
          d = "podman";
          dps = "podman ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'";
          dpsa = "podman ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'";
          dimg = "podman images";
          dstop = "podman stop $(podman ps -q)";
          drm = "podman rm -f $(podman ps -aq)";
          drmi = "podman rmi -f $(podman images -q)";
          dprune = "podman system prune -af --volumes";
          dlogs = "podman logs -f";
          dexec = "podman exec -it";
          dstats = "podman stats --no-stream";
          dc = if cfg.extraPackages.compose then "podman-compose" else "podman compose";
        }
      );
    };

    # Configuration files in ~/.config/containers/
    xdg.configFile = mkMerge [
      {
        "containers/containers.conf".text = containersConf;
        "containers/storage.conf".text = storageConf;
        "containers/registries.conf".text = registriesConf;
        "containers/policy.json".text = policyJson;
      }
      (mapAttrs' (
        name: text:
        nameValuePair "containers/systemd/${name}" {
          inherit text;
        }
      ) cfg.quadlets)
    ];

    systemd.user = {
      # Systemd user session variables
      sessionVariables = mkIf cfg.dockerCompat {
        DOCKER_HOST = "unix://%t/podman/podman.sock";
      };

      # Systemd tmpfiles rule to ensure runtime directory and docker.sock symlink exist
      tmpfiles.rules = [
        "d %t/podman 0700 - - - -"
      ]
      ++ optionals cfg.dockerCompat [
        "L+ %t/docker.sock - - - - %t/podman/podman.sock"
      ];

      # Podman API Socket
      sockets.podman = mkIf cfg.enableSocket {
        Unit = {
          Description = "Podman API Socket";
          Documentation = "man:podman-system-service(1)";
        };
        Socket = {
          ListenStream = "%t/podman/podman.sock";
          SocketMode = "0660";
        };
        Install = {
          WantedBy = [ "sockets.target" ];
        };
      };

      # Podman API Service (socket activated)
      services.podman = mkIf cfg.enableSocket {
        Unit = {
          Description = "Podman API Service";
          Documentation = "man:podman-system-service(1)";
          Requires = [ "podman.socket" ];
          After = [ "podman.socket" ];
        };
        Service = {
          Type = "exec";
          KillMode = "process";
          ExecStart = "${cfg.package}/bin/podman system service";
        };
      };

      # Auto-prune periodic service & timer
      services.podman-prune = mkIf cfg.autoPrune.enable {
        Unit = {
          Description = "Podman periodic storage prune";
          Documentation = "man:podman-system-prune(1)";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${cfg.package}/bin/podman system prune ${escapeShellArgs cfg.autoPrune.flags}";
        };
      };

      timers.podman-prune = mkIf cfg.autoPrune.enable {
        Unit = {
          Description = "Periodic Podman storage prune timer";
        };
        Timer = {
          OnCalendar = cfg.autoPrune.schedule;
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
