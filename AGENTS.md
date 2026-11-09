# AGENTS.md — nixfiles

Guia para agentes de IA (Claude, Gemini, Codex, etc.) neste repositório. Contém só regras **transversais**.
Detalhes de host ou de módulo ficam no README mais próximo do código (ver [Onde documentar](#onde-documentar)).

## Contexto

Configuração declarativa com **Nix Flakes** para **NixOS** e **Home Manager** (integrado e standalone).
Usuário padrão: `juca`. Idioma: comentários e docs em pt-BR; identificadores e options em inglês.

## Navegação Rápida ("Quero mexer em... → vá para...")

| Quero... | Onde mexer | Documentação / Guia |
|---|---|---|
| Mudar tema, cor de destaque, wallpaper ou monitor de um host | `<home-manager\|nixos>/hosts/<host>/settings.nix` | [COMO-MEXER.md](docs/COMO-MEXER.md#receitas-do-teste-do-leigo) |
| Instalar ou remover programas (CLI / GUI) | `<home-manager\|nixos>/hosts/<host>/settings.nix` (`my.apps.*`) | [COMO-MEXER.md](docs/COMO-MEXER.md#3-instalar-um-programa-cli-ou-gui) |
| Criar uma nova máquina | `./scripts/nx new-host` | [COMO-MEXER.md](docs/COMO-MEXER.md#7-criar-uma-nova-máquina-host) |
| Registrar / alterar arquitetura, plataforma ou WM de hosts | `hosts.nix` | [hosts.nix](hosts.nix) |
| Modificar configurações avançadas de um host | `<home-manager\|nixos>/hosts/<host>/avancado.nix` | AGENTS.md local do host |
| Alterar perfis compartilhados de usuário ou sistema | `profiles/home/` ou `profiles/nixos/` | [profiles/](profiles/) |
| Adicionar novo módulo de usuário ou sistema | Criar pasta em `modules/<hm\|nixos>/.../` com `default.nix` (auto-import) | Regra 10 (Convenções Nix) |
| Consultar tipos e opções declarativas disponíveis | `docs/OPTIONS.md` | [OPTIONS.md](docs/OPTIONS.md) |
| Testar, aplicar ou fazer rollback de configurações | `./scripts/nx <check\|apply\|rollback>` | [COMO-MEXER.md](docs/COMO-MEXER.md#8-aplicar-as-alterações) |

## Mapa do repositório

| Caminho | Conteúdo |
|---|---|
| `flake.nix` | Entrada: inputs, hosts (`mkHosts`), devShells, overlays, packages, checks |
| `hosts.nix` | Registro declarativo canônico de todos os hosts (HM, NixOS, ISOs) |
| `profiles/` | Perfis compartilhados (`home/` e `nixos/`: workstation, minimal, vm) |
| `lib/` | `helpers.nix`, `options.nix` (`lib.my`), `import-dir.nix`, `disk/btrfs.nix` e `nixgl/` |
| `nixos/` | Entrada do sistema (`default.nix`), `hosts/<host>/`, `users/` |
| `home-manager/` | Entrada do usuário (`default.nix`), `hosts/<host>/`, `users/` |
| `modules/nixos/` | Módulos NixOS reutilizáveis (desktop, hardware, system) |
| `modules/home-manager/` | Módulos HM reutilizáveis (`desktop/` incluindo `theme/`, `system/`) |
| `overlays/`, `pkgs/` | Overlays e pacotes próprios |
| `docs/OPTIONS.md` | Catálogo declarativo gerado com todas as opções `desktop.*` e `system.*` |

## Hosts

| Host | Tipo | Distro | Desktop | Saída do flake | Doc |
|---|---|---|---|---|---|
| `anubis` | HM standalone | Fedora | MangoWM + Noctalia | `homeConfigurations."juca@anubis"` | [AGENTS.md](home-manager/hosts/anubis/AGENTS.md) |
| `nitro` | HM standalone | Debian | BSPWM (X11) | `homeConfigurations."juca@nitro"` | [AGENTS.md](home-manager/hosts/nitro/AGENTS.md) |
| `virtual` | HM standalone (VM) | Debian | BSPWM (X11) | `homeConfigurations."juca@virtual"` | [AGENTS.md](home-manager/hosts/virtual/AGENTS.md) |
| `fedora`, `anubisvm` | HM standalone | Fedora | BSPWM | `homeConfigurations."juca@<host>"` | — |
| `virtualvm` | HM standalone | VM | DWM | `homeConfigurations."juca@virtualvm"` | [AGENTS.md](home-manager/hosts/virtualvm/AGENTS.md) |
| `rocinante` | NixOS | NixOS | DWM-Titus + Quickshell | `nixosConfigurations.rocinante` | [AGENTS.md](nixos/hosts/rocinante/AGENTS.md) |
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
8. **Scripts de shell herméticos e `writeShellApplication`:** Scripts utilitários extraídos para subdiretórios `scripts/` devem ser herméticos e carregados via `writeShellApplication`. Para evitar quebras na construção da derivação por avisos cosméticos ou pelo preâmbulo gerado pelo Nixpkgs (como SC2012, SC2034, SC2086, SC2089, SC2090), configure `excludeShellChecks` no builder.
9. **Helpers de opções (`lib.my` / `myLib`):** Declarar opções através dos helpers `lib.my.mkBool`, `lib.my.mkStr`, `lib.my.mkInt`, `lib.my.mkEnum`, `lib.my.mkListOf`, `lib.my.mkOpt`, etc. A descrição é estritamente obrigatória em todas as opções.
10. **Auto-importação (`lib.my.importDir`):** Diretórios agregadores de módulos usam importação automática declarativa. Novos submódulos com `default.nix` são carregados automaticamente sem edição de listas manuais. Pastas/arquivos iniciados por `_` e o diretório `disabled/` são ignorados.
11. **Motor de tema semântico (`desktop.theme`):** Cores de interface e ferramentas devem derivar de `config.desktop.theme.colors` ou `.colorsBare`. Suporta paletas pré-definidas, `theme.overrides`, `theme.custom` e exclusões declarativas via `theme.exclude`. Manipulação de cores (alpha, tuplas RGB, hex) usa exclusivamente os helpers de `lib.my.theme.*` (`theme/lib.nix`).

## Validação (obrigatória antes de pedir o switch)

Escolha o mais barato que cobre a mudança:

```bash
nix-instantiate --parse <arquivo.nix>        # sintaxe
nix eval .#nixosConfigurations.<host>.config.system.stateVersion
nix eval .#homeConfigurations."juca@<host>".config.home.stateVersion
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run
nix build .#homeConfigurations."juca@<host>".activationPackage --dry-run
nix flake check --no-build                   # só no fechamento (ou 'nfc60' para limitar a 40% CPU e até metade da RAM)
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
- **Sintaxe de WM:** MangoWM usa `snake_case` (`border_px`, `exec_once`, `window_rule`); Hyprland 0.55+ usa `windowrule` (não `windowrulev2`). Detalhes no `AGENTS.md` do ambiente.
- **Low-RAM hosts e PSD:** em hosts com pouca RAM (ex.: 2 GB no `anubis`), desativar `system.programs.browsers.psd.enable`; o `tmpfs` em `/run/user/1000` limitado a 10% da RAM (~180 MB) estoura rapidamente e causa falhas de `No space left on device (28)` e crashes em navegadores.

## Onde documentar

- Regra que vale para o repo inteiro → este arquivo (curta).
- Gotcha de um host → `home-manager/hosts/<host>/AGENTS.md` ou `nixos/hosts/<host>/AGENTS.md`.
- Gotcha de um módulo/ambiente → `modules/.../<modulo>/AGENTS.md` ou comentário no `.nix`.
- Comandos e guia de instalação → `WIKI.md`.

Não adicionar changelog de decisões aqui. Links sempre **relativos** (nunca `file:///` ou caminhos absolutos).