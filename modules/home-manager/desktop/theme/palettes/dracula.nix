# Valores marcados com "~" são derivados (o Dracula não define esse papel).
{ pkgs, ... }:
{
  label = "Dracula";
  variant = "dark";
  colors = {
    bg = "#282a36";
    bgAlt = "#21222c";
    bgDark = "#191a21";
    surface = "#44475a";
    surfaceAlt = "#565a72"; # ~
    border = "#6272a4";
    fg = "#f8f8f2";
    fgMuted = "#adb5cb"; # ~
    fgSubtle = "#6272a4";
    red = "#ff5555";
    orange = "#ffb86c";
    yellow = "#f1fa8c";
    green = "#50fa7b";
    teal = "#8be9fd";
    cyan = "#8be9fd";
    blue = "#6272a4"; # ~ (Dracula não tem azul puro; usa o "comment")
    purple = "#bd93f9";
    pink = "#ff79c6";
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
