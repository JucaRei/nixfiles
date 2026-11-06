#!/usr/bin/env bash
# scripts/podman-doctor.sh
# Script de diagnóstico e verificação de integridade do ambiente Podman rootless.

set -euo pipefail

echo "========================================"
echo "🩺 Diagnóstico do Ambiente Podman"
echo "========================================"

echo -n "1. Binário do Podman: "
if command -v podman >/dev/null 2>&1; then
  echo "OK ($(podman --version))"
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
echo "${DOCKER_HOST:-<não definida>}"

echo -n "5. Socket do Podman (%t/podman/podman.sock): "
SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
if [ -S "$SOCK" ]; then
  echo "Ativo e ouvindo em $SOCK"
else
  echo "Inativo no momento (inicia sob demanda via systemd: systemctl --user start podman.socket)"
fi

echo -n "6. Driver de Armazenamento: "
STORAGE_INFO=$(podman info --format '{{.Store.GraphDriverName}} (graphRoot: {{.Store.GraphRoot}})' 2>/dev/null || echo "erro ao obter info")
echo "$STORAGE_INFO"

echo -n "7. Teste de execução rootless (alpine): "
if podman run --rm alpine:latest echo "Podman funcionando com sucesso!" 2>/dev/null; then
  echo "✅ Sucesso!"
else
  echo "⚠️ Falha ao executar container de teste. Verifique logs com 'podman info'."
fi
echo "========================================"

