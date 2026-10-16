{ pkgs, ... }:
{
  label = "Tokyo Night";
  variant = "dark";
  colors = {
    bg = "#1a1b26";
    bgAlt = "#16161e";
    bgDark = "#13131a"; # ~
    surface = "#292e42";
    surfaceAlt = "#3b4261";
    border = "#414868";
    fg = "#c0caf5";
    fgMuted = "#a9b1d6";
    fgSubtle = "#565f89";
    red = "#f7768e";
    orange = "#ff9e64";
    yellow = "#e0af68";
    green = "#9ece6a";
    teal = "#73daca";
    cyan = "#7dcfff";
    blue = "#7aa2f7";
    purple = "#9d7cd8";
    pink = "#bb9af7";
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
