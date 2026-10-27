# Podman Rootless — guia do módulo

Gerenciamento de containers rootless com Podman.

## Contexto

Localizado em `modules/home-manager/system/services/podman/`.
Ativado via `services.podman.enable = true`.

## Decisões em vigor

- **Compatibilidade com Docker**: `dockerCompat = true` provisiona wrappers `docker`, inicializa o socket do Podman no systemd de usuário e exporta `DOCKER_HOST`.
- **Binários OCI**: Helpers OCI são injetados via `helper_binaries_dir` no `containers.conf`.
- **Gotcha Standalone (Debian/Ubuntu)**: Requer que o pacote `uidmap` esteja instalado no host base para fornecer os binários setuid `newuidmap` e `newgidmap`.

## Como prosseguir

- Mantenha a configuração voltada a rootless, sem requisições de privilégios de superusuário no Home Manager.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/services/podman/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
