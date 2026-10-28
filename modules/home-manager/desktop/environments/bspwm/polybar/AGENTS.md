# Polybar — guia do módulo

Barra de status modular para o ambiente BSPWM.

## Contexto

Submódulo de `desktop/environments/bspwm/polybar/`. Controlado por `desktop.bspwm.polybar.enable`.

## Decisões em vigor

- **Multi-Monitor**: Divisão estrita de papéis: `bar/primary` (hardware, telemetria e rede) e `bar/secondary` (controles, relógio e powermenu). Inicialização via `polybar-launch` com `flock` e debounce.
- **Estilos (`desktop.bspwm.polybar.style`)**:
  - `"modern"`: visual inspirado em Waybar/Catppuccin.
  - `"zproger"` / `"pills"`: cápsulas `#2b2f37`, números pastel de 1 a 10 (`pillModuleOverrides`), cores Zproger em `colors.nix`.
- **Bateria e Adaptador**: Opções declarativas `desktop.bspwm.polybar.battery` e `desktop.bspwm.polybar.adapter` (ex.: `BAT1` e `ACAD` no host `nitro`).
- **Áudio e Volume Boost (150%)**: Módulo customizado com `pactl subscribe` e suporte a boost de volume até 150% via `pamixer`. Cores de destaque (`colors.peach`) acima de 100%.
- **Bluetooth Dinâmico**: Script `bluetoothScript` que identifica tipos de dispositivos pareados (fones, teclado, mouse).
- **Stalonetray Integrado**: Ativado via `desktop.bspwm.polybar.tray.enable`, exclusivo na barra secundária (ou primária se single-monitor). `ignore_classes` filtra apps que já possuem módulos nativos (Wi-Fi, Bluetooth, Fcitx5, Solaar).
- **Encapsulamento Modular e Cores (`desktop.bspwm.polybar.encapsulation`)**:
  - Aceita string direta (`"pill"`, `"shapes"`, `"slant"`, `"powerline"`) ou submódulo granular por cápsula (`workspaces`, `stats`, `netspeed`, `date`, `tray`) com `{ style, color, accent }`.
  - Resolução de cores via `resolveColor`: aceita nomes da paleta semântica (`"accent"`, `"mint"`, `"coral"`, `"nord"`, `"pill"`, etc.) e código `#HEX` direto (tanto `"#RRGGBB"` quanto `"RRGGBB"` sem cerquilha).
  - Prioridade estrita: campo no submódulo da cápsula -> `encapsulation.colors.<nome>` -> cor padrão global da cápsula / tema.

## Como prosseguir

- Manter cores padronizadas via `config.desktop.theme.colors` ou paleta Zproger quando em estilo `pills`.
- Evitar duplicação de módulos informativos entre telas primária e secundária.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/environments/bspwm/polybar/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
