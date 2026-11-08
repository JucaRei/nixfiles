# Registro de Risco Temporário (docs/PENDENTE-CHECK.md)

Este arquivo registra commits que alteram código de avaliação para rastreamento nos Checkpoints CP1, CP2 e Fase 6.
Será removido no fechamento final.

- `7ec5b5d`: `modules/home-manager/system/programs/shells/default.nix`, `pkgs/default.nix` — Adicionados binários `nix-capped` e aliases; risco mínimo de escopo de pacotes.
- `cb7bc78a`: `flake.nix`, `lib/helpers.nix`, `pkgs/tools/options-doc` — Unificação do nixfmt e gerador de docs; risco baixo de avaliação de formatter e checks.fmt.
- `fa75b8a1`: `lib/helpers.nix`, `lib/nixpkgs-config.nix`, `modules/home-manager/system/programs/multimedia/mpv/default.nix` — Remoção de allowBroken e nvidiaLegacyHosts/isNvidia; risco baixo em mpv (lê osConfig) e pacotes broken (verificar rocinante na fase 6).
- `13975dc9`: `modules/home-manager/system/programs/apps.nix`, `modules/nixos/system/programs/apps.nix` — Criação das opções declarativas `my.apps.cli` e `my.apps.gui`.
- `4ce3aef4`: `modules/home-manager/desktop/theme/palettes/*`, `profiles/home/workstation.nix` — Centralização de tema e acento por host; remoção de hex fixos.
- `90282fb9`: `home-manager/hosts/*`, `nixos/hosts/*`, `lib/helpers.nix` — Criação de `settings.nix` e `avancado.nix` em todos os hosts e check de CI.
- `c5eeca13`: `pkgs/tools/nx`, `scripts/nx`, `templates/host/*`, `shell.nix`, `modules/home-manager/system/programs/shells/default.nix` — Utilitário `nx` e templates para criação de novos hosts; risco mínimo.
- `025ed235`: `lib/options.nix`, `modules/**` — Adicionados cabeçalhos de documentação e exemplos nas opções principais; risco muito baixo (apenas metadados e helpers com fallback).
- `8d7e9229`: `home-manager/default.nix`, `nixos/default.nix`, `modules/home-manager/desktop/theme/default.nix`, `modules/**/apps.nix`, `scripts/nx` — Adicionadas assertivas em pt-BR com diagnóstico e sugestões; risco baixo de asserção indevida (testar CP2).
- `1ad61df9`: `modules/home-manager/**`, `lib/disk/btrfs.nix`, `nixos/hosts/**`, `pkgs/**` — Modularização de arquivos grandes (>400 linhas) em submódulos e redução de mkForce para 10 usos reais com justificativas; risco baixo de escopo de avaliação (verificar no CP2).
