# lib/ — helpers e nixGL

```
lib/
├── default.nix        reexporta helpers.nix
├── helpers.nix        mkHome, mkNixos, mkIso, mkHosts, mkChecks, forAllSystems
├── import-dir.nix     auto-descoberta e importação declarativa de diretórios de módulos
├── nixpkgs-config.nix configuração canônica unificada de nixpkgs
├── options.nix        helpers de criação de opções (mkOpt, mkBool, mkStr, etc.)
├── disk/
│   └── btrfs.nix      gerador declarativo de layout de disco Disko + Btrfs
└── nixgl/
    ├── default.nix    construtor do wrapper (Nix)
    └── wrapper.sh     lógica de seleção de GPU (shell real, com shellcheck)
```

## helpers.nix e nixpkgs-config.nix

- `nixpkgs-config.nix`: único ponto canônico definindo `allowUnfree = true;` e `nvidia.acceptLicense = true;`. Sem `allowInsecure = true;` ou `allowBroken = true;` globais; pacotes inseguros são permitidos exclusivamente via `permittedInsecurePackages` no host que deles necessita (ex.: `rocinante`).

- `mkCommonArgs`: único lugar que define os `specialArgs` (antes repetidos 5 vezes).
- `mkPkgs`: `pkgs` do HM standalone (overlays nixgl, nur e `outputs.overlays`; `nixpkgs.*` do módulo HM não vale nesse caso).
- `pinNixGLDefault`: com `nixGLType` explícito, fixa `nixgl.auto.nixGLDefault` em Intel/Mesa. Ainda é necessário porque `desktop/environments/default.nix` usa `pkgs.nixgl.auto.nixGLDefault`. Se esse uso for trocado por um script `nixGL` próprio, o overlay pode ser removido.
- `mkHosts`: constrói todas as `homeConfigurations`, `nixosConfigurations` e imagens `iso-*` a partir de `hosts.nix`.
- `mkChecks`: avalia cada `homeConfiguration` standalone e gera derivações herméticas para `checks.fmt` (`nixfmt --check`) e `checks.shellcheck` (todos os scripts `.sh` do repo).

## hosts.nix e profiles/

- `hosts.nix`: Fonte única da verdade contendo especificações declarativas de cada máquina (`kind`, `desktop`, `platform`, `vm`, `nixGLType`).
- `profiles/home/`: Perfis compartilhados de usuário (`workstation`, `minimal`, `vm`).
- `profiles/nixos/`: Perfis compartilhados de sistema operacional (`desktop`, `server`, `vm`).

## disk/btrfs.nix (`lib.my.disk.btrfs`)

Função parametrizada para particionamento Disko e montagens de `fileSystems`:
- Suporta tabelas de partição `gpt` (UEFI) e `msdos` (Legacy BIOS / CSM).
- Subvolumes Btrfs padronizados (`@`, `@home`, `@snapshots`, `@nix`, `@var_log`) com compressão configurável (`zstd`).
- Suporte a swap dedicado e criptografia de disco com LUKS.

## Motor de Tema (`lib.my.theme` e `desktop.theme.lib`)

Exporta a biblioteca de manipulação de cores definida em `modules/home-manager/desktop/theme/lib.nix`:
- `stripHash`, `hexToTuple`, `hexTo0x`, `rgb`, `rgba`, `cssRgb`, `cssRgba`.
- `withAlpha hex alpha`: interpola opacidade alfa em valores hexadecimais.
- `generateTmTheme { name, colors }`: gera dinamicamente esquemas de sintaxe TextMate (`.tmTheme`) para ferramentas como `bat` sem IFD e sem dependência de temas externos.

## options.nix (`lib.my` / `myLib`)

Centraliza a criação de opções concisas com descrição obrigatória para reduzir boilerplate em todos os módulos NixOS e Home Manager:
- `mkOpt type default description`: opção genérica com tipo, padrão e doc obrigatória.
- `mkBool default description`: opção booleana.
- `mkStr default description`: opção do tipo string.
- `mkInt default description`: opção inteira.
- `mkPath default description`: opção do tipo caminho (path).
- `mkEnum values default description`: opção enumerada.
- `mkPkg default description`: opção do tipo pacote.
- `mkListOf elemType default description`: lista de elementos do tipo especificado.
- `mkReadOnly type default description`: opção somente-leitura.

Disponível automaticamente em todos os módulos via `lib.my.*` ou pelo argumento `myLib.*`.

## import-dir.nix (`lib.my.importDir` / `lib.my.importSubdirs`)

Implementa auto-descoberta e importação declarativa de módulos em diretórios agregadores, eliminando listas manuais de `imports`:
- `lib.my.importDir ./.`: importa todos os módulos válidos do diretório (subpastas com `default.nix` e arquivos `.nix` regulares).
- `lib.my.importSubdirs ./.`: importa apenas subpastas diretas que contenham `default.nix`.

### Convenção:
- Arquivos ou subpastas cujo nome começa com `_` (ex: `_template/`, `_common.nix`) são ignorados.
- Pastas chamadas `disabled/` ou arquivos chamados `disabled` são ignorados (permite desligar módulos facilmente).
- O próprio arquivo `default.nix` do diretório é ignorado para evitar inclusão recursiva.
- Adicionar um novo módulo no repositório resume-se a criar a pasta com seu `default.nix`, sem necessidade de editar listas agregadoras.

## nixGL (`nixgl/`)

`nixGLType`:

| Valor | Comportamento |
|---|---|
| `"intel"` | sempre `nixGLIntel` (Optimus com a Intel no display, ex.: `nitro`) |
| `"mesa"` | sempre `nixGLMesa` |
| `null`, `"auto"`, `"nvidia"` | wrapper "smart": detecta a GPU em runtime |

O wrapper "smart" prioriza NVIDIA (driver do host via symlinks, sem `nixGLNvidia`), depois Intel, AMD e Mesa. Overrides: `FORCE_NVIDIA`, `FORCE_INTEL`, `FORCE_AMD`, `FORCE_MESA` (valor `1`) e `__NV_PRIME_RENDER_OFFLOAD=0`.

Para mudar a lógica, edite `wrapper.sh` e rode `shellcheck lib/nixgl/wrapper.sh`. Os placeholders entre arrobas (`intelRunner`, `mesaRunner`, `nvidiaVaapiDir`) são substituídos por `pkgs.replaceVars`, que falha o build se algum faltar.

Mudanças de comportamento em relação à versão anterior:
- `FORCE_NVIDIA=1` agora funciona (estava documentado, mas era ignorado).
- `wrapDesktopFiles` foi removido (só aparecia em código comentado).

## Convenção de uso nos módulos Home Manager

Todo módulo com programas gráficos acelerados por hardware (OpenGL, Vulkan, EGL, VAAPI, Electron) deve receber `nixGLWrapper ? lib.id` e envolver o pacote:

```nix
{ config, lib, pkgs, nixGLWrapper ? lib.id, ... }:

# Para opções do tipo package:
programs.exemplo.package = nixGLWrapper pkgs.exemplo;

# Para listas em home.packages:
home.packages = [ (nixGLWrapper pkgs.exemplo) ];
```
No NixOS (`mkNixos`) e em HM com `useNixGL = false`, `nixGLWrapper` é automaticamente `lib.id` (no-op).
