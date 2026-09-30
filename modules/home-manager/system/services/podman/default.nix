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
    mkOption
    nameValuePair
    optionalAttrs
    optionalString
    optionals
    types
    ;

  cfg = config.system.services.podman;

  policyJson = builtins.toJSON {
    default = [
      {
        type = "insecureAcceptAnything";
      }
    ];
    transports = {
      docker-daemon = {
        "" = [
          {
            type = "insecureAcceptAnything";
          }
        ];
      };
    };
  };

  containersConf = ''
    [containers]
    netns = "${cfg.network}"
    log_driver = "k8s-file"
    pids_limit = 2048
    default_capabilities = [
      "CHOWN",
      "DAC_OVERRIDE",
      "FOWNER",
      "FSETID",
      "KILL",
      "NET_BIND_SERVICE",
      "SETFCAP",
      "SETGID",
      "SETPUID",
      "SETPCAP",
      "SYS_CHROOT",
    ]
    default_sysctls = [
      "net.ipv4.ping_group_range=0 0",
    ]

    [engine]
    cgroup_manager = "${cfg.cgroupManager}"
    runtime = "${cfg.runtime}"
    events_logger = "journald"
    active_service = "local"
    image_default_format = "v2s2"
    compression_format = "zstd"
    env = [
      "BUILDAH_FORMAT=docker",
    ]
    helper_binaries_dir = [
      "${pkgs.passt}/bin",
      "${pkgs.slirp4netns}/bin",
      "${pkgs.conmon}/bin",
      "${pkgs.crun}/bin",
      "${pkgs.fuse-overlayfs}/bin",
      "/run/wrappers/bin",
      "/usr/libexec/podman",
      "/usr/lib/podman",
      "/usr/bin",
      "/bin",
      "/usr/sbin",
      "/sbin",
    ]
  '';

  storageConf = ''
    [storage]
    driver = "${cfg.storage.driver}"
    ${optionalString (cfg.storage.runroot != null) ''runroot = "${cfg.storage.runroot}"''}
    ${optionalString (cfg.storage.graphroot != null) ''graphroot = "${cfg.storage.graphroot}"''}

    [storage.options]
    ${optionalString (cfg.storage.mountProgram != null) ''mount_program = "${cfg.storage.mountProgram}"''}
    pull_options = { enable_partial_images = "true", use_hard_links = "false" }
  '';

  registriesConf = ''
    unqualified-search-registries = [
    ${concatMapStringsSep "\n" (r: ''  "${r}",'') cfg.registries.search}
    ]

    short-name-mode = "${cfg.registries.shortNameMode}"
    ${concatMapStringsSep "\n" (reg: ''
      [[registry]]
      location = "${reg}"
      insecure = true
    '') cfg.registries.insecure}
    ${concatMapStringsSep "\n" (reg: ''
      [[registry]]
      location = "${reg}"
      blocked = true
    '') cfg.registries.block}
  '';

  dockerWrapper = pkgs.writeShellScriptBin "docker" ''
    exec ${cfg.package}/bin/podman "$@"
  '';

  podmanDoctor = pkgs.writeShellScriptBin "podman-doctor" ''
    set -euo pipefail

    echo "========================================"
    echo "🩺 Diagnóstico do Ambiente Podman"
    echo "========================================"

    echo -n "1. Binário do Podman: "
    if command -v podman >/dev/null 2>&1; then
      echo "OK ($(${cfg.package}/bin/podman --version))"
    else
      echo "FALHA: podman não encontrado no PATH"
    fi

    echo -n "2. SubUID / SubGID do usuário: "
    USER_NAME="$(id -un)"
    if grep -q "^$USER_NAME:" /etc/subuid 2>/dev/null && grep -q "^$USER_NAME:" /etc/subgid 2>/dev/null; then
      echo "OK (subuid: $(grep "^$USER_NAME:" /etc/subuid | cut -d: -f2-3), subgid: $(grep "^$USER_NAME:" /etc/subgid | cut -d: -f2-3))"
    else
      echo "AVISO: /etc/subuid ou /etc/subgid não encontrados para '$USER_NAME'."
      echo "   -> No Fedora/Debian standalone execute: sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER_NAME"
    fi

    echo -n "3. Utilitários newuidmap / newgidmap (shadow setuid): "
    if command -v newuidmap >/dev/null 2>&1 && command -v newgidmap >/dev/null 2>&1; then
      echo "OK ($(command -v newuidmap))"
    elif [ -x "/usr/bin/newuidmap" ] || [ -x "/run/wrappers/bin/newuidmap" ]; then
      echo "OK (encontrado em caminho padrão)"
    else
      echo "FALHA: newuidmap ou newgidmap não encontrados!"
      echo "   -> No Debian/Ubuntu (ex: virtualvm): execute 'sudo apt install -y uidmap'"
      echo "   -> No Fedora/RHEL: execute 'sudo dnf install -y shadow-utils'"
      echo "   -> No NixOS: adicione 'programs.shadow.enable = true' ou 'virtualisation.podman.enable = true'"
    fi

    echo -n "4. Variável DOCKER_HOST: "
    echo "''${DOCKER_HOST:-<não definida>}"

    echo -n "5. Socket do Podman (%t/podman/podman.sock): "
    SOCK="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
    if [ -S "$SOCK" ]; then
      echo "Ativo e ouvindo em $SOCK"
    else
      echo "Inativo no momento (inicia sob demanda via systemd: systemctl --user start podman.socket)"
    fi

    echo -n "6. Driver de Armazenamento: "
    STORAGE_INFO=$(${cfg.package}/bin/podman info --format '{{.Store.GraphDriverName}} (graphRoot: {{.Store.GraphRoot}})' 2>/dev/null || echo "erro ao obter info")
    echo "$STORAGE_INFO"

    echo -n "7. Teste de execução rootless (alpine): "
    if ${cfg.package}/bin/podman run --rm alpine:latest echo "Podman funcionando com sucesso!" 2>/dev/null; then
      echo "✅ Sucesso!"
    else
      echo "⚠️ Falha ao executar container de teste. Verifique logs com 'podman info'."
    fi
    echo "========================================"
  '';
