# Wallpaper agnóstico (`desktop.wallpaper`) — guia do módulo

Gerencia e aplica papel de parede de forma universal em **qualquer desktop ou window manager** (BSPWM, DWM, Hyprland, MangoWM, XFCE4, GNOME, etc.), abstraindo ferramentas de X11 (`feh`) e Wayland (`swaybg`, `hyprpaper`, `swww`).

No modo aleatório (`--random` ou no login), **cada monitor conectado recebe automaticamente um wallpaper diferente**. Suporta também rotação periódica por timer (`interval = "15m"`).

## Uso no Host

No arquivo de configuração do host (ex: `home-manager/hosts/<host>/default.nix`):

```nix
desktop.wallpaper = {
  enable = true;
  directory = "${config.home.homeDirectory}/Pictures/Wallpapers"; # Pasta no host
  randomOnStart = true;    # true = sorteia da pasta no boot (wallpaper diferente por tela)
  interval = "15m";        # Rotação periódica (ex: "30s", "5m", "15m", "1h")
  mode = "fill";           # fill | center | tile | scale | max
  backend = "auto";        # auto | feh | swaybg | hyprpaper | swww | xfconf | gsettings
};
```

## Como funciona

1. **Script CLI `set-wallpaper` (e alias `wallpaper`):**
   Disponibilizado no `PATH` do usuário.
2. **Suporte Multi-Monitor:**
   No modo aleatório, detecta ativamente os monitores (via `xrandr` no X11 ou `wlr-randr`/`hyprctl` no Wayland) e aplica imagens distintas em cada tela.
3. **Timer de Rotação Automática:**
   Quando `interval` é configurado, ativa o timer do systemd (`wallpaper-rotate.timer`), com fallback automático para modo daemon (`set-wallpaper --timer <interval>`).
4. **Backends automáticos:**
   - **X11 (BSPWM, DWM, etc.):** Usa `feh --bg-<modo>` passando as imagens por tela.
   - **Wayland (MangoWM, Sway, etc.):** Usa `swaybg` (com `nixGLWrapper` em hosts standalone) com flag `-o <monitor> -i <imagem>`.
   - **Hyprland:** Usa `hyprpaper` ou `swaybg`.
   - **XFCE4:** Atualiza propriedades `xfconf` e aplica via `feh`.
   - **GNOME / Cinnamon:** Aplica via `gsettings`.
5. **Persistência de Estado:**
   O caminho dos wallpapers ativos é salvo em `~/.local/state/wallpaper/current`.

## Comandos do CLI

```bash
set-wallpaper                      # Restaura os últimos wallpapers ativos
set-wallpaper /caminho/imagem.png  # Aplica uma imagem específica em todas as telas
set-wallpaper /caminho/pasta       # Aplica wallpapers aleatórios da pasta informada
set-wallpaper -r, --random         # Sorteia imagens diferentes para cada monitor
set-wallpaper -n, --next           # Avança para os próximos wallpapers da pasta
set-wallpaper -p, --prev           # Retorna aos wallpapers anteriores da pasta
set-wallpaper -t, --timer 15m      # Executa em loop trocando a cada 15m
set-wallpaper -c, --current        # Imprime os caminhos das imagens ativas por monitor
set-wallpaper --restore            # Reaplica os wallpapers ativos (útil após reconectar monitores)
set-wallpaper -h, --help           # Exibe ajuda e opções disponíveis
```

Também é possível usar o comando curto `wallpaper` (ex: `wallpaper --random`).
