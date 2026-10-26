{ pkgs, ... }:
let
  # Paleta canônica oficial Dracula (por Zeno Rocha)
  dracula = {
    # ── Fundos e Superfícies ──────────────────────────────────────
    background = "#282a36"; # Fundo principal escuro
    currentLine = "#44475a"; # Linha atual e superfície de elementos
    selection = "#44475a"; # Fundo de seleção de texto e itens
    comment = "#6272a4"; # Comentários, bordas e elementos neutros

    # ── Textos ────────────────────────────────────────────────────
    foreground = "#f8f8f2"; # Texto principal de alto contraste

    # ── Cores Vibrantes (Vampire Accent Palette) ───────────────────
    cyan = "#8be9fd"; # Ciano elétrico / links e conexões
    green = "#50fa7b"; # Verde neon / sucesso e conclusão
    orange = "#ffb86c"; # Laranja vibrante / avisos e números
    pink = "#ff79c6"; # Rosa neon assinatura / seleções e destaques
    purple = "#bd93f9"; # Roxo/lavanda assinatura / palavras-chave e layout
    red = "#ff5555"; # Vermelho neon / erros e alertas
    yellow = "#f1fa8c"; # Amarelo vibrante / busca e avisos
  };
in
{
  label = "Dracula";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    # ── Fundos & Superfícies ───────────────────────────────────────
    bg = dracula.background; # Fundo principal
    bgAlt = "#21222c"; # Fundo alternativo mais profundo derivado
    bgDark = "#191a21"; # Fundo ultra escuro para tooltips e modais
    surface = dracula.currentLine; # Superfície de cards, painéis e inputs
    surfaceAlt = "#565a72"; # Superfície elevada / item sob cursor derivado
    border = dracula.comment; # Linhas divisórias e contorno de janelas

    # ── Textos & Tipografia ────────────────────────────────────────
    fg = dracula.foreground; # Texto padrão com alta legibilidade
    fgMuted = "#adb5cb"; # Texto atenuado e secundário
    fgSubtle = dracula.comment; # Texto sutil, comentários e placeholders

    # ── Cores de Acento & Destaque ─────────────────────────────────
    red = dracula.red; # Alertas, erros e tags urgentes
    orange = dracula.orange; # Avisos, atenção e progresso
    yellow = dracula.yellow; # Destaque quente e busca ativa
    green = dracula.green; # Sucesso, status online e baterias
    teal = dracula.cyan; # Ciano/teal para conexões de rede
    cyan = dracula.cyan; # Ciano para links e status
    blue = dracula.comment; # Dracula não possui azul puro; usa o tom comment
    purple = dracula.purple; # Roxo clássico Dracula para layouts e CPU
    pink = dracula.pink; # Rosa neon para destaques especiais

    # ── Extras e compatibilidade (Polybar e tokens canônicos) ──────
    lavender = dracula.purple;
    sapphire = dracula.cyan;
    sky = dracula.cyan;
    maroon = dracula.red;
    peach = dracula.orange;
    mauve = dracula.purple;
    flamingo = dracula.pink;
    rosewater = dracula.foreground;
    subtext1 = "#adb5cb";

    # ── Tokens Canônicos Dracula Exportados ─────────────────────────
    inherit (dracula)
      background
      currentLine
      selection
      comment
      foreground
      ;
  };

  gtk = {
    name = "Dracula";
    package = pkgs.dracula-theme;
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
