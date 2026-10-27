{ pkgs, ... }:
{
  label = "Doom One";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    bg = "#282c34";
    bgAlt = "#21242b";
    bgDark = "#1b1d23";
    surface = "#21242b";
    surfaceAlt = "#50536b";
    border = "#50536b";

    fg = "#dfdfdf";
    fgMuted = "#abb2bf";
    fgSubtle = "#b2b2b2";

    red = "#ff6c6b";
    orange = "#da8548";
    yellow = "#ecbe7b";
    green = "#95be65";
    teal = "#4db5bd";
    cyan = "#46d9ff";
    blue = "#6eaafb";
    purple = "#c678dd";
    pink = "#ff6c6b";
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
