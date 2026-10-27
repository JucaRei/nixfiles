{ pkgs, ... }:
{
  label = "Nord";
  variant = "dark";

  # Papéis semânticos consumidos por todos os módulos do repositório
  colors = {
    bg = "#2e3440";
    bgAlt = "#272c36";
    bgDark = "#222730";
    surface = "#3b4252";
    surfaceAlt = "#434c5e";
    border = "#4c566a";

    fg = "#d8dee9";
    fgMuted = "#a5b1c4";
    fgSubtle = "#616e88";

    red = "#bf616a";
    orange = "#d08770";
    yellow = "#ebcb8b";
    green = "#a3be8c";
    teal = "#8fbcbb";
    cyan = "#88c0d0";
    blue = "#81a1c1";
    purple = "#b48ead";
    pink = "#b48ead";
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
