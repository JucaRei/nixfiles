{ pkgs, ... }:
{
  label = "Kanagawa Wave";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    bg = "#1f1f28";
    bgAlt = "#2a2a37";
    bgDark = "#16161d";
    surface = "#363646";
    surfaceAlt = "#54546d";
    border = "#2d4f67";

    fg = "#dcd7ba";
    fgMuted = "#c8c093";
    fgSubtle = "#727169";

    red = "#c34043";
    orange = "#ffa066";
    yellow = "#dca561";
    green = "#76946a";
    teal = "#7aa89f";
    cyan = "#7fb4ca";
    blue = "#7e9cd8";
    purple = "#957fb8";
    pink = "#d27e99";
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
