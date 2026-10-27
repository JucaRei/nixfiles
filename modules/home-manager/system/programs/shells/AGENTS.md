# Shells Interativos (`system.programs.shells`) — guia do módulo

Configuração dos shells do usuário (Bash, Zsh, Fish).

## Contexto

Localizado em `modules/home-manager/system/programs/shells/`.
Permite definir o shell interativo padrão via `system.programs.shells.default`.

## Decisões em vigor

- **Redirecionamento de Shell Padrão em Standalone**: Em distros standalone (Debian/Fedora), o arquivo `/etc/passwd` aponta para `/bin/bash`. Quando `cfg.default != "bash"`, o módulo `shells/bash/default.nix` injeta em `profileExtra` e `initExtra` uma verificação interativa que executa `exec "$targetShellPkg" -l`. Isso garante que sessões SSH e TTYs usem o shell configurado sem quebrar chamadas não-interativas (SCP, SFTP, rsync).
- **Aliases de Shell**: Nunca usar `"$@"` em aliases simples (o Fish rejeita essa sintaxe como inválida). Lógicas complexas devem ser empacotadas com `pkgs.writeShellScriptBin`.
- **Bash e ble.sh**: O `ble.sh` é pré-carregado com `--attach=none` (ordem 500) e anexado após o Starship (ordem 2000).
- **FZF**: Motor `fd`, preview com `bat` e `eza`, aliases de busca fuzzy (`fif`, `fkill`, `fpreview`).

## Como prosseguir

- Assegure-se de que novos aliases adicionados sejam compatíveis com a sintaxe tanto do Bash quanto do Fish.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/programs/shells/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
