# Podman configuration templates and helper scripts.
{
  cfg,
  pkgs,
  optionalString,
  concatMapStringsSep,
}:

let
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
    ${optionalString (
      cfg.storage.mountProgram != null
    ) ''mount_program = "${cfg.storage.mountProgram}"''}
    pull_options = { enable_partial_images = "true", use_hard_links = "false" }
  '';

  registriesConf = ''
    unqualified-search-registries = [
    ${concatMapStringsSep "\n" (r: ''"${r}",'') cfg.registries.search}
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
  inherit
    policyJson
    containersConf
    storageConf
    registriesConf
    dockerWrapper
    podmanDoctor
    ;
}
