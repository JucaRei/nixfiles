# Noctalia Shell — guia do módulo

Shell nativo em C++ integrado para compositores Wayland (MangoWM / Hyprland).

## Contexto

Localizado em `modules/home-manager/desktop/display-servers/wayland/noctalia/`.
Ativado quando `waylandShell = "noctalia"` no host (ex.: `anubis`).

## Decisões em vigor

- **Configuração Declarativa**: Configuração gerada em TOML em `~/.config/noctalia/config.toml` via `desktop.wayland.noctalia.settings`.
- **Integração MangoWM**: Conecta via `ext-workspace-v1` e IPC de socket do MangoWM. O layout é exibido via widget customizado `mango_layout`.
- **Plugins**: A sintaxe de referência exige `<autor>/<plugin>:<entry>` (nunca `plugin:`).
- **Controle de OSD**: Volume e brilho utilizam mensagens nativas via IPC (`noctalia msg`), dispensando `notify-send`.
- **Módulo Idle**: Seção correta no TOML é `[idle.behavior.<nome>]` (não `bahavior`). Para Intel HD 3000, definir `pre_action_fade_seconds = 0.0` para evitar flickering visual.

## Como prosseguir

- As opções declarativas são serializadas via `(pkgs.formats.toml { }).type`.
- Ajustes de tema e cores devem refletir `config.desktop.theme.colors`.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/display-servers/wayland/noctalia/default.nix
nix build .#homeConfigurations."juca@anubis".activationPackage --dry-run
```
