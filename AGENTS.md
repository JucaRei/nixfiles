# AGENTS.md — nixfiles

Guia para agentes de IA (Claude, Gemini, Codex, etc.) neste repositório. Contém só regras **transversais**.
Detalhes de host ou de módulo ficam no README mais próximo do código (ver [Onde documentar](#onde-documentar)).

## Contexto

Configuração declarativa com **Nix Flakes** para **NixOS** e **Home Manager** (integrado e standalone).
Usuário padrão: `juca`. Idioma: comentários e docs em pt-BR; identificadores e options em inglês.

## Mapa do repositório

| Caminho | Conteúdo |
|---|---|
| `flake.nix` | Entrada: inputs, hosts, devShells, overlays, packages, checks |
| `lib/` | `helpers.nix` (`mkNixos`, `mkHome`, `mkIso`, `mkChecks`) e `nixgl/` |
| `nixos/` | Entrada do sistema (`default.nix`), `hosts/<host>/`, `users/` |
| `home-manager/` | Entrada do usuário (`default.nix`), `hosts/<host>/`, `users/` |
| `modules/nixos/` | Módulos NixOS reutilizáveis (desktop, hardware, system) |
| `modules/home-manager/` | Módulos HM reutilizáveis (`desktop/` incluindo `theme/`, `system/`) |
| `overlays/`, `pkgs/` | Overlays e pacotes próprios |

## Hosts

| Host | Tipo | Distro | Desktop | Saída do flake | Doc |
|---|---|---|---|---|---|
| `anubis` | HM standalone | Fedora | MangoWM + Noctalia | `homeConfigurations."juca@anubis"` | `home-manager/hosts/anubis/` |
| `nitro` | HM standalone | Debian | BSPWM (X11) | `homeConfigurations."juca@nitro"` | `home-manager/hosts/nitro/` |
| `fedora`, `anubisvm` | HM standalone | Fedora | BSPWM | `homeConfigurations."juca@<host>"` | — |
| `virtualvm` | HM standalone | VM | DWM | `homeConfigurations."juca@virtualvm"` | — |
| `rocinante` | NixOS | NixOS | DWM-Titus + Quickshell | `nixosConfigurations.rocinante` | `nixos/hosts/rocinante/` |
| `rocinante-vm`, `rocinante-hyperv` | NixOS (VM) | NixOS | BSPWM | `nixosConfigurations.<host>` | `nixos/hosts/<host>/` |
| `iso-*` | ISO live | NixOS | variável | `nixosConfigurations.iso-<desktop>` | — |

Diretórios em `nixos/hosts/` **sem** saída no flake (legado, não assumir que buildam): `nixtro`, `soyoz`, `virtual`, `zion`, `virtualvm`.

## Convenções Nix

1. **Sem unused bindings.** Declare em `{ lib, pkgs, ... }:` só o que o corpo usa. O `...` absorve o resto. Verificado por `deadnix`.
2. **Estilo:** formatar com `nix fmt` (nixfmt). Evitar `with pkgs;` em listas longas e `rec { }`; `statix check .` deve passar.
3. **Namespaces de options:** `desktop.*`, `system.programs.*`, `system.services.*`. Todo módulo novo expõe `enable` via `mkEnableOption`.
4. **Módulos não conhecem hosts.** Não usar `hostname == "..."` dentro de `modules/`. Criar uma option e defini-la em `hosts/<host>/default.nix`.
5. **Nixpkgs config e overlays** vêm de um único lugar. Não duplicar `allowInsecure`; preferir `permittedInsecurePackages`.
6. **Comentários e docs existentes** são preservados ao editar.
7. **Aceleração gráfica (nixGLWrapper):** Qualquer aplicação gráfica que utilize aceleração de hardware (OpenGL, Vulkan, EGL, VAAPI ou apps Electron como navegadores, terminais GPU, players multimídia, IDEs, Discord e WMs/shells) DEVE receber `nixGLWrapper ? lib.id` nos argumentos do módulo e envolver seus pacotes (`(nixGLWrapper pkgs.<app>)` ou `package = nixGLWrapper ...;`). No NixOS ou com nixGL desativado, `nixGLWrapper` é automaticamente `lib.id` (no-op).

## Validação (obrigatória antes de pedir o switch)

Escolha o mais barato que cobre a mudança:

```bash
nix-instantiate --parse <arquivo.nix>        # sintaxe
nix eval .#nixosConfigurations.<host>.config.system.stateVersion
nix eval .#homeConfigurations."juca@<host>".config.home.stateVersion
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run
nix build .#homeConfigurations."juca@<host>".activationPackage --dry-run
nix flake check --no-build                   # só no fechamento (ou 'nfc60' para limitar a 60% CPU/RAM)
```

Para configs geradas, validar também com a ferramenta do programa (ex.: `mango -c <arquivo> -p`).

Ao corrigir um erro de runtime ou de upgrade, **não tratar só o sintoma**: ler o changelog/wiki upstream da versão instalada, varrer o módulo inteiro por outros parâmetros legados e corrigir tudo de uma vez.

## Aplicação (executada pelo dono, não pelo agente)

```bash
home-manager switch --flake .#juca@<host>            # HM standalone
home-manager switch --flake .#juca@<host> -b backup  # primeiro switch
sudo nixos-rebuild switch --flake .#<host>           # NixOS
```

## Nunca fazer

- Rodar `switch`, `nixos-rebuild`, `sudo` ou comandos que alterem o sistema sem pedido explícito.
- Editar `flake.lock` à mão ou rodar `nix flake update` sem pedido.
- Ler, imprimir ou commitar conteúdo de `secrets/` ou chaves (`sops`, `~/.ssh`).
- Fazer `git commit`/`push` sem pedido.

## Gotchas críticos (os que quebram o sistema)

- **nixGL em Optimus:** definir `nixGLType = "intel"` no `mkHome` quando a Intel gerencia o display (ex.: `nitro`). `auto` só é seguro se o nixGL suportar a versão exata da NVIDIA no nixpkgs.
- **Aceleração gráfica no HM standalone:** Nunca declarar pacotes com aceleração gráfica puros sem `nixGLWrapper` em módulos do Home Manager. Em distros como Debian ou Fedora, a ausência do wrapper causa falhas de contexto GLX/EGL/Vulkan ou fallback lento em software rendering.
- **`nitro` (Debian):** nunca ativar `nvidia-drm.modeset=1`; quebra o GLX da Intel (`failed to find suitable GL configuration`).
- **`rocinante`:** NVIDIA 340 exige boot CSM/legacy (`bootType = "legacy"`); não usar `hardware.nvidia`, usar `boot.extraModulePackages` + `services.xserver.drivers`.
- **Polkit/setuid no HM:** não instalar `pkgs.polkit` em `home.packages`. Em standalone, helpers setuid vêm de `/run/wrappers/bin/` ou da distro.
- **SSH:** nunca colocar `+ssh-dss` no `~/.ssh/config` global (OpenSSH 9.8+ falha em toda a config). Legado fica só nos wrappers `ssh-legacy`/`scp-legacy` (via `pkgs.older`).
- **`programs.git`:** opções sob `programs.git.settings` (HM 24.11+).
- **`xorg.*`:** depreciado no nixpkgs 26.05; usar pacotes de primeiro nível (`libx11`, `xrandr`, `setxkbmap`).
- **NUR:** o overlay já é injetado; não importar `inputs.nur.modules.homeManager.default`.
- **XDG:** `xdg.mimeApps`, `xdg.systemDirs` e `targets.genericLinux.enable` ficam em `desktop/environments/default.nix`, não nos submódulos.
- **Overlays:** usar `inherit (final.stdenv.hostPlatform) system`, não `inherit (final) system`. Fontes em `pkgs/fonts/` exigem `dontBuild = true;`.
- **Aliases de shell:** não usar `"$@"` (Fish rejeita); comandos POSIX complexos viram `pkgs.writeShellScriptBin`.
- **Tiling managers no HM:** wrapper `~/.local/bin/start-<wm>`, sessão `.desktop` em `~/.local/share/{wayland,x}-sessions/`, teclado herdado de `home.keyboard`.
- **Sintaxe de WM:** MangoWM usa `snake_case` (`border_px`, `exec_once`, `window_rule`); Hyprland 0.55+ usa `windowrule` (não `windowrulev2`). Detalhes no README do ambiente.
- **Low-RAM hosts e PSD:** em hosts com pouca RAM (ex.: 2 GB no `anubis`), desativar `system.programs.browsers.psd.enable`; o `tmpfs` em `/run/user/1000` limitado a 10% da RAM (~180 MB) estoura rapidamente e causa falhas de `No space left on device (28)` e crashes em navegadores.

## Onde documentar

- Regra que vale para o repo inteiro → este arquivo (curta).
- Gotcha de um host → `home-manager/hosts/<host>/README.md` ou `nixos/hosts/<host>/README.md`.
- Gotcha de um módulo/ambiente → README em `modules/.../<ambiente>/` ou comentário no `.nix`.
- Comandos e guia de instalação → `WIKI.md`.

Não adicionar changelog de decisões aqui. Links sempre **relativos** (nunca `file:///` ou caminhos absolutos).