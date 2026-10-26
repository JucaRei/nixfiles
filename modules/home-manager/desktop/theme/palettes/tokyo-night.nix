{ pkgs, ... }:
let
  # Paleta oficial Tokyo Night (Dark mode por Folke Lemaitre / tokyonight.nvim)
  tokyoNight = {
    # ── Fundos & Superfícies ───────────────────────────────────────
    bg = "#1a1b26"; # Fundo principal Tokyo Night Dark
    bgDark = "#16161e"; # Fundo escuro (sidebar, statusline)
    bgHighlight = "#292e42"; # Linha ativa e seleção sutil
    terminalBlack = "#414868"; # Preto do terminal / bordas ativas

    # ── Superfícies & Bordas ──────────────────────────────────────
    surface = "#292e42"; # Superfície de cards e popups
    surfaceAlt = "#3b4261"; # Superfície elevada / bordas ativas
    border = "#414868"; # Linha divisória e bordas de janela

    # ── Tipografia & Textos ────────────────────────────────────────
    fg = "#c0caf5"; # Texto principal claro e suave
    fgDark = "#a9b1d6"; # Texto secundário e atenuado
    fgGutter = "#3b4261"; # Numeração de linhas e ícones sutis
    comment = "#565f89"; # Comentários e texto atenuado

    # ── Cores Vibrantes (Tokyo Neon) ──────────────────────────────
    red = "#f7768e"; # Vermelho neon / erros e alertas
    red1 = "#db4b4b"; # Vermelho escuro / erro crítico
    orange = "#ff9e64"; # Laranja quente / parâmetros e atenção
    yellow = "#e0af68"; # Amarelo dourado / busca ativa e avisos
    green = "#9ece6a"; # Verde suave / sucesso e strings
    green1 = "#73daca"; # Verde esmeralda / teal
    green2 = "#41a6b5"; # Verde profundo
    teal = "#73daca"; # Ciano esverdeado / conexões
    cyan = "#7dcfff"; # Ciano elétrico / tipos e links
    blue = "#7aa2f7"; # Azul assinatura Tokyo Night / funções e diretórios
    blue0 = "#3d59a1"; # Azul profundo
    purple = "#9d7cd8"; # Roxo Tokyo Night / statements e módulos
    magenta = "#bb9af7"; # Magenta neon / palavras-chave e destaques
    magenta2 = "#ff007c"; # Magenta vibrante
  };
in
{
  label = "Tokyo Night";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    # ── Fundos & Superfícies ───────────────────────────────────────
    bg = tokyoNight.bg; # Fundo principal
    bgAlt = tokyoNight.bgDark; # Fundo alternativo escuro
    bgDark = "#13131a"; # Fundo profundo derivado para tooltips
    surface = tokyoNight.surface; # Superfície de cards e inputs
    surfaceAlt = tokyoNight.surfaceAlt; # Superfície elevada / item sob cursor
    border = tokyoNight.border; # Bordas e divisores

    # ── Textos & Tipografia ────────────────────────────────────────
    fg = tokyoNight.fg; # Texto padrão com alta legibilidade
    fgMuted = tokyoNight.fgDark; # Texto secundário atenuado
    fgSubtle = tokyoNight.comment; # Comentários e texto sutil

    # ── Cores de Acento & Destaque ─────────────────────────────────
    red = tokyoNight.red; # Alertas, erros e tags críticas
    orange = tokyoNight.orange; # Avisos, atenção e progresso
    yellow = tokyoNight.yellow; # Destaque dourado e busca
    green = tokyoNight.green; # Sucesso, status online e baterias
    teal = tokyoNight.teal; # Verde água / conexões de rede
    cyan = tokyoNight.cyan; # Ciano elétrico / links
    blue = tokyoNight.blue; # Azul assinatura / workspaces
    purple = tokyoNight.purple; # Roxo Tokyo Night / layouts e CPU
    pink = tokyoNight.magenta; # Magenta vibrante / destaque secundário

    # ── Extras e compatibilidade (Polybar e tokens canônicos) ──────
    lavender = tokyoNight.magenta;
    sapphire = tokyoNight.blue0;
    sky = tokyoNight.cyan;
    maroon = tokyoNight.red1;
    peach = tokyoNight.orange;
    mauve = tokyoNight.purple;
    flamingo = tokyoNight.magenta;
    rosewater = tokyoNight.fg;
    subtext1 = tokyoNight.fgDark;

    # ── Tokens Canônicos Tokyo Night Exportados ────────────────────
    inherit (tokyoNight)
      bgHighlight
      terminalBlack
      fgDark
      fgGutter
      comment
      red1
      green1
      green2
      blue0
      magenta
      magenta2
      ;
  };

  gtk = {
    name = "Tokyonight-Dark";
    package = pkgs.tokyonight-gtk-theme;
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
