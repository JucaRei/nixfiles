# Tema agnóstico (`desktop.theme`) — guia do módulo

Aplica paleta, GTK, ícones, cursor e configurações de estilo em **qualquer host e desktop** (BSPWM, DWM, Hyprland, MangoWM, XFCE4). Centraliza as cores em um único ponto declarativo com papéis semânticos.

## Uso Básico

```nix
# home-manager/hosts/<host>/default.nix
desktop.theme = {
  enable = true;
  name = "dracula";   # catppuccin-mocha | catppuccin-macchiato | dracula | nord | gruvbox-dark | tokyo-night | kanagawa-wave
  accent = "purple";  # red orange yellow green teal cyan blue purple pink
};
```

Sem `enable`, nada é aplicado no sistema/GTK, mas as **cores continuam disponíveis** para os módulos (`colors` e `colorsBare` são sempre calculados).

## Customização e Overrides

### 1. Overrides Pontuais (`desktop.theme.overrides`)

Permite sobrescrever papéis semânticos específicos sem alterar a paleta base:

```nix
desktop.theme.overrides = {
  accent = "#ff007f";
  bg = "#0f0f17";
};
```

### 2. Tema Customizado Inline (`desktop.theme.custom`)

Permite declarar uma paleta inteira inline diretamente na configuração do host ou perfil, sem criar arquivo físico em `palettes/`:

```nix
desktop.theme.custom = {
  label = "CyberpunkCustom";
  variant = "dark"; # "dark" | "light"
  colors = {
    bg = "#101018"; bgAlt = "#181824"; bgDark = "#0a0a10";
    surface = "#222230"; surfaceAlt = "#2a2a3c"; border = "#3a3a4c";
    fg = "#e0e0f0"; fgMuted = "#9090a0"; fgSubtle = "#606070";
    red = "#ff4466"; orange = "#ff8844"; yellow = "#ffdd44";
    green = "#33ff99"; teal = "#33ddff"; cyan = "#22bbee";
    blue = "#4477ff"; purple = "#aa44ff"; pink = "#ff44aa";
    accent = "#ff44aa";
  };
  # Opcionais (herdam da paleta base se omitidos):
  gtk = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
  icons = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
  cursor = { name = "Bibata-Modern-Classic"; package = pkgs.bibata-cursors; size = 24; };
};
```

Todas as 18 cores semânticas são validadas estritamente via assertions (formato `#rrggbb` e presença obrigatória).

### 3. Exclusão de Alvos (`desktop.theme.exclude` e `desktop.theme.targets`)

Permite desativar a tematização automática para aplicativos específicos:

```nix
desktop.theme.exclude = [ "bat" "vscode" ];
```

Os módulos downstream consultam centralizadamente `config.desktop.theme.targets.<alvo>` (ex.: `targets.gtk`, `targets.bat`, `targets.vscode`, `targets.zsh`, `targets.firefox`, `targets.fastfetch`, etc.) em vez de criarem opções isoladas ou verificarem com `?`.

## Utilitários de Cor (`desktop.theme.lib` e `lib.my.theme`)

Disponíveis em `config.desktop.theme.lib` (no Home Manager) ou `lib.my.theme` (globalmente via `lib/helpers.nix`):

- `stripHash hex`: remove `#` inicial se presente.
- `hexToDec hex`: converte string hexadecimal de 1 ou 2 caracteres para decimal (0..255).
- `hexToTuple hex`: converte `#rrggbb` para lista `[ r g b ]` inteira.
- `hexToRgb hex`: converte `#rrggbb` para attrset `{ r, g, b }`.
- `withAlpha hex alpha`: concatena hex sem hash com canal alpha (ex.: `withAlpha c.bg "ff"` $\to$ `"1e1e2eff"`).
- `rgb hex`: formato Hyprland `rgb(rrggbb)`.
- `rgba hex alpha`: formato Hyprland `rgba(rrggbbaa)`.
- `cssRgb hex`: formato CSS `rgb(r, g, b)`.
- `cssRgba hex alpha`: formato CSS `rgba(r, g, b, a)`.
- `hexTo0x hex alpha`: formato MangoWM `0xrrggbbaa`.
- `generateTmTheme { name, colors }`: gera especificação TextMate `.tmTheme` completa (usada pelo `bat` e editores).

## Consumindo as Cores nos Módulos

Use papéis semânticos, nunca valores hexadecimais fixos:

```nix
let
  c = config.desktop.theme.colors;
  themeLib = config.desktop.theme.lib;
in {
  border_color = c.border;
  background = c.bg;
  active_rgba = themeLib.rgba c.accent "ee";
}
```

Papéis semânticos universais:
`bg bgAlt bgDark surface surfaceAlt border fg fgMuted fgSubtle red orange yellow green teal cyan blue purple pink accent`.
`colorsBare` traz as mesmas cores sem `#` (ex.: `c.bg` $\to$ `"1e1e2e"`).

## Nova Paleta por Arquivo

1. Crie `palettes/<nome>.nix` exportando a função `{ lib, pkgs, accent }: { label, variant, colors, gtk, icons, cursor }`.
2. O índice (`palettes/default.nix`) descobre o arquivo automaticamente via `builtins.readDir` sem necessidade de editar listas manuais.
3. Arquivos iniciados por `_` são ignorados no catálogo e servem como helpers compartilhados (ex.: `_catppuccin.nix`).

## Suporte Base16 (Investigação e Descarte Formal de `pkgs.base16-schemes`)

- **Verificação**: `pkgs.base16-schemes` é empacotado no Nixpkgs como uma derivação construída via `fetchFromGitHub`.
- **Inviabilidade sem IFD**: A leitura ou extração dos esquemas YAML em tempo de avaliação do Nix (`builtins.readFile`, `builtins.fromYAML`, `import`) exige **IFD (Import From Derivation)**, o que força compilações durante a fase pura de avaliação, quebra a idempotência hermética de flakes (`nix flake check`) e degrada severamente a performance de avaliação.
- **Decisão**: O suporte automático lendo de `pkgs.base16-schemes` foi formalmente descartado para evitar IFD. Para usar paletas no padrão Base16, basta declará-las via `desktop.theme.custom` ou adicioná-las como arquivo puro em `palettes/`.

## Validação

```bash
nix eval .#homeConfigurations."juca@nitro".config.desktop.theme.colors.bg
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
nix build .#nixosConfigurations.rocinante.config.system.build.toplevel --dry-run
```
