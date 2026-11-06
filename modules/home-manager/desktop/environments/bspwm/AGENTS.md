# BSPWM — guia do ambiente

Ambiente gráfico X11 baseado no gerenciador de janelas em tiling BSPWM.

## Contexto

Utilizado principalmente em hosts X11 standalone como `nitro` (Debian) e VMs.

### Estrutura do módulo
- `default.nix`: Ponto de entrada (importação dinâmica via `lib.my.importDir`).
- `options.nix`: Declaração de opções raiz (`desktop.bspwm.*`).
- `bspwm.nix`: Integração do WM, settings, daemons systemd (`bspwm-auto-raise`, `bsp-layout`), activation e variáveis.
- `rules.nix`: Regras declarativas de janelas (`xsession.windowManager.bspwm.rules`).
- `_bspwmrc.nix`: Template do script de inicialização (`extraConfig`).
- `sxhkd.nix`: Módulo do daemon SXHKD, opções de atalhos e montagem final de keybindings.
- `_sxhkd-scripts.nix`: Wrappers herméticos dos scripts auxiliares (`writeShellApplication`).
- `_sxhkd-bindings.nix`: Atalhos particionados por grupos lógicos (apps, janelas, navegação, layouts, workspaces, mídia/brilho).
- `polybar/`: Barra de status Polybar modularizada.

## Decisões em vigor

- **Auto-Raise**: Daemon `bspwm-auto-raise` via systemd (`systemd.user.services.bspwm-auto-raise`) escuta `node_focus` do `bspc subscribe`. Janelas flutuantes inativas são enviadas para `below` e a focada vai para `above`. Atalhos no SXHKD: `Super + =` (above) e `Super + _` (normal).
- **Scratchpad**: Script nativo monitor-aware `bspwm-scratchpad` com `bspc` e `xdo` (substituiu o `tdrop`).
- **Screenshots**: Script nativo multi-monitor `bspwm-screenshot` com `maim` e `slop`.
- **Layouts**: Motor nativo em `pkgs/desktop/bspwm/bsp-layout/bsp-layout.sh` gerenciado pelo daemon `bsp-layout watch` (via systemd `bsp-layout.service` e hook de reload), garantindo persistência do layout por workspace e aplicação automática e reativa em novas janelas, fechamentos e movimentações entre desktops.
- **Lockscreen**: `betterlockscreen` + `i3lock-color` + `xss-lock` (`lock.nix`). Customizável via `~/.config/bspwm/lock.conf` ou declarativamente.
- **Recarga sem derrubar a sessão**: Hooks `home.activation.reload*` recarregam daemons (`sxhkd`, `polybar`, `dunst`, `picom`, `stalonetray`) sem reiniciar o processo do `bspwm`.
- **xsettingsd**: Gerenciado pelo serviço systemd do módulo `desktop.theme`.

## Como prosseguir

- Alterações em atalhos de teclado devem ser feitas em `sxhkd.nix`.
- Novos scripts de suporte devem preferencialmente residir em arquivos `.sh` herméticos.
- Respeitar a tecla modificadora universal `config.desktop.modifierKey`.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/environments/bspwm/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
