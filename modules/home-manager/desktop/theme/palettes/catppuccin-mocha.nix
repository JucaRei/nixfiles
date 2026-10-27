args:
let
  # Paleta oficial Catppuccin Mocha (por Catppuccin Org)
  mocha = {
    # ── Fundos & Superfícies (Base, Mantle, Crust) ─────────────────
    crust = "#11111b"; # Fundo profundo para tooltips e popups
    mantle = "#181825"; # Fundo alternativo para statusbars e sidebars
    base = "#1e1e2e"; # Fundo principal da aplicação

    # ── Superfícies & Bordas (Surfaces & Overlays) ────────────────
    surface0 = "#313244"; # Superfície de cards, caixas e inputs
    surface1 = "#45475a"; # Superfície elevada / itens sob cursor
    surface2 = "#585b70"; # Bordas, separadores e divisórias
    overlay0 = "#6c7086"; # Comentários e texto sutil
    overlay1 = "#7f849c"; # Ícones secundários e atalhos
    overlay2 = "#9399b2"; # Texto secundário sutil

    # ── Textos & Tipografia (Subtext & Text) ───────────────────────
    subtext0 = "#a6adc8"; # Texto atenuado e labels inativos
    subtext1 = "#bac2de"; # Texto secundário e títulos suaves
    text = "#cdd6f4"; # Texto principal com alta legibilidade

    # ── Acentos & Cores Vibrantes (Mocha Accents) ──────────────────
    rosewater = "#f5e0dc"; # Rosa claro suave
    flamingo = "#f2cdcd"; # Rosa flamingo
    pink = "#f5c2e7"; # Rosa vibrante
    mauve = "#cba6f7"; # Roxo/lilás assinatura Catppuccin
    red = "#f38ba8"; # Vermelho suave para alertas e erros
    maroon = "#eba0ac"; # Vermelho bordô / alertas secundários
    peach = "#fab387"; # Pêssego / laranja de atenção e avisos
    yellow = "#f9e2af"; # Amarelo dourado / busca ativa
    green = "#a6e3a1"; # Verde pastel / sucesso e status online
    teal = "#94e2d5"; # Verde água suave
    sky = "#89dceb"; # Ciano claro / links e conexões
    sapphire = "#74c7ec"; # Azul safira
    blue = "#89b4fa"; # Azul vibrante / diretórios e workspaces
    lavender = "#b4befe"; # Azul lavanda / foco e identificadores
  };
in
import ./_catppuccin.nix (
  args
  // {
    variant = "mocha";
    label = "Catppuccin Mocha";
    colors = {
      # ── Fundos & Superfícies ───────────────────────────────────────
      bg = mocha.base;
      bgAlt = mocha.mantle;
      bgDark = mocha.crust;
      surface = mocha.surface0;
      surfaceAlt = mocha.surface1;
      border = mocha.surface2;

      # ── Textos & Tipografia ────────────────────────────────────────
      fg = mocha.text;
      fgMuted = mocha.subtext0;
      fgSubtle = mocha.overlay0;

      inherit (mocha)
        red
        yellow
        green
        teal
        blue
        pink
        ;
      orange = mocha.peach;
      cyan = mocha.sky;
      purple = mocha.mauve;

      # ── Tokens Canônicos Catppuccin Exportados ─────────────────────
      inherit (mocha)
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
