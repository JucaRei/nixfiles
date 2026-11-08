# Cyberpunk Neon palette definition
{ pkgs, ... }:
{
  label = "Cyberpunk";
  variant = "dark";

  colors = {
    bg = "#120e16";
    bgAlt = "#18131d";
    bgDark = "#0a080c";
    surface = "#221a28";
    surfaceAlt = "#32253b";
    border = "#711c91";

    fg = "#e0e6ed";
    fgMuted = "#8b9bb4";
    fgSubtle = "#56647a";

    red = "#ff0055";
    orange = "#ff7700";
    yellow = "#fcee0a";
    green = "#00ff9f";
    teal = "#00f0ff";
    cyan = "#00f0ff";
    blue = "#00b8ff";
    purple = "#9d00ff";
    pink = "#ff007f";
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
