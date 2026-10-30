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
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Arquivos `.nix`** | 281 | 281 | 276 | 277 | 279 | 287 | — | — | — | — | — | — | — |
| **Linhas `.nix`** | 33.960 | 33.960 | 33.835 | 32.564 | 32.687 | 32.333 | — | — | — | — | — | — | $\le 29.000$ |
| **`mkOption`** | 439 (117 simples) | 439 | 427 | 13 | 13 | 13 | — | — | — | — | — | — | Helpers `lib.my` |
| **`mkForce`** | 100 | 100 | 99 | 99 | 99 | 46 | — | — | — | — | — | — | $\le 15$ |
| **`with pkgs;`** | 71 | 71 | 70 | 70 | 71 | 66 | — | — | — | — | — | — | 0 |
| **`rec {`** | 38 | 38 | 36 | 37 | 37 | 37 | — | — | — | — | — | — | 0 |
| **Stubs `"{ }"`** | 7 | 7 | 3* | 3* | 3* | 3* | — | — | — | — | — | — | 0 |
| **Avisos `statix`** | 76 | 76 | 0 | 0 | 0 | 0 | — | — | — | — | — | — | 0 |
| **Avisos `deadnix`**| 30 | 30 | 0 | 0 | 0 | 0 | — | — | — | — | — | — | 0 |

---

## Notas de Evolução

### Fase 4 — Perfis compartilhados e hosts enxutos
- **Perfis Compartilhados (`profiles/`)**: Criados perfis reutilizáveis em `profiles/home/{workstation,minimal,vm}.nix` e `profiles/nixos/{desktop,server,vm}.nix`, injetados automaticamente e incondicionalmente em `home-manager/default.nix` e `nixos/default.nix` via `isWorkstation` e `isVM`.
- **Declaração Unificada de Hosts (`hosts.nix`)**: Criado `hosts.nix` como fonte única da verdade para os 6 hosts Home Manager, 4 hosts NixOS e 7 imagens ISO. O `flake.nix` foi simplificado com `lib.mkHosts` em `lib/helpers.nix`, caindo de 171 para 97 linhas (-43%).
- **Redução Massiva de `mkForce`**: Eliminadas 53 ocorrências de `mkForce` ao resolver falsos conflitos na raiz dos módulos (`boot.initrd.systemd.enable`, `services.openssh.startWhenNeeded`, `services.fwupd.enable`, senhas de usuários em ISOs, overrides de temas e pacotes em `bat`, `pipewire` e `firefox` via DAG entries). O total caiu de 99 para 46 (as 46 restantes pertencem a `specialisation.nvidia`, partições de disco do Disko e live ISOs upstream).
- **Enxugamento Radical dos Hosts**:
  - `home-manager/hosts/virtual/default.nix`: 212 $\to$ 58 linhas (-72%, meta $\le 100$).
  - `home-manager/hosts/anubis/default.nix`: 162 $\to$ 89 linhas (-45%, meta $\le 100$).
  - `home-manager/hosts/nitro/default.nix`: 310 $\to$ 154 linhas (-50%).
  - `nixos/hosts/rocinante-vm/default.nix`: 219 $\to$ 118 linhas (-46%, meta $\le 120$).
  - `nixos/hosts/rocinante-hyperv/default.nix`: 313 $\to$ 137 linhas (-56%).
  - `nixos/hosts/rocinante/default.nix`: 468 $\to$ 184 linhas (-60%), modularizando o hardware específico em `hardware-macbook.nix`.
- **Linhas `.nix` Reduzidas**: 32.333 linhas no total (redução líquida de 354 linhas vs Fase 3 e -1.627 linhas vs baseline).
- **Qualidade e Linters**: `statix check .` e `deadnix .` zerados (0 avisos). `nix fmt` limpo em todo o repositório.
- **Validação de Ativação Real**: Build e ativação bem-sucedidos na VM Proxmox Debian `juca@virtual` (`10.10.10.233`), com inicialização completa de Polybar, Dunst, Stalonetray e tmpfiles sem nenhum erro.

### Fase 3 — Auto-import declarativo (lib/import-dir.nix)
- **Helper `lib.my.importDir` e `importSubdirs`**: Criado `lib/import-dir.nix` com suporte a exclusão de arquivos/diretórios iniciados por `_`, pasta `disabled` e `default.nix`.
- **Eliminação de listas estáticas de imports**: Todos os agregadores em `modules/home-manager/system/`, `modules/home-manager/desktop/`, `modules/nixos/` e raízes migrados para auto-descoberta. Novos módulos em qualquer subdiretório funcionam automaticamente sem editar `default.nix`.
- **Validação de runtime na VM `virtual`**: O switch e a ativação completa do Home Manager foram executados e validados na VM Proxmox (`10.10.10.233`), confirmando criação de diretórios de usuário, execução de hooks systemd, recarregamento de daemons e estabilidade sem regressões.
- **Invariância de configuração**: Snapshot `.snapshots/fase3` gerado e comparado contra fases anteriores: pacotes, serviços systemd, arquivos de usuário e unidades permanecem idênticos.
- **Desempenho de avaliação**: Tempo de eval de `rocinante` toplevel mantido excelente em ~2m31s.

### Fase 2 — Helpers de opções (lib/options.nix)
- **Helpers `lib.my.*`**: Criado `lib/options.nix` expondo `mkBool`, `mkStr`, `mkInt`, `mkPath`, `mkEnum`, `mkPkg`, `mkListOf`, `mkOpt` e `mkReadOnly` (com asserção estrita de descrição não-vazia).
- **Redução expressiva de boilerplate**: `mkOption` reduzido de 427 para apenas 13 em todo o repositório (os 13 restantes são atributos complexos com sub-opções dinâmicas ou opções especiais).
- **Linhas `.nix` reduzidas**: Redução líquida de 1.271 linhas em relação à Fase 1 (-1.396 linhas em relação ao Baseline), superando largamente a meta esperada da fase ($\ge 400$ linhas).
- **Qualidade mantida**: 0 avisos em `statix check .` e `deadnix .`.

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
