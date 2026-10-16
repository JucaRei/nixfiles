# Cores da Polybar. Os nomes (base, mantle, peach...) são mantidos para não mexer em
# modules.nix/scripts.nix; os valores agora vêm de `desktop.theme`.
# Importado em default.nix com: import ./colors.nix { theme = config.desktop.theme; }
{ theme }:
let
  c = theme.colors;
  # Extras do Catppuccin; em outras paletas cai para o papel mais próximo
  extra = name: fallback: c.${name} or c.${fallback};
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
  teal = c.teal;
  green = c.green;
  yellow = c.yellow;
  peach = c.orange;
  maroon = extra "maroon" "red";
  red = c.red;
  mauve = c.purple;
  flamingo = extra "flamingo" "pink";
  rosewater = extra "rosewater" "pink";
  transparent = "#00000000";

  # --- Paleta Zproger / Cápsulas & Pills (fixa; independe do tema) ---
  base-alt = "#1e222a";
  text-alt = "#abb2bf";
  pill = "#2b2f37"; # Fundo das cápsulas / pills
  pill-alt = "#32363e";
  dark = "#1e222a"; # Fundo da barra escura
  gray = "#565c64"; # Linha de foco e bordas
  muted = "#646870"; # Texto sutil / ocupado
  yellow-alt = "#F9DE8F"; # Workspace 1
  coral = "#ff9b93"; # Workspace 2
  mint = "#95e1d3"; # Workspace 3
  nord = "#81A1C1"; # Workspace 4
  green-alt = "#A3BE8C"; # Workspace 5 / Wi-Fi
  ice = "#a4ebf3"; # Temperatura
  orange = "#d19a66"; # Memória
  purple = "#989cff"; # CPU
  red-alt = "#d35f5e"; # Som / Power / Alerta
  blue-alt = "#61afef"; # Launcher / Brilho
  bat-green = "#A0E8A2"; # Verde bateria
  bat-charging = "#DF8890"; # Vermelho suave recarga
  time-alt = "#888e96"; # Cinza do relógio
}
