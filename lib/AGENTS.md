# lib/ — helpers e nixGL

```
lib/
├── default.nix     reexporta helpers.nix
├── helpers.nix     mkHome, mkNixos, mkIso, mkChecks, forAllSystems
└── nixgl/
    ├── default.nix construtor do wrapper (Nix)
    └── wrapper.sh  lógica de seleção de GPU (shell real, com shellcheck)
```

## helpers.nix

- `mkCommonArgs`: único lugar que define os `specialArgs` (antes repetidos 5 vezes).
- `mkPkgs`: `pkgs` do HM standalone (overlays nixgl, nur e `outputs.overlays`; `nixpkgs.*` do módulo HM não vale nesse caso).
- `pinNixGLDefault`: com `nixGLType` explícito, fixa `nixgl.auto.nixGLDefault` em Intel/Mesa. Ainda é necessário porque `desktop/environments/default.nix` usa `pkgs.nixgl.auto.nixGLDefault`. Se esse uso for trocado por um script `nixGL` próprio, o overlay pode ser removido.
- `nvidiaLegacyHosts`: lista que gera `isNvidia` no HM integrado. Pendência: trocar por option de hardware via `osConfig`.
- `mkChecks`: só **avalia** cada `nixosConfiguration` e `homeConfiguration` em `nix flake check` (não builda).

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
