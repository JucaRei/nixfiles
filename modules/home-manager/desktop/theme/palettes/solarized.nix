# Solarized Dark palette definition
{ pkgs, ... }:
{
  label = "Solarized Dark";
  variant = "dark";

  colors = {
    bg = "#002b36";
    bgAlt = "#073642";
    bgDark = "#00212b";
    surface = "#073642";
    surfaceAlt = "#586e75";
    border = "#586e75";

    fg = "#839496";
    fgMuted = "#657b83";
    fgSubtle = "#586e75";

    red = "#dc322f";
    orange = "#cb4b16";
    yellow = "#b58900";
    green = "#859900";
    teal = "#2aa198";
    cyan = "#2aa198";
    blue = "#268bd2";
    purple = "#6c71c4";
    pink = "#d33682";
  };

  gtk = {
    name = "Solarized-Dark";
    package = pkgs.numix-solarized-gtk-theme;
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
