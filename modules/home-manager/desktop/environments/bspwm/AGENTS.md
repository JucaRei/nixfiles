# BSPWM — guia do ambiente

Ambiente gráfico X11 baseado no gerenciador de janelas em tiling BSPWM.

## Contexto

Utilizado principalmente em hosts X11 standalone como `nitro` (Debian) e VMs.
Entrada do módulo: `default.nix`. Configuração do WM: `bspwm.nix`. Atalhos: `sxhkd.nix`. Barra: `polybar/`.

## Decisões em vigor

- **Auto-Raise**: Daemon `bspwm-auto-raise` via systemd (`systemd.user.services.bspwm-auto-raise`) escuta `node_focus` do `bspc subscribe`. Janelas flutuantes inativas são enviadas para `below` e a focada vai para `above`. Atalhos no SXHKD: `Super + =` (above) e `Super + _` (normal).
- **Scratchpad**: Script nativo monitor-aware `bspwm-scratchpad` com `bspc` e `xdo` (substituiu o `tdrop`).
- **Screenshots**: Script nativo multi-monitor `bspwm-screenshot` com `maim` e `slop`.
- **Layouts**: Motor nativo reescrito em `pkgs/desktop/bspwm/bsp-layout/bsp-layout.sh`.
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
