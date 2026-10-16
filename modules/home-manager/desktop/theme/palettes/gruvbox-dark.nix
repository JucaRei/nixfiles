# Valores marcados com "~" são derivados (o Gruvbox não define esse papel).
{ pkgs, ... }:
{
  label = "Gruvbox Dark";
  variant = "dark";
  colors = {
    bg = "#282828";
    bgAlt = "#1d2021";
    bgDark = "#141617"; # ~
    surface = "#3c3836";
    surfaceAlt = "#504945";
    border = "#665c54";
    fg = "#ebdbb2";
    fgMuted = "#a89984";
    fgSubtle = "#928374";
    red = "#fb4934";
    orange = "#fe8019";
    yellow = "#fabd2f";
    green = "#b8bb26";
    teal = "#8ec07c";
    cyan = "#8ec07c";
    blue = "#83a598";
    purple = "#d3869b";
    pink = "#d3869b";
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
