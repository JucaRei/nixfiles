# Polybar — guia do módulo

Barra de status modular para o ambiente BSPWM.

## Contexto

Submódulo de `desktop/environments/bspwm/polybar/`. Controlado por `desktop.bspwm.polybar.enable`.
As declarações de opções residem em `polybar/options.nix`, e a definição de módulos é particionada por domínio sob `polybar/modules/`.

## Decisões em vigor

- **Multi-Monitor**: Divisão estrita de papéis: `bar/primary` (hardware, telemetria e rede) e `bar/secondary` (controles, relógio e powermenu). Inicialização via `polybar-launch` com `flock` e debounce.
- **Estilos (`desktop.bspwm.polybar.style`)**:
  - `"modern"`: visual inspirado em Waybar/Catppuccin coeso.
  - `"zproger"` / `"pills"`: cápsulas `#2b2f37`, números pastel de 1 a 10 (`pillModuleOverrides`), cores Zproger em `colors.nix`.
  - `"shapes"`: blocos angulares de pixel/malha (`` e ``) estilo debian-bspwm-e300.
- **Bateria e Adaptador**: Opções declarativas `desktop.bspwm.polybar.battery` e `desktop.bspwm.polybar.adapter` (ex.: `BAT1` e `ACAD` no host `nitro`).
- **Áudio e Volume Boost (150%)**: Módulo customizado com `pactl subscribe` e suporte a boost de volume até 150% via `pamixer`. Cores de destaque (`colors.peach`) acima de 100%.
- **Bluetooth Dinâmico**: Script `bluetoothScript` que identifica tipos de dispositivos pareados (fones, teclado, mouse).
- **Stalonetray Integrado**: Ativado via `desktop.bspwm.polybar.tray.enable`, exclusivo na barra secundária (ou primária se single-monitor). `ignore_classes` filtra apps que já possuem módulos nativos (Wi-Fi, Bluetooth, Fcitx5, Solaar).

## Encapsulamento e Customização de Cores (`desktop.bspwm.polybar.encapsulation`)

O encapsulamento aceita tanto uma string direta (`"pill"`, `"shapes"`, `"slant"`, `"powerline"`) quanto uma configuração granular por cápsula:

```nix
desktop.bspwm.polybar.encapsulation = {
  default = "pill";
  accent = "#ff5555"; # Cor de destaque global padrão
  workspaces = {
    style = "powerline";
    accent = "#ff5555"; # Destaque do workspace ativo (paleta ou HEX)
  };
  stats = {
    style = "shapes";
    color = "#1e1e2e";
    accent = "mint";    # Ícones de hardware destacados em mint
  };
  netspeed = {
    style = "slant";
    color = "#29339B";  # Fundo customizado da cápsula de rede
    accent = "#8be9fd"; # Texto de velocidade em destaque ciano
  };
  date = {
    style = "pill";
    accent = "coral";   # Relógio e calendário em destaque coral
  };
  colors = {
    focusedNumber = "dark"; # Cor suave do número quando focado
  };
};
```

### Chaves de cores suportadas em `encapsulation.colors`:
- `glyph`: cor padrão dos glifos e fundos (ex: `"pill"`, `"red"`, `"shade1"`, `"#29339B"`)
- `accent`: cor de destaque padrão global (ex: `"red"`, `"accent"`, `"#ff5555"`)
- `workspaces`: cor de fundo e glifos da cápsula de workspaces
- `workspacesAccent` / `focused`: cor de destaque do workspace ativo
- `focusedNumber`: cor do número do workspace quando focado/ativo
- `stats`: cor de fundo e glifos da cápsula de métricas (cpu, memory, temp, disk)
- `statsAccent`: cor de destaque dos ícones de hardware (cpu, ram, temp, disk)
- `netspeed`: cor de fundo e glifos da cápsula de velocidade de rede
- `netspeedAccent`: cor de destaque do texto da velocidade de rede
- `date`: cor de fundo e glifos da cápsula de data/relógio
- `dateAccent`: cor de destaque dos ícones e textos da data/relógio
- `tray`: cor de fundo e glifos da cápsula da bandeja
- `trayAccent`: cor de destaque da bandeja

### Prioridade de resolução de cor:
1. Campo no submódulo da cápsula (`workspaces.color`, `stats.accent`, etc.)
2. `encapsulation.colors.<nome>` correspondente
3. Cor padrão global da cápsula ou tema semântico (`colors.pill`, `colors.accent`, etc.)

## Arquitetura de Módulos (`polybar/modules/`)

A definição dos blocos da Polybar está dividida por grupos funcionais:
- `modules/workspaces.nix`: gerência de workspaces BSPWM, títulos de janela ativa (`xwindow`), taskbar (`polywins`), janelas minimizadas e layout dinâmico (`bsp-layout`).
- `modules/media.nix`: tocador de mídia (`media`/`playerctl`), áudio (`pulseaudio`), brilho (`backlight`), bluetooth, filtro noturno (`redshift`) e central de notificações.
- `modules/system.nix`: métricas de hardware (`cpu`, `memory`, `temperature`, `disk`), tempo de atividade (`uptime`), bateria, indicador de teclado (`keyboard`), relógio (`date`), menu de energia (`powermenu`), botão da bandeja (`tray`) e configurações gerais.
- `modules/network.nix`: status de rede Wi-Fi/cabeada (`network`) e telemetria de tráfego (`netspeed`).
- `modules.nix`: agregador central que define geradores de glifos/encapsulamento e mescla os quatro domínios.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/environments/bspwm/polybar/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
