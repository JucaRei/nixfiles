{ pkgs, ... }:
let
  # Paleta oficial Kanagawa Wave (por Tommaso Laurenzi / rebelot)
  # Inspirada nas gravuras clássicas japonesas de Katsushika Hokusai
  kanagawa = {
    # ── Sumi Ink (Fundos e superfícies escuras inspiradas em nanquim) ─
    sumiInk0 = "#16161d"; # Nanquim profundo / fundo escuro de canvas e modais
    sumiInk1 = "#1f1f28"; # Nanquim padrão / fundo principal do editor e janelas
    sumiInk2 = "#2a2a37"; # Nanquim suave / fundo alternativo e statusline
    sumiInk3 = "#363646"; # Nanquim de superfície / cards, menus e popups
    sumiInk4 = "#54546d"; # Nanquim elevado / seleção de itens e borders suaves
    sumiInk5 = "#363644"; # Nanquim para linhas divisórias
    sumiInk6 = "#545464"; # Nanquim para superfícies elevadas

    # ── Wave Blue (Tons oceânicos para separadores e profundidade) ─
    waveBlue1 = "#223249"; # Azul mar profundo / destaques de fundo
    waveBlue2 = "#2d4f67"; # Azul ondas / contornos de bordas e janelas

    # ── Fuji (Textos claros inspirados nas cores do Monte Fuji) ───
    fujiWhite = "#dcd7ba"; # Branco Fuji / texto principal padrão com alta legibilidade
    fujiGray = "#727169"; # Cinza Fuji / comentários e texto atenuado
    oldWhite = "#c8c093"; # Branco antigo / texto secundário e labels atenuados

    # ── Cores da Natureza Japonesa (Sintaxe e Acentos) ────────────
    autumnRed = "#c34043"; # Vermelho outonal / erros e alertas
    autumnGreen = "#76946a"; # Verde outonal suave
    autumnYellow = "#dca561"; # Amarelo outono quente / busca e atenção
    samuraiRed = "#e82424"; # Vermelho samurai intenso
    roninYellow = "#ff9e3b"; # Amarelo/laranja ronin
    waveAqua1 = "#6a9589"; # Aqua oceano suave
    waveAqua2 = "#7aa89f"; # Aqua oceano vibrante / teal e conexões
    springGreen = "#98bb6c"; # Verde primavera / sucesso e strings
    springBlue = "#7fb4ca"; # Azul primavera / ciano
    springViolet1 = "#938aa9"; # Violeta primavera suave
    springViolet2 = "#9cabca"; # Violeta primavera claro
    boatYellow1 = "#938056"; # Amarelo barco ocre
    boatYellow2 = "#c0a36e"; # Amarelo barco dourado
    carpYellow = "#e6c384"; # Amarelo carpa
    sakuraPink = "#d27e99"; # Rosa flor de cerejeira (sakura)
    waveRed = "#e46876"; # Vermelho ondas
    peachRed = "#ff5d62"; # Vermelho pêssego
    surimiOrange = "#ffa066"; # Laranja surimi / avisos e constantes
    oniViolet = "#957fb8"; # Roxo Oni / funções, layouts e acentos
    crystalBlue = "#7e9cd8"; # Azul cristal / links, diretórios e workspaces
    katanaGray = "#717c7c"; # Cinza katana
  };
in
{
  label = "Kanagawa Wave";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    # ── Fundos & Superfícies ───────────────────────────────────────
    bg = kanagawa.sumiInk1; # Fundo principal
    bgAlt = kanagawa.sumiInk2; # Fundo alternativo
    bgDark = kanagawa.sumiInk0; # Fundo profundo
    surface = kanagawa.sumiInk3; # Superfície de cards e inputs
    surfaceAlt = kanagawa.sumiInk4; # Superfície elevada / item sob cursor
    border = kanagawa.waveBlue2; # Bordas e separadores

    # ── Textos & Tipografia ────────────────────────────────────────
    fg = kanagawa.fujiWhite; # Texto principal padrão
    fgMuted = kanagawa.oldWhite; # Texto atenuado
    fgSubtle = kanagawa.fujiGray; # Comentários e texto sutil

    # ── Cores de Acento & Destaque ─────────────────────────────────
    red = kanagawa.autumnRed; # Erros e alertas
    orange = kanagawa.surimiOrange; # Avisos e atenção
    yellow = kanagawa.autumnYellow; # Destaques quentes e busca
    green = kanagawa.springGreen; # Sucesso e status
    teal = kanagawa.waveAqua2; # Aqua / conexões de rede
    cyan = kanagawa.springBlue; # Ciano / links
    blue = kanagawa.crystalBlue; # Azul cristal / workspaces
    purple = kanagawa.oniViolet; # Roxo Oni / identificadores e CPU
    pink = kanagawa.sakuraPink; # Rosa cerejeira

    # ── Extras e compatibilidade (Polybar e tokens canônicos) ──────
    lavender = kanagawa.springViolet1;
    sapphire = kanagawa.waveBlue1;
    sky = kanagawa.springBlue;
    maroon = kanagawa.autumnRed;
    peach = kanagawa.surimiOrange;
    mauve = kanagawa.oniViolet;
    flamingo = kanagawa.sakuraPink;
    rosewater = kanagawa.fujiWhite;
    subtext1 = kanagawa.oldWhite;

    # ── Tokens Canônicos Kanagawa Exportados ────────────────────────
    inherit (kanagawa)
      sumiInk0
      sumiInk1
      sumiInk2
      sumiInk3
      sumiInk4
      sumiInk5
      sumiInk6
      waveBlue1
      waveBlue2
      fujiWhite
      fujiGray
      oldWhite
      autumnRed
      autumnGreen
      autumnYellow
      samuraiRed
      roninYellow
      waveAqua1
      waveAqua2
      springGreen
      springBlue
      springViolet1
      springViolet2
      boatYellow1
      boatYellow2
      carpYellow
      sakuraPink
      waveRed
      peachRed
      surimiOrange
      oniViolet
      crystalBlue
      katanaGray
      ;
  };

  gtk = {
    name = "Kanagawa";
    package = pkgs.kanagawa-gtk-theme or pkgs.tokyonight-gtk-theme;
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
