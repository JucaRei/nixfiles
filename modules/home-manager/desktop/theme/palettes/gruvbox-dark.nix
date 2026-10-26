{ pkgs, ... }:
let
  # Cores canônicas oficiais do Gruvbox (Dark mode por Pavel Pertsev / morhetz)
  gruvbox = {
    # ── Fundos (Dark tones) ────────────────────────────────────────
    dark0Hard = "#1d2021"; # Fundo rígido de alto contraste (dark0_hard)
    dark0 = "#282828"; # Fundo padrão do editor e terminal (dark0)
    dark0Soft = "#32302f"; # Fundo suave (dark0_soft)
    dark1 = "#3c3836"; # Superfície de cards, painéis e inputs (dark1)
    dark2 = "#504945"; # Superfície secundária / seleção de itens (dark2)
    dark3 = "#665c54"; # Bordas, separadores e linhas de foco (dark3)
    dark4 = "#7c6f64"; # Linhas guias e bordas neutras (dark4)

    # ── Textos (Light tones) ───────────────────────────────────────
    light0 = "#fbf1c7"; # Texto de alto brilho / destaque especial (light0)
    light1 = "#ebdbb2"; # Texto principal padrão (light1 / foreground)
    light2 = "#d5c4a1"; # Texto secundário e títulos suaves (light2)
    light3 = "#bdae93"; # Texto terciário e elementos secundários (light3)
    light4 = "#a89984"; # Texto atenuado e labels inativos (light4)
    gray = "#928374"; # Cinza neutro para comentários e texto sutil (gray_245)

    # ── Tons vibrantes (Bright colors para Dark Mode) ───────────────
    brightRed = "#fb4934";
    brightGreen = "#b8bb26";
    brightYellow = "#fabd2f";
    brightBlue = "#83a598";
    brightPurple = "#d3869b";
    brightAqua = "#8ec07c";
    brightOrange = "#fe8019";

    # ── Tons neutros / atenuados (Neutral / Faded colors) ───────────
    neutralRed = "#cc241d";
    neutralGreen = "#98971a";
    neutralYellow = "#d79921";
    neutralBlue = "#458588";
    neutralPurple = "#b16286";
    neutralAqua = "#689d6a";
    neutralOrange = "#d65d0e";
  };
in
{
  label = "Gruvbox Dark";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    # ── Fundos & Superfícies ───────────────────────────────────────
    bg = gruvbox.dark0; # Fundo principal (janelas, terminais, barras)
    bgAlt = gruvbox.dark0Hard; # Fundo alternativo mais escuro (dark0_hard)
    bgDark = "#141617"; # Fundo profundo derivado para popups e tooltips
    surface = gruvbox.dark1; # Superfície de cards, caixas e inputs (dark1)
    surfaceAlt = gruvbox.dark2; # Superfície elevada / item sob cursor (dark2)
    border = gruvbox.dark3; # Linhas divisórias e contorno de janelas (dark3)

    # ── Textos & Tipografia ────────────────────────────────────────
    fg = gruvbox.light1; # Texto padrão com excelente legibilidade (light1)
    fgMuted = gruvbox.light4; # Texto atenuado, descrições e ícones inativos (light4)
    fgSubtle = gruvbox.gray; # Texto sutil, comentários e placeholders (gray)

    # ── Cores de Acento & Destaque (Bright Palette) ────────────────
    red = gruvbox.brightRed; # Alertas, erros e tags urgentes
    orange = gruvbox.brightOrange; # Avisos, atenção e progresso
    yellow = gruvbox.brightYellow; # Destaque quente e busca ativa
    green = gruvbox.brightGreen; # Sucesso, status online e baterias
    teal = gruvbox.brightAqua; # Aqua vibrante / conexões de rede
    cyan = gruvbox.brightAqua; # Aqua / links e informações de sistema
    blue = gruvbox.brightBlue; # Diretórios, workspaces e links principais
    purple = gruvbox.brightPurple; # Módulos de CPU, layouts e identificadores
    pink = gruvbox.brightPurple; # Destaques secundários e mídias

    # ── Extras e compatibilidade (Polybar e tokens canônicos) ──────
    aqua = gruvbox.brightAqua;
    lavender = gruvbox.brightBlue;
    sapphire = gruvbox.neutralBlue;
    sky = gruvbox.brightAqua;
    maroon = gruvbox.neutralRed;
    peach = gruvbox.brightOrange;
    mauve = gruvbox.brightPurple;
    flamingo = gruvbox.neutralOrange;
    rosewater = gruvbox.light0;
    subtext1 = gruvbox.light2;

    # ── Tokens Canônicos Morhetz Exportados ────────────────────────
    inherit (gruvbox)
      dark0
      dark0Hard
      dark0Soft
      dark1
      dark2
      dark3
      dark4
      light0
      light1
      light2
      light3
      light4
      gray
      brightRed
      brightGreen
      brightYellow
      brightBlue
      brightPurple
      brightAqua
      brightOrange
      neutralRed
      neutralGreen
      neutralYellow
      neutralBlue
      neutralPurple
      neutralAqua
      neutralOrange
      ;
  };

  gtk = {
    name = "Gruvbox-Dark";
    package = pkgs.gruvbox-gtk-theme;
  };

  icons = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };

  cursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
  };
}
