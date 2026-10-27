# DWM-Titus + Quickshell — guia do ambiente

Ambiente gráfico X11 baseado no fork DWM de Chris Titus integrado com Quickshell.

## Contexto

Utilizado no host NixOS `rocinante` (MacBook Pro 4,1) e em VMs de teste (`virtualvm`).
Entrada do módulo: `default.nix`. Configurações e scripts: `dwm.nix`, `packages.nix`, `configs/`.

## Decisões em vigor

- **Wrapper de Sessão**: O wrapper em `$HOME/.local/bin/start-dwm` inicializa a sessão com perfis do Nix e drivers gráficos nativos.
- **Arquivos Graváveis**: Configurações em `~/.config/dwm-titus/` são provisionadas como cópias reais (não symlinks somente leitura do Nix store) via `activation.setupDwmConfig`.
- **Scripts de Integração**: Scripts `dwm-settings-*` suportam links do store e fallback atômico POSIX.
- **Dunst Condicional**: Ativado apenas quando `bar != "quickshell"` para evitar conflito de barramento D-Bus de notificações.
- **NVIDIA 340 Legacy no Quickshell**: Forçado backend em software (`QT_QUICK_BACKEND=software`, `QT_XCB_GL_INTEGRATION=none`) devido a limitações do driver legado da NVIDIA.
- **Regras de Janelas**: No `window-rules.toml`, o atributo correto para janelas flutuantes é `isfloating` (e não `float`).

## Como prosseguir

- Ao modificar scripts em `configs/scripts/`, certifique-se de manter compatibilidade POSIX.
- Não introduzir dependências que exijam aceleração 3D pesada no backend do Quickshell para hosts com GPU legada.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/environments/dwm/default.nix
nix build .#nixosConfigurations.rocinante.config.system.build.toplevel --dry-run
```
