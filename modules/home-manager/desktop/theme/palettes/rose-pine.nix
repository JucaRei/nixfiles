# Rosé Pine Moon palette definition
{ pkgs, ... }:
{
  label = "Rosé Pine";
  variant = "dark";

  colors = {
    bg = "#191724";
    bgAlt = "#1f1d2e";
    bgDark = "#14121d";
    surface = "#26233a";
    surfaceAlt = "#403d52";
    border = "#524f67";

    fg = "#e0def4";
    fgMuted = "#908caa";
    fgSubtle = "#6e6a86";

    red = "#eb6f92";
    orange = "#f6c177";
    yellow = "#ebbcba";
    green = "#31748f";
    teal = "#9ccfd8";
    cyan = "#9ccfd8";
    blue = "#3e8fb0";
    purple = "#c4a7e7";
    pink = "#eb6f92";
  };

  gtk = {
    name = "rose-pine";
    package = pkgs.rose-pine-gtk-theme;
  };

  icons = {
    name = "rose-pine-icons";
    package = pkgs.rose-pine-icon-theme;
  };

  cursor = {
    name = "BreezeX-RosePine-Linux";
    package = pkgs.rose-pine-cursor;
  };
}
