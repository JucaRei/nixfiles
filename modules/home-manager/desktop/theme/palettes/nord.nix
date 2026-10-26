{ pkgs, ... }:
let
  # Paleta oficial Nord (Arctic Ice Studio por Sven Greb)
  nord = {
    # ── Polar Night (Fundos, superfícies e bordas escuras) ─────────
    nord0 = "#2e3440"; # Base principal escura (janelas e terminais)
    nord1 = "#3b4252"; # Superfície elevada (cards, menus, inputs)
    nord2 = "#434c5e"; # Superfície secundária (seleção de itens, hover)
    nord3 = "#4c566a"; # Bordas, separadores e comentários sutis

    # ── Snow Storm (Textos, destaques e glifos claros) ────────────
    nord4 = "#d8dee9"; # Texto padrão principal (foreground)
    nord5 = "#e5e9f0"; # Texto secundário e títulos com alto contraste
    nord6 = "#eceff4"; # Texto de alto brilho e destaque especial

    # ── Frost (Tons de gelo e água: ciano, azul e menta) ─────────
    nord7 = "#8fbcbb"; # Verde menta ártico / teal / conexões de rede
    nord8 = "#88c0d0"; # Ciano glacial brilhante / acento padrão
    nord9 = "#81a1c1"; # Azul glacial suave / diretórios e workspaces
    nord10 = "#5e81ac"; # Azul ártico profundo / links e seleção

    # ── Aurora (Cores vibrantes para status, alertas e sintaxe) ───
    nord11 = "#bf616a"; # Aurora vermelho (erros, falhas e tags críticas)
    nord12 = "#d08770"; # Aurora laranja (avisos, alertas e progresso)
    nord13 = "#ebcb8b"; # Aurora amarelo (busca ativa, avisos sutis)
    nord14 = "#a3be8c"; # Aurora verde (sucesso, online e conclusão)
    nord15 = "#b48ead"; # Aurora roxo/magenta (módulos, CPU e identificadores)
  };
in
{
  label = "Nord";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    # ── Fundos & Superfícies ───────────────────────────────────────
    bg = nord.nord0; # Fundo principal da interface
    bgAlt = "#272c36"; # Fundo alternativo mais escuro derivado
    bgDark = "#222730"; # Fundo ultra escuro para tooltips e popups
    surface = nord.nord1; # Superfície de cards, painéis e inputs
    surfaceAlt = nord.nord2; # Superfície elevada / item sob cursor
    border = nord.nord3; # Linhas divisórias e contornos

    # ── Textos & Tipografia ────────────────────────────────────────
    fg = nord.nord4; # Texto padrão com alta legibilidade
    fgMuted = "#a5b1c4"; # Texto atenuado derivado para legendas
    fgSubtle = "#616e88"; # Comentários e texto sutil

    # ── Cores de Acento & Destaque (Frost & Aurora) ───────────────
    red = nord.nord11; # Alertas e erros
    orange = nord.nord12; # Avisos e atenção
    yellow = nord.nord13; # Destaques quentes e busca
    green = nord.nord14; # Sucesso, status online e baterias
    teal = nord.nord7; # Menta glacial / conexões
    cyan = nord.nord8; # Ciano glacial / links
    blue = nord.nord9; # Azul glacial / workspaces e diretórios
    purple = nord.nord15; # Roxo aurora / CPU e layouts
    pink = nord.nord15; # Nord não possui rosa; reaproveita aurora roxo

    # ── Extras e compatibilidade (Polybar e tokens canônicos) ──────
    lavender = nord.nord9;
    sapphire = nord.nord10;
    sky = nord.nord8;
    maroon = nord.nord11;
    peach = nord.nord12;
    mauve = nord.nord15;
    flamingo = nord.nord12;
    rosewater = nord.nord6;
    subtext1 = nord.nord5;

    # ── Tokens Canônicos Nord Exportados ───────────────────────────
    inherit (nord)
      nord0
      nord1
      nord2
      nord3
      nord4
      nord5
      nord6
      nord7
      nord8
      nord9
      nord10
      nord11
      nord12
      nord13
      nord14
      nord15
      ;
  };

  gtk = {
    name = "Nordic";
    package = pkgs.nordic;
  };

  icons = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };

  cursor = {
    name = "Nordzy-cursors";
    package = pkgs.nordzy-cursor-theme;
  };
}