in
{
  options.system.services.podman = {
    enable = mkEnableOption "Podman rootless container engine with best practices and upstream Home Manager integration.";

    package = mkOption {
      type = types.package;
      default = pkgs.podman;
      description = "The Podman package to use.";
    };

    dockerCompat = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Docker compatibility (docker CLI wrapper, DOCKER_HOST variable and docker.sock symlink).";
    };

    enableSocket = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Podman API systemd user socket for Docker API compatibility (DevContainers, Compose, etc.).";
    };

    cgroupManager = mkOption {
      type = types.enum [
        "systemd"
        "cgroupfs"
      ];
      default = "systemd";
      description = "Cgroup manager to use for rootless containers.";
    };

    runtime = mkOption {
      type = types.enum [
        "crun"
        "runc"
      ];
      default = "crun";
      description = "OCI container runtime (crun is fast, lightweight, and modern).";
    };

    network = mkOption {
      type = types.enum [
        "pasta"
        "slirp4netns"
      ];
      default = "pasta";
      description = "Default rootless network mode (pasta is high-performance, slirp4netns is classic fallback).";
    };

    registries = {
      search = mkOption {
        type = types.listOf types.str;
        default = [
          "docker.io"
          "quay.io"
          "ghcr.io"
          "registry.fedoraproject.org"
        ];
        description = "List of registries to search when image name is unqualified.";
      };

      insecure = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of insecure registries (HTTP or untrusted TLS).";
      };

      block = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of blocked registries.";
      };

      shortNameMode = mkOption {
        type = types.enum [
          "permissive"
          "enforcing"
          "disabled"
        ];
        default = "permissive";
        description = "Short-name resolution mode. 'permissive' avoids interactive prompt blocking in scripts.";
      };
    };

    storage = {
      driver = mkOption {
        type = types.str;
        default = "overlay";
        description = "Storage driver to use.";
      };

      runroot = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the storage runroot (tmpfs). Defaults to /run/user/<UID>/containers.";
      };

      graphroot = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the storage graphroot. Defaults to ~/.local/share/containers/storage.";
      };

      mountProgram = mkOption {
        type = types.nullOr types.str;
        default = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
        description = "Mount program for rootless overlay (fuse-overlayfs ensures high compatibility).";
      };
    };

    autoPrune = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable periodic systemd user timer to prune unused containers, images, and volumes.";
      };

      schedule = mkOption {
        type = types.str;
        default = "weekly";
        description = "Systemd OnCalendar expression for auto-prune.";
      };

      flags = mkOption {
        type = types.listOf types.str;
        default = [
          "--all"
          "--volumes"
          "--force"
          "--filter"
          "until=168h"
        ];
        description = "Flags passed to 'podman system prune'.";
      };
    };

    autoUpdate = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable periodic systemd user timer to auto-update containers via upstream Home Manager services.podman.";
      };

      schedule = mkOption {
        type = types.str;
        default = "daily";
        description = "Systemd OnCalendar expression for auto-update.";
      };
    };

    containers = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Declarative container definitions forwarded to upstream Home Manager 'services.podman.containers'.";
    };

    networks = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Declarative network definitions forwarded to upstream Home Manager 'services.podman.networks'.";
    };

    volumes = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Declarative volume definitions forwarded to upstream Home Manager 'services.podman.volumes'.";
    };

    quadlets = mkOption {
      type = types.attrsOf types.lines;
      default = { };
      example = lib.literalExpression ''
        {
          "redis.container" = \'\'
            [Container]
            Image=docker.io/library/redis:alpine
            PublishPort=6379:6379

            [Install]
            WantedBy=default.target
          \'\';
        }
      '';
      description = "Raw Quadlet definitions placed in ~/.config/containers/systemd/.";
    };

    extraPackages = {
      compose = mkOption {
        type = types.bool;
        default = true;
        description = "Install podman-compose and docker-compose.";
      };

      tui = mkOption {
        type = types.bool;
        default = true;
        description = "Install podman-tui (terminal UI for Podman).";
      };

      lazydocker = mkOption {
        type = types.bool;
        default = true;
        description = "Install lazydocker (rich interactive TUI dashboard for containers).";
      };

      inspection = mkOption {
        type = types.bool;
        default = true;
        description = "Install skopeo, buildah, and dive for image inspection, building, and layer analysis.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Additional container packages to install.";
      };
    };

    aliases = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable convenient shell aliases for Podman and Docker.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Upstream Home Manager native Podman integration (services.podman)
    services.podman = {
      enable = true;
      package = cfg.package;
      autoUpdate = mkIf cfg.autoUpdate.enable {
        onCalendar = cfg.autoUpdate.schedule;
      };
      containers = cfg.containers;
      networks = cfg.networks;
      volumes = cfg.volumes;
    };

    # Packages
    home.packages =
      [
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

    # Environment variables for Docker CLI and API compatibility
    home.sessionVariables = mkMerge [
      (mkIf cfg.dockerCompat {
        DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
      })
    ];

    # Systemd user session variables
    systemd.user.sessionVariables = mkMerge [
      (mkIf cfg.dockerCompat {
        DOCKER_HOST = "unix://%t/podman/podman.sock";
      })
    ];

    # Systemd tmpfiles rule to ensure runtime directory and docker.sock symlink exist
    systemd.user.tmpfiles.rules = mkMerge [
      [
        "d %t/podman 0700 - - - -"
      ]
      (mkIf cfg.dockerCompat [
        "L+ %t/docker.sock - - - - %t/podman/podman.sock"
      ])
    ];

    # Activation hook to guarantee docker.sock symlink is active immediately
    home.activation.podmanDockerCompat = mkIf (cfg.enableSocket && cfg.dockerCompat) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -n "''${XDG_RUNTIME_DIR:-}" ]; then
          mkdir -p "$XDG_RUNTIME_DIR/podman"
          ln -sfn "$XDG_RUNTIME_DIR/podman/podman.sock" "$XDG_RUNTIME_DIR/docker.sock" 2>/dev/null || true
        fi
      ''
    );

    # Podman API Socket
    systemd.user.sockets.podman = mkIf cfg.enableSocket {
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
    systemd.user.services.podman = mkIf cfg.enableSocket {
      Unit = {
        Description = "Podman API Service";
        Documentation = "man:podman-system-service(1)";
        Requires = [ "podman.socket" ];
        After = [ "podman.socket" ];
      };
      Service = {
        Type = "exec";
        KillMode = "process";
        ExecStart = "${cfg.package}/bin/podman system service --time=0 unix://%t/podman/podman.sock";
      };
    };

    # Auto-prune periodic service & timer
    systemd.user.services.podman-prune = mkIf cfg.autoPrune.enable {
      Unit = {
        Description = "Podman periodic storage prune";
        Documentation = "man:podman-system-prune(1)";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/podman system prune ${escapeShellArgs cfg.autoPrune.flags}";
      };
    };

    systemd.user.timers.podman-prune = mkIf cfg.autoPrune.enable {
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

    # Shell aliases
    home.shellAliases = mkIf cfg.aliases.enable (
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
}
