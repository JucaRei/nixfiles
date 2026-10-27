# Gerenciador de Arquivos Agnóstico (`system.programs.file-manager`) — guia do módulo

Camada unificada para seleção e padronização do gerenciador de arquivos gráfico.

## Contexto

Localizado em `modules/home-manager/system/programs/file-manager/`.
Suporta `thunar`, `nautilus`, `nemo`, `pcmanfm` ou detecção automática (`auto`).

## Decisões em vigor

- **Interface Universal**:
  - `activeCommand`: comando padrão de execução.
  - `activeName`: nome de exibição.
  - `activeDesktopFile`: arquivo `.desktop` correspondente.
  - CLI utilitário `file-manager` disponível no PATH do usuário.
- **Thunar**:
  - Envolvido com módulos GVfs (`GIO_EXTRA_MODULES`) para suporte a shares de rede, lixeira e MTP.
  - Sem `pkgs.polkit` em `home.packages` em standalone (o Polkit exige helpers setuid do host).
  - Acesso de administrador via protocolo `admin://`.
- **Nautilus**: Wrappers GVfs, Sushi (preview), extensões e scripts contextuais.

## Como prosseguir

- Atalhos em WMs devem referenciar `config.system.programs.file-manager.activeCommand`.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/programs/file-manager/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
