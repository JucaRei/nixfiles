# Métricas do Repositório (nixfiles)

Este documento acompanha a evolução das métricas de enxugamento e qualidade do repositório `nixfiles` ao longo das fases de refatoração.

## Metas do Projeto

- **Linhas `.nix`**: $\le 29.000$ (de 33.960 iniciais)
- **Tamanho por módulo**: nenhum módulo $> 400$ linhas (salvo dados)
- **Stubs e duplicatas**: 0 stubs e 0 duplicatas
- **Linters**: `statix` e `deadnix` sem avisos (0)
- **Tamanho dos hosts**: NixOS $\le 120$ linhas e Home Manager $\le 100$ linhas
- **`mkForce`**: $\le 15$ (com justificativa comentada)
- **Extensibilidade**: adicionar módulo, host ou paleta criando 1 arquivo, sem editar listas manuais de imports

---

## Tabela de Acompanhamento por Fase

| Métrica | Baseline (Medido) | Fase 0 | Fase 1 | Fase 2 | Fase 3 | Fase 4 | Fase 5 | Fase 6 | Fase 7 | Fase 8 | Fase 9 | Meta Final |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Arquivos `.nix`** | 281 | 281 | 276 | — | — | — | — | — | — | — | — | — |
| **Linhas `.nix`** | 33.960 | 33.960 | 33.835 | — | — | — | — | — | — | — | — | $\le 29.000$ |
| **`mkOption`** | 439 (117 simples) | 439 | 427 | — | — | — | — | — | — | — | — | Helpers `lib.my` |
| **`mkForce`** | 100 | 100 | 99 | — | — | — | — | — | — | — | — | $\le 15$ |
| **`with pkgs;`** | 71 | 71 | 70 | — | — | — | — | — | — | — | — | 0 |
| **`rec {`** | 38 | 38 | 36 | — | — | — | — | — | — | — | — | 0 |
| **Stubs `"{ }"`** | 7 | 7 | 3* | — | — | — | — | — | — | — | — | 0 |
| **Avisos `statix`** | 76 | 76 | 0 | — | — | — | — | — | — | — | — | 0 |
| **Avisos `deadnix`**| 30 | 30 | 0 | — | — | — | — | — | — | — | — | 0 |

---

## Notas de Evolução

### Fase 1 — Remover o que é morto
- **Stubs `"{ }"` (3*)**: os stubs de hosts legados em `nixos/hosts/` (`soyoz`, `virtual`, `zion`, `nixtro`) foram preservados a pedido do usuário para testes e simulações em VM/máquina real. Os stubs de módulos mortos (`gnome`, `sublime`, `zitext`) foram removidos.
- **Deadnix / Statix**: Zerados (0 avisos em ambos linters).
- **Opções não lidas**: 9 opções declaradas sem consumo e o módulo órfão `catppuccin-delta-fix.nix` foram removidos.

## Detalhes do Baseline Inicial

- **Branch**: `tests2`
- **Snapshot inicial**: `.snapshots/base/` gerado por `scripts/snapshot.sh base` (cobrindo todos os hosts NixOS e Home Manager standalone).
- **Scripts criados**:
  - `scripts/snapshot.sh`: extrai snapshot JSON com packages, files, systemd, bootloader, filesystems e opções `desktop.*`/`system.*`.
  - `scripts/metrics.sh`: afere contagem de linhas, arquivos, opções e avisos de linters.

