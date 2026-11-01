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

---

## Notas de Evolução

### Fase 6 — Motor de tema customizável
- **Overrides e Custom Inline (`T6.1`)**: Adicionado `desktop.theme.overrides` (sobrescrita pontual de papéis) e `desktop.theme.custom` (declaração de paleta inline completa sem necessidade de arquivo físico). Adicionadas asserções estritas com validação de formato `#rrggbb` e presença dos 18 papéis obrigatórios, com tabela de fallback para mensagens de erro claras sem quebras prematuras.
- **Registro Único de Alvos e Exclusão (`T6.2`)**: Adicionado `desktop.theme.exclude` e o registro dinâmico `desktop.theme.targets.<alvo>` abrangendo todos os alvos conhecidos (`alacritty`, `bat`, `btop`, `dunst`, `eza`, `fastfetch`, `firefox`, `fzf`, `gedit`, `gtk`, `hyprland`, `kitty`, `mangowm`, `meld`, `mpv`, `noctalia`, `polybar`, `qt`, `rofi`, `starship`, `thunar`, `urxvt`, `vesktop`, `vscode`, `waybar`, `wlogout`, `wofi`, `xsettingsd`, `zathura`, `zsh`). Eliminadas checagens ad-hoc e opções dispersas nos módulos.
- **Biblioteca de Cores e Manipulação (`T6.3`)**: Criado `modules/home-manager/desktop/theme/lib.nix` expondo `rgb`, `rgba`, `cssRgb`, `cssRgba`, `hexTo0x`, `hexToTuple`, `stripHash`, `withAlpha` e `generateTmTheme`. Helpers expostos em `config.desktop.theme.lib` e `lib.my.theme`. Montagens manuais de string de cor em Hyprland e MangoWM substituídas pelos helpers.
- **Conexão Dinâmica de Alvos Restantes (`T6.4`)**:
  - `bspwm/lock.nix`: Cores migradas para derivar dinamicamente de `config.desktop.theme.colorsBare`.
  - `bat`: Mapeamento automático de temas para paletas conhecidas e geração dinâmica on-the-fly de `.tmTheme` via `generateTmTheme` para temas customizados ou com overrides. Com `nord` ou `dracula`, nada cai em Catppuccin.
  - `vscode`: Customizações dinâmicas de interface (`workbench.colorCustomizations`) injetadas via `desktop.theme.colors`, eliminando valores hardcoded em `settings.json`.
  - `zsh`: Sintaxe (`syntaxHighlighting.styles`) e autosugestão (`autosuggestion.highlight`) conectadas às cores do tema ativo.
  - `firefox`: Preferências de tema claro/escuro (`shared.nix`) condicionadas a `desktop.theme.variant`.
  - `fastfetch`: Cores de chaves, títulos e separadores (`display.color`) conectadas via TrueColor ANSI 24-bit (`themeLib.hexToTuple`).
- **Investigação e Descarte de Base16 via Derivação (`T6.5`)**: Confirmado que `pkgs.base16-schemes` é uma derivação (`stdenv.mkDerivation`) e que a leitura de seus arquivos YAML em tempo de avaliação requer IFD (Import From Derivation). Conforme especificado no roteiro, o recurso via derivação foi formalmente descartado para manter a hermeticidade pura e a velocidade de avaliação do flake.
- **Qualidade e Estabilidade Mantidas**: 0 avisos em `statix check .` e `deadnix .`, `nix fmt` limpo, dry-run 100% aprovado para `juca@nitro` e `nixosConfigurations.rocinante`.

### Fase 5 — Disk e filesystem declarativo (lib/disk/btrfs.nix)
- **Helper Parametrizado (`lib/disk/btrfs.nix`)**: Criada função geradora unificada de particionamento Disko e montagens de `fileSystems` Btrfs (`lib.my.disk.btrfs`), suportando tabelas `gpt` (UEFI) e `msdos` (CSM/Legacy), compressão Zstandard configurável, subvolumes Btrfs padronizados (`@`, `@home`, `@snapshots`, `@nix`, `@var_log`), swap parametrizável e suporte a LUKS.
- **Eliminação de 7 Arquivos Repetitivos**:
  - Removidos `nixos/hosts/rocinante/{disko.nix, disko-legacy.nix, filesystem.nix}`.
  - Removidos `nixos/hosts/rocinante-vm/{disko.nix, filesystem.nix}`.
  - Removidos `nixos/hosts/rocinante-hyperv/{disko.nix, filesystem.nix}`.
  - Redução líquida de 308 linhas e eliminação de 6 arquivos no repositório.
- **Redução Adicional de `mkForce`**: `mkForce` reduzido de 46 para 30 (-16 `mkForce` duplicados eliminados).
- **Invariância Absoluta**: Snapshot `fase5` gerado com comparação contra `fase4`: `fileSystems`, `swapDevices` e `boot.initrd.luks` permaneceram 100% idênticos em todos os hosts NixOS (`rocinante`, `rocinante-vm`, `rocinante-hyperv`).
- **Qualidade Mantida**: 0 avisos em `statix check .` e `deadnix .`. `nix fmt` limpo.

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
