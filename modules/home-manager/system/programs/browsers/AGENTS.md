# Navegadores Web (`system.programs.browsers`) — guia do módulo

Configuração e empacotamento declarativo de navegadores web.

## Contexto

Localizado em `modules/home-manager/system/programs/browsers/`.
Abrange Firefox, LibreWolf, Floorp, Chrome/Chromium, Brave e Vivaldi.

## Decisões em vigor

- **Aceleração Gráfica em Standalone**: Todos os pacotes de navegadores gráficos utilizam `nixGLWrapper` para garantir acesso a OpenGL/Vulkan/VA-API em distros standalone (Debian/Fedora).
- **Firefox e Forks Multi-Versão**:
  - `configPath` dinâmico: Floorp utiliza `~/.floorp`, LibreWolf utiliza `~/.librewolf` e Firefox padrão utiliza `~/.mozilla/firefox`.
  - Native Messaging compartilhado: hook de ativação `setupFirefoxNativeMessagingHosts` cria links automáticos para compartilhar plugins de sistema (`ff2mpv-rust`, `bukubrow`, `fx-cast-bridge`).
  - Variáveis de ambiente: `MOZ_DISABLE_RDD_SANDBOX = "1"`, `MOZ_ENABLE_WAYLAND = "1"` (Wayland) e `MOZ_X11_EGL = "1"` (X11) para permitir aceleração via VA-API.
- **Optimus Standalone sem Modeset (`nitro`)**: Manter LibreWolf na Intel UHD 630 (`preferNvidia = false`) para evitar conflito com GLVND sem KMS modeset.
- **Hosts com Pouca Memória RAM (`anubis`)**: Manter `system.programs.browsers.psd.enable = false` em hosts com pouca RAM (ex.: 2 GB) para evitar estouro da partição tmpfs em `/run/user/1000`.
- **Hook Centralizado de VA-API**: `activation.checkVaapi` reside em `browsers/default.nix` para evitar duplicações entre módulos.

## Como prosseguir

- Ao adicionar extensões ou preferências, utilizar `shared.nix` para opções comuns a todos os forks do Firefox.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/programs/browsers/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
