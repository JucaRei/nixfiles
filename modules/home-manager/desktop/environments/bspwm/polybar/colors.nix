# Cores da Polybar. Os nomes (base, mantle, peach...) são mantidos para não mexer em
# modules.nix/scripts.nix; os valores agora vêm de `desktop.theme`.
# Importado em default.nix com: import ./colors.nix { theme = config.desktop.theme; }
{ theme }:
let
  c = theme.colors;
  # Extras do Catppuccin; em outras paletas cai para o papel mais próximo ou valor literal
  extra =
    name: fallback:
    if c ? ${name} then
      c.${name}
    else if c ? ${fallback} then
      c.${fallback}
    else
      fallback;
in
{
  base = c.bg;
  mantle = c.bgAlt;
  crust = c.bgDark;
  surface0 = c.surface;
  surface1 = c.surfaceAlt;
  surface2 = c.border;
  text = c.fg;
  subtext0 = c.fgMuted;
  subtext1 = extra "subtext1" "fgMuted";
  blue = c.blue;
  lavender = extra "lavender" "purple";
  sapphire = extra "sapphire" "blue";
  sky = extra "sky" "cyan";
  cyan = c.cyan;
  teal = c.teal;
  green = c.green;
  yellow = c.yellow;
  peach = c.orange;
  maroon = extra "maroon" "red";
  red = c.red;
  mauve = c.purple;
  flamingo = extra "flamingo" "pink";
  rosewater = extra "rosewater" "pink";
  accent = c.accent;
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
  orange = c.orange; # Memória
  purple = c.purple; # CPU
  red-alt = c.red; # Som / Power / Alerta
  blue-alt = c.accent; # Launcher / Brilho
  bat-green = c.green; # Verde bateria
  bat-charging = c.red; # Vermelho suave recarga
  time-alt = c.fgMuted; # Cinza do relógio

  # --- Tons Dinâmicos do Tema (adaptam-se dinamicamente ao tema ativo) ---
  shade1 = extra "shade1" (extra "surfaceAlt" "bgAlt");
  shade2 = extra "shade2" (extra "purple" "surface");
  shade3 = extra "shade3" (extra "surface" "bgAlt");
  shade4 = extra "shade4" (extra "accent" "blue");
  shade5 = extra "shade5" (extra "surfaceAlt" "bgAlt");
  shade6 = extra "shade6" (extra "teal" "surface");
  shade7 = extra "shade7" (extra "surface" "bgAlt");
  shade8 = extra "shade8" (extra "fgMuted" "fg");
}
