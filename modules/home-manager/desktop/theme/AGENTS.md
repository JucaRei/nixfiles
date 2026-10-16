# Tema agnóstico (`desktop.theme`) — guia do módulo

Aplica paleta, GTK, ícones, cursor e fonte em **qualquer host e desktop** (BSPWM, DWM, Hyprland, MangoWM, XFCE4). Substitui os 5 blocos de GTK que eram copiados em cada ambiente.

## Uso

```nix
# home-manager/hosts/<host>/default.nix
desktop.theme = {
  enable = true;
  name = "dracula";   # catppuccin-mocha | catppuccin-macchiato | dracula | nord | gruvbox-dark | tokyo-night
  accent = "purple";  # red orange yellow green teal cyan blue purple pink
};
```

Sem `enable`, nada é aplicado, mas as **cores continuam disponíveis** para os módulos (`colors` é sempre calculado).

## Consumindo as cores nos módulos

Use papéis semânticos, nunca hex solto:

```nix
let c = config.desktop.theme.colors; in
{ border_color = c.border; background = c.bg; text = c.fg; highlight = c.accent; }
```

Papéis: `bg bgAlt bgDark surface surfaceAlt border fg fgMuted fgSubtle red orange yellow green teal cyan blue purple pink accent`. `colorsBare` traz as mesmas cores sem `#` (ex.: Hyprland `rgb(${c.bg})`). Extras específicos de uma paleta (ex.: `lavender` no Catppuccin) existem só nela; use `c.lavender or c.purple`.

## Nova paleta

1. Copie `palettes/dracula.nix` para `palettes/<nome>.nix` e ajuste cores, `gtk`, `icons`, `cursor`.
2. Pronto: o índice (`palettes/default.nix`) descobre o arquivo sozinho e o `name` aceita o novo valor.
3. Arquivos que começam com `_` são helpers (ex.: `_catppuccin.nix`, compartilhado por Mocha e Macchiato). Para Frappé e Latte basta um arquivo de 20 linhas usando o helper.
4. Valores com `# ~` são derivados quando a paleta original não define o papel.

## Como a migração é segura

Tudo é aplicado com `mkDefault`. Os blocos antigos de GTK nos ambientes continuam valendo (prioridade maior) até você apagá-los, então dá para migrar um ambiente por vez. Ver `MIGRATION.md`.

## Pendente de verificação

- Os pacotes e nomes não-Catppuccin (`dracula-theme`, `nordic`, `nordzy-cursor-theme`, `gruvbox-gtk-theme`, `tokyonight-gtk-theme`, `bibata-cursors`) foram escritos de memória e **não foram avaliados**. Se um nome de tema estiver errado, sobrescreva sem editar a paleta: `desktop.theme.gtk = { name = "..."; package = pkgs....; };`.
- Qt e terminais (cores ANSI) ainda não são tratados; o ponto de extensão é este módulo.

## Validação

```bash
nix eval .#homeConfigurations."juca@nitro".config.desktop.theme.colors.bg
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
