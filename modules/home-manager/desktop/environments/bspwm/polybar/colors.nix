# Cores da Polybar. Os nomes (base, mantle, peach...) são mantidos para não mexer em
# modules.nix/scripts.nix; os valores agora vêm de `desktop.theme`.
# Importado em default.nix com: import ./colors.nix { theme = config.desktop.theme; }
{ theme }:
let
  c = theme.colors;
in
{
  # --- Papéis semânticos universais ---
  inherit (c)
    bg
    bgAlt
    bgDark
    surface
    surfaceAlt
    border
    fg
    fgMuted
    fgSubtle
    pink
    cyan
    teal
    green
    yellow
    red
    accent
    ;

  # --- Equivalentes Catppuccin (consumidos por modules.nix) ---
  inherit (c)
    base
    mantle
    crust
    surface0
    surface1
    surface2
    text
    subtext0
    subtext1
    blue
    lavender
    sapphire
    sky
    maroon
    mauve
    flamingo
    rosewater
    ;
  peach = c.orange;
  transparent = "#00000000";

  # --- Paleta Cápsulas & Pills (adaptada dinamicamente ao tema) ---
  base-alt = c.bgAlt;
  text-alt = c.fgMuted;
  pill = c.surface; # Fundo das cápsulas / pills
  pill-alt = c.surfaceAlt;
  pill-active = c.accent; # Fundo vibrante de destaque do workspace ativo
  dark = c.bgDark; # Fundo da barra escura
  gray = c.border; # Linha de foco e bordas
  muted = c.fgSubtle; # Texto sutil / ocupado
  yellow-alt = c.yellow; # Workspace 1
  coral = c.pink; # Workspace 2
  mint = c.teal; # Workspace 3
  nord = c.blue; # Workspace 4
  green-alt = c.green; # Workspace 5 / Wi-Fi
  ice = c.cyan; # Temperatura
  inherit (c) orange; # Memória
  inherit (c) purple; # CPU
  red-alt = c.red; # Som / Power / Alerta
  blue-alt = c.accent; # Launcher / Brilho
  bat-green = c.green; # Verde bateria
  bat-charging = c.red; # Vermelho suave recarga
  time-alt = c.fgMuted; # Cinza do relógio

  # --- Tons Dinâmicos do Tema (adaptam-se dinamicamente ao tema ativo) ---
  shade1 = c.surfaceAlt;
  shade2 = c.purple;
  shade3 = c.surface;
  shade4 = c.accent;
  shade5 = c.surfaceAlt;
  shade6 = c.teal;
  shade7 = c.surface;
  shade8 = c.fgMuted;
}
