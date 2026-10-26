args:
let
  # Paleta oficial Catppuccin Macchiato (por Catppuccin Org)
  macchiato = {
    # ── Fundos & Superfícies (Base, Mantle, Crust) ─────────────────
    crust = "#181926"; # Fundo profundo para tooltips e popups
    mantle = "#1e2030"; # Fundo alternativo para statusbars e sidebars
    base = "#24273a"; # Fundo principal da aplicação

    # ── Superfícies & Bordas (Surfaces & Overlays) ────────────────
    surface0 = "#363a4f"; # Superfície de cards, caixas e inputs
    surface1 = "#494d64"; # Superfície elevada / itens sob cursor
    surface2 = "#5b6078"; # Bordas, separadores e divisórias
    overlay0 = "#6e738d"; # Comentários e texto sutil
    overlay1 = "#8087a2"; # Ícones secundários e atalhos
    overlay2 = "#939ab7"; # Texto secundário sutil

    # ── Textos & Tipografia (Subtext & Text) ───────────────────────
    subtext0 = "#a5adcb"; # Texto atenuado e labels inativos
    subtext1 = "#b8c0e0"; # Texto secundário e títulos suaves
    text = "#cad3f5"; # Texto principal com alta legibilidade

    # ── Acentos & Cores Vibrantes (Macchiato Accents) ──────────────
    rosewater = "#f4dbd6"; # Rosa claro suave
    flamingo = "#f0c6c6"; # Rosa flamingo
    pink = "#f5bde6"; # Rosa vibrante
    mauve = "#c6a0f6"; # Roxo/lilás assinatura Catppuccin
    red = "#ed8796"; # Vermelho suave para alertas e erros
    maroon = "#ee99a0"; # Vermelho bordô / alertas secundários
    peach = "#f5a97f"; # Pêssego / laranja de atenção e avisos
    yellow = "#eed49f"; # Amarelo dourado / busca ativa
    green = "#a6da95"; # Verde pastel / sucesso e status online
    teal = "#8bd5ca"; # Verde água suave
    sky = "#91d7e3"; # Ciano claro / links e conexões
    sapphire = "#7dc4e4"; # Azul safira
    blue = "#8aadf4"; # Azul vibrante / diretórios e workspaces
    lavender = "#b7bdf8"; # Azul lavanda / foco e identificadores
  };
in
import ./_catppuccin.nix (
  args
  // {
    variant = "macchiato";
    label = "Catppuccin Macchiato";
    colors = {
      # ── Fundos & Superfícies ───────────────────────────────────────
      bg = macchiato.base;
      bgAlt = macchiato.mantle;
      bgDark = macchiato.crust;
      surface = macchiato.surface0;
      surfaceAlt = macchiato.surface1;
      border = macchiato.surface2;

      # ── Textos & Tipografia ────────────────────────────────────────
      fg = macchiato.text;
      fgMuted = macchiato.subtext0;
      fgSubtle = macchiato.overlay0;

      # ── Cores de Acento & Destaque ─────────────────────────────────
      red = macchiato.red;
      orange = macchiato.peach;
      yellow = macchiato.yellow;
      green = macchiato.green;
      teal = macchiato.teal;
      cyan = macchiato.sky;
      blue = macchiato.blue;
      purple = macchiato.mauve;
      pink = macchiato.pink;

      # ── Tokens Canônicos Catppuccin Exportados ─────────────────────
      inherit (macchiato)
        rosewater
        flamingo
        mauve
        maroon
        peach
        sky
        sapphire
        lavender
        text
        subtext1
        subtext0
        overlay2
        overlay1
        overlay0
        surface2
        surface1
        surface0
        base
        mantle
        crust
        ;
    };
  }
)
