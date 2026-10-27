# Emulador de Terminal Agnóstico (`system.programs.terminal`) — guia do módulo

Camada unificada para seleção e padronização do emulador de terminal.

## Contexto

Localizado em `modules/home-manager/system/programs/terminal/`.
Permite alternar o terminal padrão em qualquer ambiente sem reescrever atalhos ou integrações.

## Decisões em vigor

- **Interface Universal**:
  - `activeCommand`: comando executável para abrir o terminal padrão.
  - `activeName`: nome amigável para menus e guias de atalhos.
  - `activeWorkingDirCommand`: comando base para abrir em diretório específico (usado por gerenciadores de arquivos).
  - `scratchpadCommand`: comando adaptado para janelas flutuantes/scratchpad.
  - CLI `terminal` e wrapper `~/.local/bin/term` exportando `TERMINAL = "terminal"`.
- **Terminais Suportados e Gotchas**:
  - **Alacritty**: Bell script hermético (`bell.command.program`) com fallbacks graciosos (`pulseaudio`, `canberra-gtk-play`, `pw-play`) para evitar alertas amarelos de erro.
  - **URxvt**: Paleta Gruvbox 256 (.Xresources), plugins Perl integrados (`tabbedex`, `clipboard`, `vtwheel`, `resize-font`), daemon `urxvtd` via systemd, e cadeia explícita de fontes Xft com `skipBuiltinGlyphs = false` e `URxvt.letterSpace = "-1"` para eliminar gaps de glifos.

## Como prosseguir

- Todos os gerenciadores de janelas e launchers devem invocar `config.system.programs.terminal.activeCommand` em vez de invocar binários diretamente.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/programs/terminal/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
